//
//  QuestFileAnalysisView.swift
//  BigBrainFun
//
//  Created by Ed on 12/04/2023.
//

import SwiftUI
import Vision

import NaturalLanguage

struct QuestFileAnalysisView: View {
    @EnvironmentObject var points: Points
    @State var quest: Quest
    @EnvironmentObject var questsManager: QuestsManager
    @State var selectedFileURL: URL?
    @State private var analysisResult: String?
    @State private var isAnalyzing = false
    @State private var loadedImage: NSImage?
    
    let onClose: () -> Void
    
    func isImageMatchingTitle(title: String, image: CGImage) -> Bool {
        guard let model = try? YOLOv3(configuration: MLModelConfiguration()),
              let visionModel = try? VNCoreMLModel(for: model.model) else {
            print("Failed to load YOLOv3 model.")
            return false
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        
        var matched = false
        
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard let observations = request.results as? [VNRecognizedObjectObservation],
                  let topObservation = observations.first else {
                return
            }
            
            let titleWords = Set(title.lowercased().components(separatedBy: " "))
            let matchedWords = topObservation.labels
                .filter { label in
                    let labelWords = Set(label.identifier.lowercased().components(separatedBy: " "))
                    let commonWords = titleWords.intersection(labelWords)
                    let commonWordsRatio = Float(commonWords.count) / Float(labelWords.count)
                    return commonWordsRatio >= 0.5 // Filter out labels that don't have enough common words with the title
                }
                .map { $0.identifier.lowercased() }
            
            let commonWords = titleWords.intersection(matchedWords)
            
            if !commonWords.isEmpty {
                matched = true
                print("Object matched the title!")
                print("Title: \(title)")
                print("Title Words: \(titleWords)")
                print("Matched Words: \(matchedWords)")
                print("Common Words: \(commonWords)")
            } else {
                print("Object didn't match the title.")
                print("Title: \(title)")
                print("Title Words: \(titleWords)")
                print("Matched Words: \(matchedWords)")
            }
        }
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform image recognition.")
            return false
        }
        
        return matched
    }
    
    
    func isJobDescription(title: String, text: String) -> Bool {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        
        let jobTitle = title.lowercased()
        var jobWords: Set<String> = []
        jobTitle.enumerateSubstrings(in: jobTitle.startIndex..., options: .byWords) { word, _, _, _ in
            if let word = word {
                jobWords.insert(word)
            }
        }
        
        var jobDescWords: Set<String> = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            guard let tag = tag, let token = text[tokenRange].lowercased().trimmingCharacters(in: .whitespacesAndNewlines) as String?, !jobWords.contains(token) else {
                return true
            }
            
            if tag == .organizationName || tag == .placeName {
                jobDescWords.insert(token)
            }
            
            return true
        }
        
        let commonWords = jobWords.intersection(jobDescWords)
        
        print("Job Title: \(jobTitle)")
        print("Job Words: \(jobWords)")
        print("Job Desc Words: \(jobDescWords)")
        print("Common Words: \(commonWords)")
        
        return commonWords.count >= jobWords.count / 2
    }
    
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
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let imageData = try Data(contentsOf: fileURL)
                    guard let image = NSImage(data: imageData) else {
                        DispatchQueue.main.async {
                            self.analysisResult = "Failed to create image from data"
                        }
                        return
                    }
                    
                    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                        DispatchQueue.main.async {
                            self.analysisResult = "Failed to create CGImage from NSImage"
                        }
                        return
                    }
                    
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                    let textRequest = VNRecognizeTextRequest { (request, error) in
                        defer {
                            // Hide loading bar
                            DispatchQueue.main.async {
                                self.isAnalyzing = false
                            }
                        }
                        
                        guard let observations = request.results as? [VNRecognizedTextObservation],
                              !observations.isEmpty else {
                            DispatchQueue.main.async {
                                self.analysisResult = "No text detected"
                            }
                            return
                        }
                        
                        let text = observations.compactMap { observation in
                            observation.topCandidates(1).first?.string
                        }.joined(separator: "\n")
                        
                        if text.isEmpty {
                            DispatchQueue.main.async {
                                self.analysisResult = "No text detected"
                            }
                        } else {
                            if isJobDescription(title: quest.title, text: text) {
                                DispatchQueue.main.async {
                                    self.analysisResult = "Text detected:\n\(text)"
                                    self.toggleCompletion()
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.analysisResult = "Text detected:\n\(text)"
                                }
                            }
                        }
                        if !quest.isCompleted {
                            if isImageMatchingTitle(title: quest.title, image: cgImage) {
                                DispatchQueue.main.async {
                                    self.analysisResult = "Object detected."
                                    self.toggleCompletion()
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.analysisResult = "Object is not detected."
                                }
                            }
                        }
                    }
                    textRequest.recognitionLevel = .accurate
                    try requestHandler.perform([textRequest])
                } catch {
                    DispatchQueue.main.async {
                        self.analysisResult = "Error analyzing file: \(error.localizedDescription)"
                        // Hide loading bar
                        self.isAnalyzing = false
                    }
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
