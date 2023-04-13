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
    let blockedURLs = ["youtube.com", "twitch.tv"]
    
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
        if shouldBlock(url: url) {
            let alert = NSAlert()
            alert.messageText = "Available on ⭐️ DASH ⭐️"
            alert.runModal()
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        // Check if URL has a scheme
        if urlComponents.scheme == nil {
            // If it doesn't have a scheme, add http:// as the default
            urlComponents.scheme = "http"
        }
        
        webView.load(URLRequest(url: urlComponents.url!))
    }

    func shouldBlock(url: URL) -> Bool {
        for blockedURL in blockedURLs {
            if url.absoluteString.lowercased().contains(blockedURL.lowercased()) {
                return true
            }
        }
        return false
    }

    
    @objc func goBack() {
        webView.goBack()
    }
    
    @objc func goForward() {
        webView.goForward()
    }
    
    @objc func reload() {
        webView.reload()
    }
    
    @objc func stop() {
        webView.stopLoading()
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, shouldBlock(url: url) {
                let alert = NSAlert()
                alert.messageText = "Available on ⭐️ DASH ⭐️"
                alert.runModal()
                decisionHandler(.cancel)
                goBack()
            } else {
                decisionHandler(.allow)
            }
        }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        view.window?.title = webView.title ?? "Untitled"
        
        // Find the content view
        guard let contentView = view.superview else {
            print("Error: Could not find content view")
            return
        }
        
        // Access the stack view
        guard let foundStackView = contentView.subviews.first(where: { $0 is NSStackView }) as? NSStackView else {
            print("Error: Could not find stack view")
            return
        }
        
        // Access the address panel
        guard let foundAddressPanel = foundStackView.arrangedSubviews.first(where: { $0 is AddressPanel }) as? AddressPanel else {
            print("Error: Could not find address panel")
            return
        }
        
        // Update the text field with the current URL
        foundAddressPanel.updateTextField(with: webView.url)
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
        
        let backButton = NSButton(title: "←", target: tabViewController, action: #selector(TabViewController.goBack))
        backButton.bezelStyle = .texturedRounded
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        let forwardButton = NSButton(title: "→", target: tabViewController, action: #selector(TabViewController.goForward))
        forwardButton.bezelStyle = .texturedRounded
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        
        let reloadButton = NSButton(image: NSImage(named: NSImage.refreshTemplateName)!, target: tabViewController, action: #selector(TabViewController.reload))
        reloadButton.bezelStyle = .texturedRounded
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stopButton = NSButton(image: NSImage(named: NSImage.stopProgressTemplateName)!, target: tabViewController, action: #selector(TabViewController.stop))
        stopButton.bezelStyle = .texturedRounded
        stopButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonStackView = NSStackView(views: [backButton, forwardButton, reloadButton, stopButton])
        buttonStackView.orientation = .horizontal
        buttonStackView.spacing = 5
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let addressPanel = AddressPanel(tabViewController: tabViewController)
        addressPanel.translatesAutoresizingMaskIntoConstraints = false
        
        let webView = tabViewController.view
        webView.wantsLayer = true
        webView.layer?.backgroundColor = backgroundColor.cgColor
        webView.layer?.cornerRadius = cornerRadius
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStackView = NSStackView(views: [buttonStackView, addressPanel])
        horizontalStackView.orientation = .horizontal
        horizontalStackView.spacing = 10
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStackView = NSStackView(views: [horizontalStackView, webView])
        verticalStackView.orientation = .vertical
        verticalStackView.spacing = 0
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            verticalStackView.topAnchor.constraint(equalTo: view.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addressPanel.heightAnchor.constraint(equalToConstant: 30),
            buttonStackView.widthAnchor.constraint(equalToConstant: 100),
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
        
        textField.placeholderString = "https://www.google.com"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.maximumNumberOfLines = 1
        textField.lineBreakMode = .byTruncatingTail
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            textField.heightAnchor.constraint(equalToConstant: 25),
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
    
    func updateTextField(with url: URL?) {
        textField.stringValue = url?.absoluteString ?? ""
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
