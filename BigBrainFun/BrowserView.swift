//
//  BrowserView.swift
//  BigBrainFun
//
//  Created by Ed on 12/04/2023.
//

import SwiftUI
import WebKit
import Cocoa

class TabViewController: NSViewController, WKNavigationDelegate {
    
    // MARK: Properties
    
    
    let webView = WKWebView()
    
    // MARK: Initialization
    
    init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
        
        webView.navigationDelegate = self
        view = webView
        
        if let url = url {
            load(url)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public methods
    
    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
    func stop() {
        webView.stopLoading()
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        view.window?.title = webView.title ?? "Untitled"
    }
    
}

struct BrowserView: NSViewRepresentable {
    
    // MARK: Properties
    
    let tabViewController: TabViewController
    
    // MARK: NSViewRepresentable
    
    func makeNSView(context: Context) -> NSView {
        let view = tabViewController.view
        view.frame.size = NSSize(width: 400, height: 300)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
}


struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(tabViewController: TabViewController(url: URL(string: "https://www.google.com")!))
    }
}
