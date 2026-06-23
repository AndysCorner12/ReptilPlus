//
//  ReptilesPagerView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct ReptilesPagerView: View {
    let reptiles: [Reptil]
    @State private var currentIndex = 0
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Indicator de página
            HStack {
                ForEach(reptiles.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color(red: 0.2, green: 0.6, blue: 0.4) : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
            
            // TabView con swipe
            TabView(selection: $currentIndex) {
                ForEach(reptiles.indices, id: \.self) { index in
                    ReptilDetailContentView(reptil: reptiles[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Contador
            Text("\(currentIndex + 1) de \(reptiles.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .navigationTitle("Desliza para navegar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReptilDetailContentView: View {
    let reptil: Reptil
    @EnvironmentObject var appState: AppState
    
    var especie: Especie? {
        appState.especiePara(reptil)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Imagen grande
                ZStack {
                    Circle()
                        .fill(colorParaEstado(reptil.estado).opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "lizard.fill")
                        .font(.system(size: 80))
                        .foregroundColor(colorParaEstado(reptil.estado))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                // Nombre
                Text(reptil.nombre)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Especie
                if let especie = especie {
                    VStack(spacing: 4) {
                        Text(especie.nombreComun)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text(especie.nombreCientifico)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Divider()
                
                // Estrellas de salud
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estado de salud")
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < estrellasParaSalud(reptil.estado) ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                        
                        Text(reptil.estado.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(colorParaEstado(reptil.estado))
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
                
                // Información
                VStack(alignment: .leading, spacing: 16) {
                    InfoCard(icono: "scalemass", titulo: "Peso", valor: String(format: "%.1f gramos", reptil.pesoActual))
                    InfoCard(icono: "ruler", titulo: "Longitud", valor: String(format: "%.1f cm", reptil.longitudActual))
                    InfoCard(icono: iconoParaSexo(reptil.sexo), titulo: "Sexo", valor: reptil.sexo.rawValue.capitalized)
                }
                .padding(.horizontal)
                
                if let notas = reptil.notas, !notas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notas")
                            .font(.headline)
                        Text(notas)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
    
    func colorParaEstado(_ estado: EstadoSalud) -> Color {
        switch estado {
        case .saludable: return .green
        case .observacion: return .yellow
        case .enfermo: return .orange
        case .critico: return .red
        }
    }
    
    func estrellasParaSalud(_ estado: EstadoSalud) -> Int {
        switch estado {
        case .saludable: return 5
        case .observacion: return 4
        case .enfermo: return 3
        case .critico: return 2
        }
    }
    
    func iconoParaSexo(_ sexo: SexoReptil) -> String {
        switch sexo {
        case .macho: return "circle.fill"
        case .hembra: return "circle"
        case .desconocido: return "questionmark.circle"
        }
    }
}

struct InfoCard: View {
    let icono: String
    let titulo: String
    let valor: String
    
    var body: some View {
        HStack {
            Image(systemName: icono)
                .font(.title3)
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(valor)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
