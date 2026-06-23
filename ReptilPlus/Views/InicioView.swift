//  InicioView.swift
//  ReptilPlus
//  Created by Andrea Guillen on 16/1/26.

import SwiftUI

struct InicioView: View {
    @EnvironmentObject var auth: AuthStore
    @EnvironmentObject var appState: AppState
    @ObservedObject private var prefs = UserPreferences.shared

    var reptilesEnfermos: [Reptil] {
        appState.coleccion.reptiles.filter { $0.estado == .enfermo || $0.estado == .critico }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Header ─────────────────────────────────────────────
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hola, \(auth.usuarioActual?.nombre.components(separatedBy: " ").first ?? "usuario") 👋")
                            .font(.title2)
                            .bold()
                        Text(fechaHoy())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    NavigationLink(destination: PerfilView()) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.15))
                                .frame(width: 44, height: 44)
                            Text(iniciales)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // ── Alertas de salud ───────────────────────────────────
                if !reptilesEnfermos.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Atención requerida", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.horizontal)
                        ForEach(reptilesEnfermos) { reptil in
                            NavigationLink(destination: DetalleReptilView(reptil: reptil)) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.white)
                                    Text("\(reptil.nombre) - \(reptil.estado.rawValue)")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                                .background(reptil.estado == .critico ? Color.red : Color.orange,
                                            in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // ── Cards resumen ──────────────────────────────────────
                HStack(spacing: 12) {
                    ResumenCard(icono: "lizard.fill",
                                valor: "\(appState.coleccion.cantidad)",
                                titulo: "Reptiles", color: .green)
                    ResumenCard(icono: "leaf.fill",
                                valor: "\(appState.coleccion.especies.count)",
                                titulo: "Especies", color: .blue)
                    ResumenCard(icono: "star.fill",
                                valor: "\(prefs.favoritos.count)",
                                titulo: "Favoritos", color: .yellow)
                }
                .padding(.horizontal)

                // ── Mis reptiles ───────────────────────────────────────
                if appState.coleccion.cantidad > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mis reptiles")
                                .font(.title3).bold()
                            Spacer()
                            Button {
                                appState.selectedTab = .reptiles
                            } label: {
                                Text("Ver todos")
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                            }
                        }
                        .padding(.horizontal)
                        ForEach(appState.coleccion.ordenadosPorNombre().prefix(3)) { reptil in
                            NavigationLink(destination: DetalleReptilView(reptil: reptil)) {
                                ReptilCustomRow(reptil: reptil, especie: appState.especiePara(reptil))
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "lizard")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Aún no tienes reptiles")
                            .font(.headline).foregroundColor(.secondary)
                        Button {
                            appState.selectedTab = .reptiles
                        } label: {
                            Label("Añadir reptil", systemImage: "plus.circle.fill")
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Color(red: 0.2, green: 0.6, blue: 0.4), in: Capsule())
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }

                // ── Accesos rápidos ────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accesos rápidos")
                        .font(.title3).bold()
                        .padding(.horizontal)
                    HStack(spacing: 12) {
                        AccesoRapido(icono: "heart.text.square.fill", titulo: "Cuidados", color: .pink) {
                            appState.selectedTab = .cuidados
                        }
                        AccesoRapido(icono: "star.fill", titulo: "Favoritos", color: .yellow) {
                            // Navegar al tab de reptiles y filtrar favoritos
                            appState.selectedTab = .reptiles
                        }
                        AccesoRapido(icono: "chart.bar.fill", titulo: "Stats", color: .purple) {
                            appState.selectedTab = .estadisticas
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
    }

    var iniciales: String {
        guard let nombre = auth.usuarioActual?.nombre else { return "?" }
        return nombre.split(separator: " ").prefix(2)
            .compactMap { $0.first }.map { String($0) }.joined().uppercased()
    }

    func fechaHoy() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM"
        f.locale = Locale(identifier: "es_ES")
        return f.string(from: Date()).capitalized
    }
}

// MARK: - Subvistas auxiliares

struct ResumenCard: View {
    let icono: String; let valor: String; let titulo: String; let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icono).font(.system(size: 22)).foregroundColor(color)
            Text(valor).font(.title2).bold()
            Text(titulo).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct AccesoRapido: View {
    let icono: String; let titulo: String; let color: Color; let accion: () -> Void
    var body: some View {
        Button(action: accion) {
            VStack(spacing: 8) {
                Image(systemName: icono).font(.system(size: 26)).foregroundColor(color)
                Text(titulo).font(.caption).foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct EstadisticaCard: View {
    let icono: String; let valor: String; let titulo: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icono).font(.system(size: 30)).foregroundColor(color)
            Text(valor).font(.title).bold()
            Text(titulo).font(.subheadline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding()
        .background(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ReptilRowView: View {
    let reptil: Reptil
    @EnvironmentObject var appState: AppState

    func colorParaEstado(_ estado: EstadoSalud) -> Color {
        switch estado {
        case .saludable: return .green
        case .observacion: return .yellow
        case .enfermo: return .orange
        case .critico: return .red
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "lizard.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(colorParaEstado(reptil.estado))
            VStack(alignment: .leading, spacing: 4) {
                Text(reptil.nombre).font(.headline)
                if let especie = appState.especiePara(reptil) {
                    Text(especie.nombreComun).font(.subheadline).foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
        .padding(.horizontal)
    }
}
