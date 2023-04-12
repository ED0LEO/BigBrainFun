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
    
    let onClose: () -> Void
    
    private func analyzeFile() {
        guard let fileURL = selectedFileURL else {
            print("No file selected")
            return
        }
        
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
        }
    }



    
    var body: some View {
        VStack {
            Text("Analyze File for Quest: \(quest.title)")
                .font(.title)
                .padding()
                .foregroundColor(.black)
            
            if let fileURL = selectedFileURL {
                ImageView(fileURL: fileURL)
            }
            
            Text("Select a file to analyze:")
                .padding(.bottom)
                .foregroundColor(.black)
            
            HStack {
                Button(action: {
                    let openPanel = NSOpenPanel()
                    openPanel.allowedFileTypes = ["pdf", "jpg", "png"]
                    if openPanel.runModal() == NSApplication.ModalResponse.OK {
                        selectedFileURL = openPanel.url
                    }
                }, label: {
                    Text("Choose File")
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                
                if let fileURL = selectedFileURL {
                    Text(fileURL.lastPathComponent)
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom, 30)
            
            Button(action: {
                analyzeFile()
            }) {
                Text("Analyze File")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 30)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
            
            if let result = analysisResult {
                Text(result)
                    .padding()
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: {
                onClose()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 30)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
        }
        .frame(width: 500, height: 500)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
