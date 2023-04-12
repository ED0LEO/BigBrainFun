//
//  PlanView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI
import SceneKit

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 36, weight: .bold))
            .foregroundColor(.white)
            .shadow(color: Color(red: 255/255, green: 102/255, blue: 102/255), radius: 4, x: 0, y: 0)
    }
}

extension Text {
    func titleStyle() -> some View {
        self.modifier(TitleStyle())
    }
}

struct PlanView: View {
    @State private var isAnalyzing = false
    @State private var selectedQuest: Quest? = nil
    @State private var fileURL: URL?
    
    
    var body: some View{
        VStack{
            if selectedQuest == nil {
                QuestsView(onQuestSelected: { quest in
                    selectedQuest = quest
                })
            } else if !isAnalyzing {
                QuestDetailsView(fileURL: $fileURL, quest: selectedQuest!, analyzing: $isAnalyzing, onClose: {
                    selectedQuest = nil
                })
            }
            else
            {
                QuestFileAnalysisView(quest: selectedQuest!, selectedFileURL: $fileURL, onClose: {
                    isAnalyzing = false
                })
            }
        }
    }
}

struct PopoverView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("You cant get a prize yet!")
                .font(.headline)
                .padding()
            
            Image(systemName: "cross")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Button("Close", action: {
                isPresented = false
            })
            .buttonStyle(GrowingButton())
            .padding()
            .animation(.easeInOut(duration: 0.3))
            
        }
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

enum Category: String, CaseIterable {
    case study = "Study"
    case dev = "Dev"
}

struct Quest: Identifiable, Equatable {
    var id: String
    var title: String
    var isCompleted = false
    var documentURL: URL?
    var category: Category
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
