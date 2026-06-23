//
//  OpinionesView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct Opinion: Identifiable, Codable {
    let id: UUID
    var reptilId: UUID
    var autor: String
    var fecha: Date
    var calificacion: Int // 1-5 estrellas
    var comentario: String

    init(id: UUID = UUID(), reptilId: UUID, autor: String, fecha: Date = Date(), calificacion: Int, comentario: String) {
        self.id = id
        self.reptilId = reptilId
        self.autor = autor
        self.fecha = fecha
        self.calificacion = calificacion
        self.comentario = comentario
    }
}

class OpinionesManager: ObservableObject {
    @Published var opiniones: [Opinion] = []

    init() {
        cargarOpiniones()
    }

    func cargarOpiniones() {
        if let data = UserDefaults.standard.data(forKey: "opiniones"),
           let loaded = try? JSONDecoder().decode([Opinion].self, from: data) {
            opiniones = loaded
        }
    }

    func guardarOpiniones() {
        if let data = try? JSONEncoder().encode(opiniones) {
            UserDefaults.standard.set(data, forKey: "opiniones")
        }
    }

    func agregar(_ opinion: Opinion) {
        opiniones.append(opinion)
        guardarOpiniones()
    }

    func opinionesPara(reptilId: UUID) -> [Opinion] {
        opiniones.filter { $0.reptilId == reptilId }
            .sorted { $0.fecha > $1.fecha }
    }

    func promedioCalificacion(reptilId: UUID) -> Double {
        let ops = opinionesPara(reptilId: reptilId)
        guard !ops.isEmpty else { return 0 }
        let suma = ops.reduce(0) { $0 + $1.calificacion }
        return Double(suma) / Double(ops.count)
    }
}

// OpinionesView acepta reptilId: UUID (llamada desde DetalleReptilView)
// También acepta reptil: Reptil para compatibilidad con NavigationLink existente
struct OpinionesView: View {
    let reptilId: UUID
    @StateObject private var manager = OpinionesManager()
    @ObservedObject private var prefs = UserPreferences.shared
    @State private var mostrarNuevaOpinion = false

    // Inicializador con Reptil
    init(reptil: Reptil) {
        self.reptilId = reptil.id
    }

    // Inicializador con UUID directo
    init(reptilId: UUID) {
        self.reptilId = reptilId
    }

    var opiniones: [Opinion] {
        manager.opinionesPara(reptilId: reptilId)
    }

    var promedio: Double {
        manager.promedioCalificacion(reptilId: reptilId)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Opiniones y Valoraciones")
                    .font(.title2)
                    .fontWeight(.bold)

                if !opiniones.isEmpty {
                    HStack(spacing: 8) {
                        Text(String(format: "%.1f", promedio))
                            .font(.system(size: 48, weight: .bold))

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: Double(index) < promedio ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                            Text("\(opiniones.count) opiniones")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Button {
                    mostrarNuevaOpinion = true
                } label: {
                    Label("Escribir opinión", systemImage: "square.and.pencil")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.4), in: Capsule())
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color(.systemGray6))

            if opiniones.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Aún no hay opiniones")
                        .font(.title3)
                    Text("Sé el primero en opinar")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(opiniones) { opinion in
                            OpinionCard(opinion: opinion)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Opiniones")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostrarNuevaOpinion) {
            NuevaOpinionView(reptilId: reptilId, manager: manager)
        }
    }
}

struct OpinionCard: View {
    let opinion: Opinion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(opinion.autor)
                        .font(.headline)

                    Text(opinion.fecha, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < opinion.calificacion ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }

            Text(opinion.comentario)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

struct NuevaOpinionView: View {
    let reptilId: UUID
    @ObservedObject var manager: OpinionesManager
    @ObservedObject private var prefs = UserPreferences.shared
    @Environment(\.dismiss) var dismiss

    @State private var calificacion = 5
    @State private var comentario = ""
    @State private var mostrarAlerta = false

    var body: some View {
        NavigationView {
            Form {
                Section("Calificación") {
                    HStack {
                        Text("Estrellas:")
                        Spacer()
                        ForEach(1...5, id: \.self) { num in
                            Button {
                                calificacion = num
                            } label: {
                                Image(systemName: num <= calificacion ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }

                Section("Comentario") {
                    TextEditor(text: $comentario)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Nueva Opinión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Publicar") {
                        guardarOpinion()
                    }
                }
            }
            .alert("Atención", isPresented: $mostrarAlerta) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Por favor, escribe un comentario")
            }
        }
    }

    func guardarOpinion() {
        guard !comentario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            mostrarAlerta = true
            return
        }

        let nueva = Opinion(
            reptilId: reptilId,
            autor: prefs.currentUsername.isEmpty ? "Usuario" : prefs.currentUsername,
            calificacion: calificacion,
            comentario: comentario
        )

        manager.agregar(nueva)
        dismiss()
    }
}
