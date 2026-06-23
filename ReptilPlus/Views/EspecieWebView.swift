//
//  EspecieWebView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct EspecieWebView: View {
    let url: URL
    @StateObject private var vm = WebViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                HStack {
                    ProgressView(value: vm.progress)
                    Text("\(Int(vm.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            WebView(url: url, model: vm)
        }
        .navigationTitle("Información")
        .navigationBarTitleDisplayMode(.inline)
    }
}
