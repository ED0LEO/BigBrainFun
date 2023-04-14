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
        WebView(url: URL(string: "https://inv.odyssey346.dev/embed/\(videoID)")!)
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
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(videoID: "")
    }
}
