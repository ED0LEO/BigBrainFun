//
//  VideoPlayerView.swift
//  BigBrainFun
//
//  Created by Ed on 08/04/2023.
//

import SwiftUI
import WebKit

struct VideoPlayerView: View {
    let videoID: String

    var body: some View {
        WebView(url: URL(string: "https://yewtu.be/embed/\(videoID)")!)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
    }
    
    // Add this method to customize the shape of the view
    func makeNSView(context: Context) -> NSView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        webView.wantsLayer = true
        webView.layer?.cornerRadius = 10
        return webView
    }
}


struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(videoID: "")
    }
}
