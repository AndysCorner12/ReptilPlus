//
//  CuidadosView.swift
//  ReptilPlus
//

import SwiftUI

// MARK: - Modelo de tarea real con persistencia

struct TareaReal: Identifiable, Codable {
    let id: UUID
    var reptilId: UUID
    var tipo: String
    var descripcion: String
    var completada: Bool
    var fecha: Date
    var icono: String
    var prioridadRaw: String

    init(id: UUID = UUID(), reptilId: UUID, tipo: String, descripcion: String,
         icono: String, prioridad: String, fecha: Date = Date()) {
        self.id = id
        self.reptilId = reptilId
        self.tipo = tipo
        self.descripcion = descripcion
        self.completada = false
        self.fecha = fecha
        self.icono = icono
        self.prioridadRaw = prioridad
    }

    var colorPrioridad: Color {
        switch prioridadRaw {
        case "alta": return .red
        case "media": return .orange
        default: return .green
        }
    }
}

class TareasManager: ObservableObject {
    @Published var tareas: [TareaReal] = []
    private let key = "tareasReptiles"

    init() { cargar() }

    func cargar() {
        if let data = UserDefaults.standard.data(forKey: key),
           let t = try? JSONDecoder().decode([TareaReal].self, from: data) {
            tareas = t
        }
    }

    func guardar() {
        if let data = try? JSONEncoder().encode(tareas) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func agregarTareasIniciales(para reptil: Reptil) {
        guard !tareas.contains(where: { $0.reptilId == reptil.id }) else { return }
        let nuevas: [TareaReal] = [
            TareaReal(reptilId: reptil.id, tipo: "Alimentación",
                      descripcion: "Dar de comer según dieta de su especie",
                      icono: "fork.knife", prioridad: "alta"),
            TareaReal(reptilId: reptil.id, tipo: "Agua",
                      descripcion: "Cambiar y limpiar el agua",
                      icono: "drop.fill", prioridad: "alta"),
            TareaReal(reptilId: reptil.id, tipo: "Temperatura",
                      descripcion: "Verificar temperatura del terrario",
                      icono: "thermometer", prioridad: "media"),
            TareaReal(reptilId: reptil.id, tipo: "Limpieza",
                      descripcion: "Limpiar el terrario",
                      icono: "sparkles", prioridad: "media"),
            TareaReal(reptilId: reptil.id, tipo: "Pesaje",
                      descripcion: "Pesar y registrar el peso",
                      icono: "scalemass", prioridad: "baja"),
        ]
        tareas.append(contentsOf: nuevas)
        guardar()
    }

    func toggleCompletada(_ tarea: TareaReal) {
        if let i = tareas.firstIndex(where: { $0.id == tarea.id }) {
            tareas[i].completada.toggle()
            guardar()
        }
    }

    func resetearTareas(reptilId: UUID) {
        for i in tareas.indices where tareas[i].reptilId == reptilId {
            tareas[i].completada = false
        }
        guardar()
    }

    func tareasPara(_ reptilId: UUID) -> [TareaReal] {
        tareas.filter { $0.reptilId == reptilId }
    }

    func pendientesPara(_ reptilId: UUID) -> Int {
        tareasPara(reptilId).filter { !$0.completada }.count
    }
}

// MARK: - Vista principal

struct CuidadosView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var manager = TareasManager()
    @State private var reptilSeleccionado: Reptil? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if appState.coleccion.cantidad == 0 {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No hay reptiles")
                            .font(.title2)
                        Text("Añade reptiles para gestionar sus cuidados")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    Text("Tareas de hoy")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top, 8)

                    ForEach(appState.coleccion.reptiles) { reptil in
                        ReptilCuidadosCard(
                            reptil: reptil,
                            manager: manager,
                            seleccionado: reptilSeleccionado?.id == reptil.id,
                            onToggle: {
                                reptilSeleccionado = reptilSeleccionado?.id == reptil.id ? nil : reptil
                            }
                        )
                        .onAppear { manager.agregarTareasIniciales(para: reptil) }
                    }
                }
            }
            .padding(.bottom, 20)
        }

    }
}

// MARK: - Card por reptil

struct ReptilCuidadosCard: View {
    let reptil: Reptil
    @ObservedObject var manager: TareasManager
    let seleccionado: Bool
    let onToggle: () -> Void

    var tareas: [TareaReal] { manager.tareasPara(reptil.id) }
    var pendientes: Int { manager.pendientesPara(reptil.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: "lizard.fill")
                        .foregroundColor(colorEstado(reptil.estado))
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reptil.nombre)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(pendientes) tarea\(pendientes == 1 ? "" : "s") pendiente\(pendientes == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(pendientes > 0 ? .orange : .green)
                    }
                    Spacer()
                    Image(systemName: seleccionado ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            if seleccionado {
                Divider()
                ForEach(tareas) { tarea in
                    TareaRealRow(tarea: tarea) {
                        manager.toggleCompletada(tarea)
                    }
                    if tarea.id != tareas.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
                Button {
                    manager.resetearTareas(reptilId: reptil.id)
                } label: {
                    Label("Reiniciar tareas", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
        .padding(.horizontal)
    }

    func colorEstado(_ estado: EstadoSalud) -> Color {
        switch estado {
        case .saludable: return .green
        case .observacion: return .yellow
        case .enfermo: return .orange
        case .critico: return .red
        }
    }
}

// MARK: - Fila de tarea

struct TareaRealRow: View {
    let tarea: TareaReal
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: tarea.completada ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(tarea.completada ? .green : tarea.colorPrioridad)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tarea.tipo)
                    .font(.subheadline)
                    .bold()
                    .strikethrough(tarea.completada)
                    .foregroundColor(tarea.completada ? .secondary : .primary)
                Text(tarea.descripcion)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Circle()
                .fill(tarea.colorPrioridad)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(tarea.completada ? Color(.systemGray6).opacity(0.5) : Color.clear)
    }
}
