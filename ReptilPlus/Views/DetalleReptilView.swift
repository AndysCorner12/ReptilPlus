//  DetalleReptilView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct DetalleReptilView: View {
    let reptil: Reptil
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared
    @State private var tabSeleccionado = 0
    @State private var mostrarMapaSheet = false
    @State private var mostrarEditarEstado = false
    @State private var reptilMutable: Reptil

    var especie: Especie? { appState.especiePara(reptilMutable) }
    var esFavorito: Bool { prefs.esFavorito(reptilMutable.id) }

    init(reptil: Reptil) {
        self.reptil = reptil
        self._reptilMutable = State(initialValue: reptil)
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Hero header ───────────────────────────────────────────
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [colorParaEstado(reptilMutable.estado).opacity(0.25),
                             Color(.systemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 160)

                Image(systemName: "lizard.fill")
                    .font(.system(size: 80))
                    .foregroundColor(colorParaEstado(reptilMutable.estado).opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                Button {
                    prefs.toggleFavorito(reptilMutable.id)
                } label: {
                    Image(systemName: esFavorito ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(esFavorito ? .yellow : .white)
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                .padding()
            }

            // ── Nombre + especie ──────────────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reptilMutable.nombre)
                        .font(.title2).bold()
                    if let e = especie {
                        Text(e.nombreCientifico)
                            .font(.caption).italic().foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button { mostrarEditarEstado = true } label: {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colorParaEstado(reptilMutable.estado))
                            .frame(width: 10, height: 10)
                        Text(reptilMutable.estado.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(colorParaEstado(reptilMutable.estado).opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal).padding(.vertical, 8)

            // ── Tabs (segmented) ──────────────────────────────────────
            Picker("Sección", selection: $tabSeleccionado) {
                Text("Info").tag(0)
                Text("Especie").tag(1)
                Text("Opiniones").tag(2)
                Text("Mapa").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal).padding(.bottom, 8)

            Divider()

            // ── Contenido de cada tab ─────────────────────────────────
            ScrollView {
                Group {
                    if tabSeleccionado == 0 {
                        infoTab
                    } else if tabSeleccionado == 1 {
                        especieTab
                    } else if tabSeleccionado == 2 {
                        opinionesTab
                    } else {
                        mapaTab
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            prefs.setLastVisited(reptilMutable.id)
            prefs.lastVisitedReptilId = reptilMutable.id.uuidString
        }
        .sheet(isPresented: $mostrarEditarEstado, onDismiss: { appState.guardarReptiles() }) {
            EditarEstadoView(reptil: $reptilMutable)
        }
        .sheet(isPresented: $mostrarMapaSheet) {
            NavigationView {
                MapaView()
                    .navigationTitle("Ubicación")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cerrar") { mostrarMapaSheet = false }
                        }
                    }
            }
        }
    }

    // MARK: - Tab: Info

    private var infoTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Estrellas salud
            HStack(spacing: 4) {
                ForEach(0..<5) { i in
                    Image(systemName: i < estrellasParaSalud(reptilMutable.estado) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
                Text(reptilMutable.estado.rawValue)
                    .font(.subheadline)
                    .foregroundColor(colorParaEstado(reptilMutable.estado))
                    .padding(.leading, 6)
            }
            .padding()

            Divider()

            infoFila(icono: "circle.fill", label: "Sexo",
                     valor: reptilMutable.sexo.rawValue.capitalized, color: .blue)
            infoFila(icono: "scalemass", label: "Peso",
                     valor: String(format: "%.1f g", reptilMutable.pesoActual))
            infoFila(icono: "ruler", label: "Longitud",
                     valor: String(format: "%.1f cm", reptilMutable.longitudActual))

            if let fn = reptilMutable.fechaNacimiento {
                infoFila(icono: "calendar", label: "Nacimiento",
                         valor: fechaFormateada(fn))
            }

            if let notas = reptilMutable.notas, !notas.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Notas", systemImage: "note.text")
                        .font(.caption).foregroundColor(.secondary)
                    Text(notas).font(.body)
                }
                .padding()
                Divider()
            }

            // Botón editar estado
            Button { mostrarEditarEstado = true } label: {
                Label("Editar estado y medidas", systemImage: "pencil.circle")
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.purple, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
            }
            .padding()
        }
    }

    // MARK: - Tab: Especie

    private var especieTab: some View {
        Group {
            if let e = especie {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(e.nombreComun).font(.title3).bold()
                        Text(e.nombreCientifico).font(.subheadline).italic().foregroundColor(.secondary)
                        if let f = e.familia {
                            Text("Familia: \(f)").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    Divider()

                    if let t = e.tamanoPromedio {
                        infoFila(icono: "ruler", label: "Tamaño promedio",
                                 valor: String(format: "%.0f cm", t))
                    }
                    if let ev = e.esperanzaVida {
                        infoFila(icono: "heart", label: "Esperanza de vida",
                                 valor: "\(ev) años")
                    }

                    if !e.descripcion.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Descripción", systemImage: "text.alignleft")
                                .font(.caption).foregroundColor(.secondary)
                            Text(e.descripcion).font(.body)
                        }
                        .padding()
                        Divider()
                    }

                    // Botón Wikipedia
                    NavigationLink(destination: especieWebDestination()) {
                        Label("Ver en Wikipedia", systemImage: "globe")
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }
                    .padding()

                    // Botón ficha especie
                    NavigationLink(destination: EspecieDetailView(especie: e)) {
                        Label("Ficha completa de la especie", systemImage: "doc.text")
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.green, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal).padding(.bottom)
                }
            } else {
                Text("Información de especie no disponible")
                    .foregroundColor(.secondary).padding()
            }
        }
    }

    // MARK: - Tab: Opiniones

    private var opinionesTab: some View {
        // Use NavigationLink to avoid nested ScrollViews
        NavigationLink(destination: OpinionesView(reptilId: reptilMutable.id)) {
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                    .padding(.top, 32)
                Text("Ver opiniones y valoraciones")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Toca para ver y añadir opiniones")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }

    // MARK: - Tab: Mapa

    private var mapaTab: some View {
        VStack(spacing: 16) {
            MapaView()
                .frame(height: 300)
                .cornerRadius(12)
                .padding()
                .onAppear { appState.focusedReptilId = reptilMutable.id }

            Button {
                appState.focusedReptilId = reptilMutable.id
                mostrarMapaSheet = true
            } label: {
                Label("Ver mapa en pantalla completa", systemImage: "arrow.up.left.and.arrow.down.right")
                    .frame(maxWidth: .infinity).padding()
                    .background(Color(red: 0.2, green: 0.6, blue: 0.4),
                                in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Helpers

    private func infoFila(icono: String, label: String, valor: String, color: Color = .blue) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icono).foregroundColor(color).frame(width: 24)
                Text(label).foregroundColor(.secondary)
                Spacer()
                Text(valor).bold()
            }
            .padding(.horizontal).padding(.vertical, 10)
            .background(Color(.systemBackground))
            Divider().padding(.leading, 52)
        }
    }

    private func fechaFormateada(_ fecha: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: fecha)
    }

    private func especieWebDestination() -> some View {
        if let e = especie {
            let nombre = e.nombreCientifico.replacingOccurrences(of: " ", with: "_")
            if let url = URL(string: "https://es.wikipedia.org/wiki/\(nombre)") {
                return AnyView(EspecieWebView(url: url))
            }
        }
        return AnyView(Text("URL no disponible").padding())
    }

    private func colorParaEstado(_ estado: EstadoSalud) -> Color {
        switch estado {
        case .saludable: return .green
        case .observacion: return .yellow
        case .enfermo: return .orange
        case .critico: return .red
        }
    }

    private func estrellasParaSalud(_ estado: EstadoSalud) -> Int {
        switch estado {
        case .saludable: return 5
        case .observacion: return 4
        case .enfermo: return 3
        case .critico: return 2
        }
    }
}

// Kept here to avoid breaking EspecieDetailView which uses these
struct DetalleSeccion<Content: View>: View {
    let titulo: String
    let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titulo).font(.headline)
            content()
        }
    }
}

struct InfoRow: View {
    let label: String; let value: String; let icono: String
    var color: Color = .blue
    var body: some View {
        HStack {
            Image(systemName: icono).foregroundColor(color).frame(width: 24)
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).bold()
        }
        .padding(.vertical, 4)
    }
}
