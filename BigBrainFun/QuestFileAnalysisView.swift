//
//  QuestFileAnalysisView.swift
//  BigBrainFun
//
//  Created by Ed on 12/04/2023.
//

import SwiftUI
import Vision

struct QuestFileAnalysisView: View {
    @EnvironmentObject var points: Points
    @State var quest: Quest
    @EnvironmentObject var questsManager: QuestsManager
    @State var selectedFileURL: URL?
    @State private var analysisResult: String?
    @State private var isAnalyzing = false
    @State private var loadedImage: NSImage?
    
    let onClose: () -> Void
    
    private func updateQuestDocumentURL(newURL: URL) {
        quest.documentURL = newURL
        questsManager.updateQuest(id: quest.id, title: quest.title, category: quest.category, isCompleted: quest.isCompleted, documentURL: newURL)
    }
    
    private func toggleCompletion() {
        questsManager.updateQuest(id: quest.id, title: quest.title, category: quest.category, isCompleted: !quest.isCompleted, documentURL: quest.documentURL!)
        quest.isCompleted.toggle() // update the local quest state variable as well
        points.points = points.points + 100
    }
    
    private func analyzeFile() {
        
        if quest.documentURL == nil{
            print("No file selected")
            return
        }
        
        if let fileURL = quest.documentURL{
            
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
                            toggleCompletion()
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
        
    }
    
    var body: some View {
        ZStack {
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
                
                if let docURL = quest.documentURL, let imageData = try? Data(contentsOf: docURL), let image = NSImage(data: imageData) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
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
                            if let selectedURL = selectedFileURL{
                                updateQuestDocumentURL(newURL: selectedURL)
                            }
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
         
            if quest.isCompleted{
                CelebrationView(points: 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
            }
        }
    }
}
