//
//  EstadisticasView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct EstadisticasView: View {
    @EnvironmentObject var appState: AppState
    
    var estadisticas: Estadisticas {
        calcularEstadisticas()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Resumen general
                VStack(alignment: .leading, spacing: 16) {
                    Text("Resumen General")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(titulo: "Total Reptiles", valor: "\(estadisticas.total)", icono: "lizard.fill", color: .blue)
                        StatCard(titulo: "Especies", valor: "\(estadisticas.especies)", icono: "leaf.fill", color: .green)
                        StatCard(titulo: "Saludables", valor: "\(estadisticas.saludables)", icono: "heart.fill", color: .green)
                        StatCard(titulo: "En Observación", valor: "\(estadisticas.observacion)", icono: "eye.fill", color: .yellow)
                    }
                    .padding(.horizontal)
                }
                
                // Por sexo
                VStack(alignment: .leading, spacing: 16) {
                    Text("Distribución por Sexo")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        PieChartSegment(
                            valor: estadisticas.machos,
                            total: estadisticas.total,
                            color: .blue,
                            label: "Machos"
                        )
                        
                        PieChartSegment(
                            valor: estadisticas.hembras,
                            total: estadisticas.total,
                            color: .pink,
                            label: "Hembras"
                        )
                        
                        PieChartSegment(
                            valor: estadisticas.desconocidos,
                            total: estadisticas.total,
                            color: .gray,
                            label: "Desconocido"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Peso promedio
                VStack(alignment: .leading, spacing: 16) {
                    Text("Medidas Promedio")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        MeasureCard(
                            titulo: "Peso",
                            valor: String(format: "%.1f g", estadisticas.pesoPromedio),
                            icono: "scalemass"
                        )
                        
                        MeasureCard(
                            titulo: "Longitud",
                            valor: String(format: "%.1f cm", estadisticas.longitudPromedio),
                            icono: "ruler"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Top especies
                if !estadisticas.topEspecies.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Especies Más Populares")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(Array(estadisticas.topEspecies.enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(Color(red: 0.2, green: 0.6, blue: 0.4), in: Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.nombre)
                                        .font(.headline)
                                    Text("\(item.cantidad) reptiles")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(Int((Double(item.cantidad) / Double(estadisticas.total)) * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Estadísticas")
    }
    
    func calcularEstadisticas() -> Estadisticas {
        let reptiles = appState.coleccion.reptiles
        
        let machos = reptiles.filter { $0.sexo == .macho }.count
        let hembras = reptiles.filter { $0.sexo == .hembra }.count
        let desconocidos = reptiles.filter { $0.sexo == .desconocido }.count
        
        let saludables = reptiles.filter { $0.estado == .saludable }.count
        let observacion = reptiles.filter { $0.estado == .observacion }.count
        
        let pesoTotal = reptiles.reduce(0 as Float) { $0 + $1.pesoActual }
        let pesoPromedio = reptiles.isEmpty ? 0 : pesoTotal / Float(reptiles.count)
        
        let longitudTotal = reptiles.reduce(0 as Float) { $0 + $1.longitudActual }
        let longitudPromedio = reptiles.isEmpty ? 0 : longitudTotal / Float(reptiles.count)
        
        // Top especies
        var especiesCount: [UUID: Int] = [:]
        for reptil in reptiles {
            especiesCount[reptil.especieId, default: 0] += 1
        }
        
        let topEspecies = especiesCount.sorted { $0.value > $1.value }
            .prefix(5)
            .compactMap { especieId, cantidad -> (nombre: String, cantidad: Int)? in
                guard let especie = appState.coleccion.especiePara(id: especieId) else { return nil }
                return (nombre: especie.nombreComun, cantidad: cantidad)
            }
        
        return Estadisticas(
            total: reptiles.count,
            especies: appState.coleccion.especies.count,
            machos: machos,
            hembras: hembras,
            desconocidos: desconocidos,
            saludables: saludables,
            observacion: observacion,
            pesoPromedio: pesoPromedio,
            longitudPromedio: longitudPromedio,
            topEspecies: topEspecies
        )
    }
}

struct Estadisticas {
    let total: Int
    let especies: Int
    let machos: Int
    let hembras: Int
    let desconocidos: Int
    let saludables: Int
    let observacion: Int
    let pesoPromedio: Float
    let longitudPromedio: Float
    let topEspecies: [(nombre: String, cantidad: Int)]
}

struct StatCard: View {
    let titulo: String
    let valor: String
    let icono: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icono)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(valor)
                .font(.title)
                .fontWeight(.bold)
            
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PieChartSegment: View {
    let valor: Int
    let total: Int
    let color: Color
    let label: String
    
    var porcentaje: Int {
        total > 0 ? Int((Double(valor) / Double(total)) * 100) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Text("\(porcentaje)%")
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(valor)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MeasureCard: View {
    let titulo: String
    let valor: String
    let icono: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icono)
                .font(.system(size: 28))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
            
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(valor)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
}
