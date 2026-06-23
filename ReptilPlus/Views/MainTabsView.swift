//  MainTabsView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct MainTabsView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared
    @State private var showAcercaDe = false
    @State private var isLoadingRemote = false

    var body: some View {
        TabView(selection: $appState.selectedTab) {

            NavigationView {
                InicioView()
                    .navigationTitle("Inicio")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button { showAcercaDe = true } label: {
                                Image(systemName: "info.circle")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if isLoadingRemote {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }
            .tag(MainTab.inicio)

            NavigationView {
                ReptilesListView()
                    .navigationTitle("Mis Reptiles")
            }
            .tabItem { Label("Reptiles", systemImage: "lizard.fill") }
            .tag(MainTab.reptiles)

            NavigationView {
                CuidadosView()
                    .navigationTitle("Cuidados")
            }
            .tabItem { Label("Cuidados", systemImage: "heart.text.square.fill") }
            .tag(MainTab.cuidados)

            NavigationView {
                EstadisticasView()
                    .navigationTitle("Estadísticas")
            }
            .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            .tag(MainTab.estadisticas)

            NavigationView {
                PerfilView()
                    .navigationTitle("Mi Perfil")
            }
            .tabItem { Label("Perfil", systemImage: "person.fill") }
            .tag(MainTab.perfil)
        }
        .sheet(isPresented: $showAcercaDe) {
            AcercaDeView()
        }
        .task {
            await cargarDatosIniciales()
        }
    }

    // MARK: - Carga de datos al inicio (remoto → bundle → UserDefaults)

    private func cargarDatosIniciales() async {
        isLoadingRemote = true

        // 1. Cargar especies desde URL remota con fallback a bundle
        let especiesRemote = await RemoteDataService.cargarEspecies()
        await MainActor.run {
            if !especiesRemote.isEmpty {
                appState.coleccion.especies = especiesRemote
            } else {
                // fallback ya gestionado dentro de RemoteDataService, pero también intentamos bundle aquí
                if appState.coleccion.especies.isEmpty {
                    cargarEspeciesBundle()
                }
            }
        }

        // 2. Cargar reptiles guardados por el usuario (UserDefaults)
        await MainActor.run {
            appState.cargarReptiles()
        }

        // 3. Si no hay reptiles del usuario, cargar catálogo (remoto → bundle), sin duplicar
        if await MainActor.run(body: { appState.coleccion.reptiles.isEmpty }) {
            let catalogoRemote = await RemoteDataService.cargarCatalogo()
            await MainActor.run {
                for reptil in catalogoRemote {
                    if appState.coleccion.obtener(id: reptil.id) == nil {
                        appState.coleccion.agregar(reptil)
                    }
                }
                appState.guardarReptiles()
            }
        }

        // 4. Restaurar último reptil visitado
        await MainActor.run {
            if let lastId = prefs.getLastVisited(),
               appState.coleccion.obtener(id: lastId) != nil {
                appState.focusedReptilId = lastId
            }
            isLoadingRemote = false
        }
    }

    private func cargarEspeciesBundle() {
        if let url = Bundle.main.url(forResource: "especies", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let wrapper = try? decoder.decode(EspeciesWrapper.self, from: data) {
                appState.coleccion.especies = wrapper.especies
            }
        }
    }
}
