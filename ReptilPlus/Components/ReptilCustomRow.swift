//
//  ReptilCustomRow.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct ReptilCustomRow: View {
    let reptil: Reptil
    let especie: Especie?
    
    var body: some View {
        HStack(spacing: 12) {
            // Imagen circular del reptil
            ZStack {
                Circle()
                    .fill(colorParaEstado(reptil.estado).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "lizard.fill")
                    .font(.system(size: 30))
                    .foregroundColor(colorParaEstado(reptil.estado))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reptil.nombre)
                    .font(.headline)
                
                if let especie = especie {
                    Text(especie.nombreComun)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < estrellasParaSalud(reptil.estado) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack(spacing: 8) {
                    Label(String(format: "%.0f g", reptil.pesoActual), systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(String(format: "%.0f cm", reptil.longitudActual), systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack {
                Circle()
                    .fill(colorParaEstado(reptil.estado))
                    .frame(width: 12, height: 12)
                
                Text(reptil.estado.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(colorParaEstado(reptil.estado))
            }
        }
        .padding(.vertical, 8)
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
}
