//
//  QuestFileAnalysisView.swift
//  BigBrainFun
//
//  Created by Ed on 12/04/2023.
//

import SwiftUI
import Vision

struct ImageView: View {
    @State private var image: NSImage?
    let fileURL: URL
    
    var body: some View {
        VStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("No image available.")
                    .padding()
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    func loadImage() {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: fileURL),
               let nsImage = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.image = nsImage
                }
            }
        }
    }
}


struct QuestFileAnalysisView: View {
    let quest: Quest
    @Binding var selectedFileURL: URL?
    @State private var analysisResult: String?
    @State private var isAnalyzing = false
    
    let onClose: () -> Void
    
    private func analyzeFile() {
        guard let fileURL = selectedFileURL else {
            print("No file selected")
            return
        }
        
        // Show loading bar
        isAnalyzing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                guard let image = NSImage(data: imageData) else {
                    print("Failed to create image from data")
                    return
                }
                
                guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    print("Failed to create CGImage from NSImage")
                    return
                }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                let textRequest = VNRecognizeTextRequest { (request, error) in
                    defer {
                        // Hide loading bar
                        isAnalyzing = false
                    }
                    
                    guard let observations = request.results as? [VNRecognizedTextObservation],
                          !observations.isEmpty else {
                        self.analysisResult = "No text detected"
                        return
                    }
                    
                    let text = observations.compactMap { observation in
                        observation.topCandidates(1).first?.string
                    }.joined(separator: "\n")
                    
                    if text.isEmpty {
                        self.analysisResult = "No text detected"
                    } else {
                        self.analysisResult = "Text detected:\n\(text)"
                    }
                }
                textRequest.recognitionLevel = .accurate
                try requestHandler.perform([textRequest])
            } catch {
                print("Error analyzing file: \(error.localizedDescription)")
                // Hide loading bar
                isAnalyzing = false
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Analyze File for Quest: \(quest.title)")
                    .font(.title)
                    .padding()
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .buttonStyle(CloseButton())
            }
            .padding(.horizontal, 20)
            
            if let fileURL = selectedFileURL {
                ImageView(fileURL: fileURL)
            }
            
            Text("Select a file to analyze:")
                .padding(.bottom)
                .foregroundColor(.black)
            
            HStack {
                Button(action: {
                    let openPanel = NSOpenPanel()
                    openPanel.allowedFileTypes = ["jpg", "png"]
                    if openPanel.runModal() == NSApplication.ModalResponse.OK {
                        selectedFileURL = openPanel.url
                    }
                }, label: {
                    Text("Choose File")
                })
                .buttonStyle(SelectFileButton())
                
                if let fileURL = selectedFileURL {
                    Text(fileURL.lastPathComponent)
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom, 30)
            
            Spacer()
            
            if isAnalyzing {
                ProgressView("")
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.purple)
                    .padding(.bottom, 30)
            }
            else {
                Button(action: {
                    analyzeFile()
                }) {
                    Text("Analyze File")
                }
                .buttonStyle(AnalyzeButton())
                .padding(.bottom, 30)
                
                if let result = analysisResult {
                    ScrollView {
                        Text(result)
                            .padding()
                            .foregroundColor(.black)
                    }
                    .frame(height: 100)
                    .padding(.bottom, 30)
                }
            }
        }
        .frame(width: 500, height: 500)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
