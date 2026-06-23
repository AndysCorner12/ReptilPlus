//
//  UserPreferences.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import Foundation
import SwiftUI

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    // Usuario identificado
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentUserId") var currentUserId: String = ""
    
    // Último reptil visitado
    @AppStorage("lastVisitedReptilId") var lastVisitedReptilId: String = ""
    
    // Filtros
    @AppStorage("filterSexo") var filterSexo: String = ""
    @AppStorage("sortOrder") var sortOrder: String = "nombre" // nombre, fecha, peso
    
    // Favoritos (guardados como JSON string)
    @Published var favoritos: Set<UUID> = []
    
    private let favoritosKey = "favoritos"
    
    init() {
        loadFavoritos()
    }
    
    // MARK: - Favoritos
    
    func loadFavoritos() {
        if let data = UserDefaults.standard.data(forKey: favoritosKey),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            favoritos = Set(ids.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func saveFavoritos() {
        let ids = favoritos.map { $0.uuidString }
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: favoritosKey)
        }
    }
    
    func toggleFavorito(_ id: UUID) {
        if favoritos.contains(id) {
            favoritos.remove(id)
        } else {
            favoritos.insert(id)
        }
        saveFavoritos()
    }
    
    func esFavorito(_ id: UUID) -> Bool {
        favoritos.contains(id)
    }
    
    // MARK: - Login
    
    func login(username: String, userId: String) {
        isLoggedIn = true
        currentUsername = username
        currentUserId = userId
    }
    
    func logout() {
        isLoggedIn = false
        currentUsername = ""
        currentUserId = ""
        lastVisitedReptilId = ""
    }
    
    // MARK: - Último visitado
    
    func setLastVisited(_ reptilId: UUID) {
        lastVisitedReptilId = reptilId.uuidString
    }
    
    func getLastVisited() -> UUID? {
        UUID(uuidString: lastVisitedReptilId)
    }
}
