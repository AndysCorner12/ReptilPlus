//  NuevoReptilView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct NuevoReptilView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var nombre = ""
    @State private var especieSeleccionada: Especie? = nil
    @State private var sexo: SexoReptil = .desconocido
    @State private var peso: String = ""
    @State private var longitud: String = ""
    @State private var estado: EstadoSalud = .saludable
    @State private var notas = ""
    @State private var fechaNacimiento = Date()
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Información básica") {
                    TextField("Nombre del reptil", text: $nombre)
                    Picker("Especie", selection: $especieSeleccionada) {
                        Text("Seleccionar...").tag(nil as Especie?)
                        ForEach(appState.coleccion.especies) { especie in
                            Text(especie.nombreComun).tag(Optional(especie))
                        }
                    }
                    Picker("Sexo", selection: $sexo) {
                        ForEach(SexoReptil.allCases, id: \.self) { s in
                            Text(s.rawValue.capitalized).tag(s)
                        }
                    }
                }

                Section("Medidas") {
                    TextField("Peso (gramos)", text: $peso)
                        .keyboardType(.decimalPad)
                    TextField("Longitud (cm)", text: $longitud)
                        .keyboardType(.decimalPad)
                }

                Section("Estado") {
                    Picker("Estado de salud", selection: $estado) {
                        ForEach(EstadoSalud.allCases, id: \.self) { e in
                            Text(e.rawValue).tag(e)
                        }
                    }
                    DatePicker("Fecha de nacimiento", selection: $fechaNacimiento, displayedComponents: .date)
                }

                Section("Notas") {
                    TextEditor(text: $notas)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nuevo Reptil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") { guardarReptil() }
                }
            }
            .alert("Atención", isPresented: $mostrarAlerta) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(mensajeAlerta)
            }
        }
    }

    func guardarReptil() {
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            mensajeAlerta = "El nombre es obligatorio"
            mostrarAlerta = true; return
        }
        guard let especie = especieSeleccionada else {
            mensajeAlerta = "Debes seleccionar una especie"
            mostrarAlerta = true; return
        }
        let pesoFloat = Float(peso.replacingOccurrences(of: ",", with: ".")) ?? 0
        let longitudFloat = Float(longitud.replacingOccurrences(of: ",", with: ".")) ?? 0

        let nuevoReptil = Reptil(
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            especieId: especie.id,
            fechaNacimiento: fechaNacimiento,
            pesoActual: pesoFloat,
            longitudActual: longitudFloat,
            sexo: sexo,
            estado: estado,
            notas: notas.isEmpty ? nil : notas
        )
        appState.coleccion.agregar(nuevoReptil)
        appState.guardarReptiles()
        dismiss()
    }
}
