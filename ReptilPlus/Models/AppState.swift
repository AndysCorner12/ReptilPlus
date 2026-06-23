//  AppState.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import Foundation

enum MainTab: String, Hashable {
    case inicio, reptiles, cuidados, estadisticas, perfil
}

final class AppState: ObservableObject {
    @Published var selectedTab: MainTab = .inicio
    @Published var coleccion = ColeccionReptiles()
    @Published var focusedReptilId: UUID? = nil

    private let reptilesPersistKey = "coleccionReptiles"

    // MARK: - Persistence

    /// Guarda los reptiles del usuario en UserDefaults
    func guardarReptiles() {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        if let data = try? enc.encode(coleccion.reptiles) {
            UserDefaults.standard.set(data, forKey: reptilesPersistKey)
        }
    }

    /// Recupera los reptiles guardados en UserDefaults
    func cargarReptiles() {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        if let data = UserDefaults.standard.data(forKey: reptilesPersistKey),
           let reptiles = try? dec.decode([Reptil].self, from: data) {
            // Añadir sin duplicar
            for r in reptiles {
                if coleccion.obtener(id: r.id) == nil {
                    coleccion.agregar(r)
                }
            }
        }
    }

    // MARK: - Helpers

    func reptilPorId(_ id: UUID) -> Reptil? {
        coleccion.obtener(id: id)
    }

    func especiePara(_ reptil: Reptil) -> Especie? {
        coleccion.especiePara(id: reptil.especieId)
    }
}
