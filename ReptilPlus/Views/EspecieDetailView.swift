//
//  EspecieDetailView.swift
//  ReptilPlus
//

import SwiftUI

struct EspecieDetailView: View {
    let especie: Especie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(especie.nombreComun)
                        .font(.largeTitle)
                        .bold()
                    Text(especie.nombreCientifico)
                        .font(.title3)
                        .italic()
                        .foregroundColor(.secondary)
                    if let familia = especie.familia {
                        Text("Familia: \(familia)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    if !especie.descripcion.isEmpty {
                        DetalleSeccion(titulo: "Descripción") {
                            Text(especie.descripcion).font(.body)
                        }
                    }

                    DetalleSeccion(titulo: "Características") {
                        VStack(alignment: .leading, spacing: 4) {
                            if let tamano = especie.tamanoPromedio {
                                InfoRow(label: "Tamaño promedio", value: String(format: "%.0f cm", tamano), icono: "ruler")
                            }
                            if let esperanza = especie.esperanzaVida {
                                InfoRow(label: "Esperanza de vida", value: "\(esperanza) años", icono: "heart")
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle("Información de Especie")
        .navigationBarTitleDisplayMode(.inline)
    }
}
