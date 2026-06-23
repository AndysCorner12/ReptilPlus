//  RemoteDataService.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.
//
//  Carga el catálogo de especies y reptiles desde URLs públicas de GitHub.
//  Si la red falla, usa los JSON del bundle como fallback.
//  Los reptiles añadidos por el usuario se gestionan por AppState/UserDefaults,
//  no desde aquí.

import Foundation

final class RemoteDataService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    // URLs públicas del catálogo (GitHub raw)
    private static let especiesURLString = "https://raw.githubusercontent.com/andreaguillen/reptilplus-data/main/especies.json"
    private static let reptilesURLString = "https://raw.githubusercontent.com/andreaguillen/reptilplus-data/main/reptiles.json"

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - async/await API (usada en MainTabsView.task)

    static func cargarEspecies() async -> [Especie] {
        if let data = await fetchData(from: especiesURLString),
           let wrapper = try? decoder.decode(EspeciesWrapper.self, from: data) {
            return wrapper.especies
        }
        return cargarEspeciesBundle()
    }

    static func cargarCatalogo() async -> [Reptil] {
        if let data = await fetchData(from: reptilesURLString),
           let wrapper = try? decoder.decode(ReptilesWrapper.self, from: data) {
            return wrapper.reptiles
        }
        return cargarReptilesBundle()
    }

    // MARK: - Callback API (usada en ReptilesListView botón recargar)

    func recargarDatos(completion: @escaping (Result<(especies: [Especie], reptiles: [Reptil]), Error>) -> Void) {
        isLoading = true
        errorMessage = nil

        Task {
            let especies = await Self.cargarEspecies()
            let reptiles = await Self.cargarCatalogo()

            await MainActor.run {
                self.isLoading = false
                if especies.isEmpty && reptiles.isEmpty {
                    let err = NSError(domain: "RemoteDataService", code: 0,
                                     userInfo: [NSLocalizedDescriptionKey: "No se pudieron cargar datos remotos."])
                    self.errorMessage = err.localizedDescription
                    completion(.failure(err))
                } else {
                    completion(.success((especies: especies, reptiles: reptiles)))
                }
            }
        }
    }

    // MARK: - Private helpers

    private static func fetchData(from urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 8)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        return data
    }

    private static func cargarEspeciesBundle() -> [Especie] {
        guard let url = Bundle.main.url(forResource: "especies", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wrapper = try? decoder.decode(EspeciesWrapper.self, from: data) else { return [] }
        return wrapper.especies
    }

    private static func cargarReptilesBundle() -> [Reptil] {
        guard let url = Bundle.main.url(forResource: "reptiles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wrapper = try? decoder.decode(ReptilesWrapper.self, from: data) else { return [] }
        return wrapper.reptiles
    }
}
