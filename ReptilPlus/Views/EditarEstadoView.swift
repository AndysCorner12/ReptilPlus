//  EditarEstadoView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct EditarEstadoView: View {
    @Binding var reptil: Reptil
    @Environment(\.dismiss) var dismiss

    @State private var estadoSeleccionado: EstadoSalud
    @State private var notasEstado: String
    @State private var pesoActual: String
    @State private var longitudActual: String

    init(reptil: Binding<Reptil>) {
        self._reptil = reptil
        self._estadoSeleccionado = State(initialValue: reptil.wrappedValue.estado)
        self._notasEstado = State(initialValue: reptil.wrappedValue.notas ?? "")
        self._pesoActual = State(initialValue: String(format: "%.1f", reptil.wrappedValue.pesoActual))
        self._longitudActual = State(initialValue: String(format: "%.1f", reptil.wrappedValue.longitudActual))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Estado de Salud") {
                    Picker("Estado", selection: $estadoSeleccionado) {
                        ForEach(EstadoSalud.allCases, id: \.self) { estado in
                            HStack {
                                Circle()
                                    .fill(colorParaEstado(estado))
                                    .frame(width: 12, height: 12)
                                Text(estado.rawValue)
                            }
                            .tag(estado)
                        }
                    }
                    .pickerStyle(.menu)

                    HStack {
                        Text("Calificación:")
                        Spacer()
                        ForEach(0..<5) { index in
                            Image(systemName: index < estrellasParaSalud(estadoSeleccionado) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                }

                Section("Medidas Actuales") {
                    HStack {
                        Text("Peso (g):")
                        TextField("", text: $pesoActual)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Longitud (cm):")
                        TextField("", text: $longitudActual)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Notas") {
                    TextEditor(text: $notasEstado)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Editar Estado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") { guardarCambios() }
                }
            }
        }
    }

    func guardarCambios() {
        reptil.estado = estadoSeleccionado
        reptil.notas = notasEstado.isEmpty ? nil : notasEstado
        if let peso = Float(pesoActual.replacingOccurrences(of: ",", with: ".")), peso > 0 {
            reptil.pesoActual = peso
        }
        if let longitud = Float(longitudActual.replacingOccurrences(of: ",", with: ".")), longitud > 0 {
            reptil.longitudActual = longitud
        }
        dismiss()
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
