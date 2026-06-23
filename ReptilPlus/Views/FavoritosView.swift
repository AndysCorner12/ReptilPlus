//
//  FavoritosView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct FavoritosView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared

    var reptilesFavoritos: [Reptil] {
        appState.coleccion.reptiles.filter { prefs.esFavorito($0.id) }
    }

    var body: some View {
        VStack {
            if reptilesFavoritos.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No tienes favoritos")
                        .font(.title2)
                    Text("Marca reptiles como favoritos para verlos aquí")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List(reptilesFavoritos) { reptil in
                    NavigationLink(destination: DetalleReptilView(reptil: reptil)) {
                        ReptilCustomRow(
                            reptil: reptil,
                            especie: appState.especiePara(reptil)
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favoritos")
    }
}
