//
//  WebView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI
import WebKit

final class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var progress: Double = 0
    @Published var isLoading: Bool = false
    
    func makeWebView() -> WKWebView {
        let wv = WKWebView()
        wv.navigationDelegate = self
        wv.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        return wv
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "estimatedProgress", let wv = object as? WKWebView else { return }
        DispatchQueue.main.async {
            self.progress = wv.estimatedProgress
            self.isLoading = wv.estimatedProgress < 1.0
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.progress = 1.0
        }
    }
    
    deinit {
        // Clean up observer
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var model: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let wv = model.makeWebView()
        wv.load(URLRequest(url: url))
        return wv
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
