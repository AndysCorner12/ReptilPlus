//  PerfilView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct PerfilView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared
    @State private var mostrarConfirmacion = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Avatar ───────────────────────────────────────────
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.15))
                            .frame(width: 100, height: 100)
                        Text(iniciales)
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                    }
                    if let u = auth.usuarioActual {
                        Text(u.nombre).font(.title2).bold()
                        Text("@\(u.username)").font(.subheadline).foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)

                // ── Datos del usuario ─────────────────────────────────
                if let u = auth.usuarioActual {
                    VStack(spacing: 0) {
                        PerfilFila(icono: "envelope.fill", titulo: "Email", valor: u.email)
                        Divider().padding(.leading, 52)
                        PerfilFila(icono: "phone.fill", titulo: "Teléfono",
                                   valor: u.telefono.isEmpty ? "No indicado" : u.telefono)
                        Divider().padding(.leading, 52)
                        PerfilFila(icono: "calendar", titulo: "Miembro desde",
                                   valor: fechaFormateada(u.createdAt))
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                }

                // ── Estadísticas del usuario ──────────────────────────
                VStack(spacing: 0) {
                    HStack {
                        StatFila(icono: "lizard.fill", titulo: "Mis reptiles",
                                 valor: "\(appState.coleccion.cantidad)", color: .green)
                        Divider()
                        StatFila(icono: "star.fill", titulo: "Favoritos",
                                 valor: "\(prefs.favoritos.count)", color: .yellow)
                        Divider()
                        StatFila(icono: "leaf.fill", titulo: "Especies",
                                 valor: "\(appState.coleccion.especies.count)", color: .blue)
                    }
                    .frame(height: 80)
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)
                .padding(.horizontal)

                // ── Cerrar sesión ─────────────────────────────────────
                Button {
                    mostrarConfirmacion = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar sesión")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .alert("¿Cerrar sesión?", isPresented: $mostrarConfirmacion) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar sesión", role: .destructive) {
                prefs.logout()
                auth.logout()
            }
        } message: {
            Text("Se cerrará tu sesión actual.")
        }
    }

    var iniciales: String {
        guard let nombre = auth.usuarioActual?.nombre else { return "?" }
        return nombre.split(separator: " ").prefix(2)
            .compactMap { $0.first }.map { String($0) }.joined().uppercased()
    }

    func fechaFormateada(_ fecha: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: fecha)
    }
}

// MARK: - Subvistas

struct PerfilFila: View {
    let icono: String; let titulo: String; let valor: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icono)
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).font(.caption).foregroundColor(.secondary)
                Text(valor).font(.subheadline)
            }
            Spacer()
        }
        .padding(.horizontal).padding(.vertical, 12)
    }
}

struct StatFila: View {
    let icono: String; let titulo: String; let valor: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icono).foregroundColor(color)
            Text(valor).font(.title2).bold()
            Text(titulo).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
