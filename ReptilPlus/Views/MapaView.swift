//
//  MapaView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI
import MapKit

struct MapaView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.0500, longitude: -1.2133),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var reptilesConUbicacion: [Reptil] {
        appState.coleccion.reptiles
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if !reptilesConUbicacion.isEmpty {
                HStack {
                    Menu {
                        Button("Todos") {
                            appState.focusedReptilId = nil
                            centrarTodos()
                        }
                        ForEach(reptilesConUbicacion) { reptil in
                            Button(reptil.nombre) {
                                appState.focusedReptilId = reptil.id
                                centrarEn(reptil)
                            }
                        }
                    } label: {
                        Label(
                            appState.focusedReptilId.flatMap { appState.reptilPorId($0)?.nombre } ?? "Seleccionar",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                        .padding(8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    
                    Spacer()
                }
                .padding([.horizontal, .top])
                
                Map(coordinateRegion: $region, annotationItems: reptilesConUbicacion) { reptil in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: 38.0500 + Double.random(in: -0.01...0.01),
                                                                       longitude: -1.2133 + Double.random(in: -0.01...0.01))) {
                        Button {
                            appState.focusedReptilId = reptil.id
                            centrarEn(reptil)
                        } label: {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(colorParaEstado(reptil.estado))
                                Text(reptil.nombre)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(4)
                                    .background(Color.white.opacity(0.9), in: Capsule())
                            }
                        }
                    }
                }
                .onAppear {
                    if let rid = appState.focusedReptilId,
                       let r = appState.reptilPorId(rid) {
                        centrarEn(r)
                    } else {
                        centrarTodos()
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "map")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No hay ubicaciones")
                        .font(.title2)
                    Text("Los terrarios de tus reptiles aparecerán aquí")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
    
    func centrarEn(_ reptil: Reptil) {
        region.center = CLLocationCoordinate2D(
            latitude: 38.0500 + Double.random(in: -0.01...0.01),
            longitude: -1.2133 + Double.random(in: -0.01...0.01)
        )
        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    
    func centrarTodos() {
        region.center = CLLocationCoordinate2D(latitude: 38.0500, longitude: -1.2133)
        region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    }
    
    func colorParaEstado(_ estado: EstadoSalud) -> Color {
        switch estado {
        case .saludable: return .green
        case .observacion: return .yellow
        case .enfermo: return .orange
        case .critico: return .red
        }
    }
}
