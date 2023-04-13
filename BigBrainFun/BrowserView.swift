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
    
    // Customizable properties
    var backgroundColor: NSColor = .white
    var cornerRadius: CGFloat = 10
    
    // MARK: NSViewRepresentable
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.frame.size = NSSize(width: 400, height: 400)
        
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let addressPanel = AddressPanel(tabViewController: tabViewController)
        addressPanel.translatesAutoresizingMaskIntoConstraints = false
        
        let webView = tabViewController.view
        webView.wantsLayer = true
        webView.layer?.backgroundColor = backgroundColor.cgColor
        webView.layer?.cornerRadius = cornerRadius
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(addressPanel)
        stackView.addArrangedSubview(webView)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addressPanel.heightAnchor.constraint(equalToConstant: 20),
            webView.topAnchor.constraint(equalTo: addressPanel.bottomAnchor, constant: 10)
        ])
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
}

class AddressPanel: NSView, NSTextFieldDelegate {
    
    // MARK: Properties
    
    let tabViewController: TabViewController
    let textField = NSTextField()
    
    // MARK: Initialization
    
    init(tabViewController: TabViewController) {
        self.tabViewController = tabViewController
        super.init(frame: .zero)
        
        textField.placeholderString = "Enter a URL"
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            textField.heightAnchor.constraint(equalToConstant: 30),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20) // Increase the constant to increase the height
        ])

        textField.delegate = self
        textField.sendAction(#selector(NSTextFieldDelegate.controlTextDidEndEditing(_:)), to: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    @objc func textFieldDidEndEditing(_ sender: NSTextField) {
        // Load the entered URL in the web view
        let urlString = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.isEmpty, let url = URL(string: urlString) {
            tabViewController.load(url)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            let urlString = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !urlString.isEmpty, let url = URL(string: urlString) {
                tabViewController.load(url)
            }
        }
    
}


struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(tabViewController: TabViewController(url: URL(string: "https://www.google.com")!))
    }
}
