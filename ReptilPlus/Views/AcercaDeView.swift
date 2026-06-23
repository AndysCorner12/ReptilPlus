//
//  AcercaDeView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct AcercaDeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 40)
                    
                    // Nombre de la app
                    Text("Reptil Plus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Versión 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Autoría
                    VStack(spacing: 16) {
                        Text("Desarrollado por")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            Text("Andrea Guillén Fernández-Santamaría")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("Universidad Católica de Murcia (UCAM)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Grado en Ingeniería Informática")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Asignatura: Desarrollo iOS")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Enero 2026")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Descripción
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Acerca de la App")
                            .font(.headline)
                        
                        Text("Reptil Plus es una aplicación completa para la gestión y cuidado de reptiles. Permite llevar un registro detallado de cada reptil, monitorear su salud, gestionar tareas de cuidado y mucho más.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Características
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Características")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "lizard.fill", text: "Gestión de reptiles")
                            FeatureRow(icon: "heart.text.square.fill", text: "Sistema de cuidados")
                            FeatureRow(icon: "map.fill", text: "Ubicación de terrarios")
                            FeatureRow(icon: "globe", text: "Información en línea")
                            FeatureRow(icon: "star.fill", text: "Sistema de favoritos")
                            FeatureRow(icon: "chart.bar.fill", text: "Estadísticas")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Tecnologías
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tecnologías")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TechRow(name: "SwiftUI", description: "Framework de interfaz")
                            TechRow(name: "MapKit", description: "Mapas y ubicaciones")
                            TechRow(name: "WebKit", description: "Navegación web")
                            TechRow(name: "UserDefaults", description: "Persistencia local")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Copyright
                    VStack(spacing: 4) {
                        Text("© 2026 Andrea Guillén")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Todos los derechos reservados")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct TechRow: View {
    let name: String
    let description: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
