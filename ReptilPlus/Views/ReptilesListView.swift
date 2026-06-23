//  ReptilesListView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct ReptilesListView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared
    @StateObject private var remoteService = RemoteDataService()
    @State private var busqueda = ""
    @State private var filtroSexo: SexoReptil? = nil
    @State private var filtroEstado: EstadoSalud? = nil
    @State private var ordenamiento: String = "nombre"
    @State private var showPager = false
    @State private var showNuevoReptil = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var reptilesFiltered: [Reptil] {
        var reptiles = appState.coleccion.reptiles

        if !busqueda.isEmpty {
            reptiles = reptiles.filter {
                $0.nombre.localizedCaseInsensitiveContains(busqueda)
                || (appState.especiePara($0)?.nombreComun.localizedCaseInsensitiveContains(busqueda) ?? false)
            }
        }
        if let sexo = filtroSexo {
            reptiles = reptiles.filter { $0.sexo == sexo }
        }
        if let estado = filtroEstado {
            reptiles = reptiles.filter { $0.estado == estado }
        }
        switch ordenamiento {
        case "peso":   reptiles.sort { $0.pesoActual > $1.pesoActual }
        case "fecha":  reptiles.sort { ($0.fechaNacimiento ?? .distantPast) > ($1.fechaNacimiento ?? .distantPast) }
        default:       reptiles.sort { $0.nombre < $1.nombre }
        }
        return reptiles
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Barra de filtros ──────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Filtro sexo
                    Menu {
                        Button("Todos") { filtroSexo = nil }
                        ForEach(SexoReptil.allCases, id: \.self) { s in
                            Button(s.rawValue.capitalized) { filtroSexo = s }
                        }
                    } label: {
                        Label(filtroSexo?.rawValue.capitalized ?? "Sexo",
                              systemImage: "person.fill")
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    // Filtro estado
                    Menu {
                        Button("Todos") { filtroEstado = nil }
                        ForEach(EstadoSalud.allCases, id: \.self) { e in
                            Button(e.rawValue) { filtroEstado = e }
                        }
                    } label: {
                        Label(filtroEstado?.rawValue ?? "Estado",
                              systemImage: "heart.fill")
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    // Ordenar
                    Menu {
                        Button("Por nombre") { ordenamiento = "nombre" }
                        Button("Por peso") { ordenamiento = "peso" }
                        Button("Por fecha nacimiento") { ordenamiento = "fecha" }
                    } label: {
                        Label("Ordenar", systemImage: "arrow.up.arrow.down")
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    // Botón recargar datos remotos
                    Button {
                        recargarDatos()
                    } label: {
                        HStack(spacing: 4) {
                            if remoteService.isLoading {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Recargar")
                                .font(.caption)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .disabled(remoteService.isLoading)

                    // Vista Pager
                    Button { showPager = true } label: {
                        Label("Deslizar", systemImage: "arrow.left.and.right")
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // ── Contador ──────────────────────────────────────────────────
            HStack {
                Text("\(reptilesFiltered.count) reptiles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
            }

            // ── Lista ─────────────────────────────────────────────────────
            if appState.coleccion.cantidad == 0 {
                Spacer()
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Aún no tienes reptiles")
                        .font(.title2)
                    Text("Toca + para añadir tu primer reptil")
                        .foregroundColor(.secondary)
                    Button {
                        showNuevoReptil = true
                    } label: {
                        Label("Añadir Reptil", systemImage: "plus.circle.fill")
                            .padding()
                            .background(Color(red: 0.2, green: 0.6, blue: 0.4), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            } else if reptilesFiltered.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Sin resultados")
                        .font(.title3)
                    Text("Prueba con otro filtro o búsqueda.")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(reptilesFiltered) { reptil in
                        NavigationLink(destination: DetalleReptilView(reptil: reptil)) {
                            ReptilCustomRow(
                                reptil: reptil,
                                especie: appState.especiePara(reptil)
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                eliminar(reptil)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $busqueda, prompt: "Buscar reptil o especie...")
                .refreshable { recargarDatos() }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showNuevoReptil = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                }
            }
        }
        .sheet(isPresented: $showPager) {
            NavigationView {
                ReptilesPagerView(reptiles: reptilesFiltered)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cerrar") { showPager = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showNuevoReptil) {
            NuevoReptilView()
        }
        .alert("Datos remotos", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func recargarDatos() {
        remoteService.recargarDatos { result in
            switch result {
            case .success(let data):
                appState.coleccion.especies = data.especies
                for reptil in data.reptiles {
                    if appState.coleccion.obtener(id: reptil.id) == nil {
                        appState.coleccion.agregar(reptil)
                    }
                }
                appState.guardarReptiles()
                alertMessage = "Actualizados: \(data.especies.count) especies, \(data.reptiles.count) reptiles en catálogo."
                showAlert = true
            case .failure:
                alertMessage = "Sin conexión. Usando datos locales."
                showAlert = true
            }
        }
    }

    private func eliminar(_ reptil: Reptil) {
        appState.coleccion.eliminar(id: reptil.id)
        appState.guardarReptiles()
    }
}
