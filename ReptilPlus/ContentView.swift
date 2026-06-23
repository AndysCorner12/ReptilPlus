//
//  ContentView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared
    
    var body: some View {
        Group {
            if prefs.isLoggedIn {
                MainTabsView()
            } else {
                NavigationView {
                    LoginView()
                }
            }
        }
        .onAppear {
            // Auto-login si hay usuario guardado
            if prefs.isLoggedIn && !prefs.currentUsername.isEmpty {
                // Buscar usuario en AuthStore
                if let usuario = auth.usuarios.first(where: { $0.username == prefs.currentUsername }) {
                    auth.usuarioActual = usuario
                }
            }
        }
    }
}
