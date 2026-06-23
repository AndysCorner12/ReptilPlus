//
//  ReptilPlusApp.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

@main
struct ReptilPlusApp: App {
    @StateObject private var auth = AuthStore()
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(appState)
        }
    }
}
