//
//  QuestViews.swift
//  BigBrainFun
//
//  Created by Ed on 10/04/2023.
//

import Foundation
import SwiftUI

struct QuestDetailsView: View {
    @State private var isQuestDone = false
    @State private var fileURL: URL?
    
    let quest: Quest

    var body: some View {
        VStack {
            Text(quest.title)
                .font(.title)
                .padding()
            
            Text(quest.category.rawValue)
                .font(.headline)
                .padding(.bottom)
            
            Text("Quest details go here...")
                .padding()
            
            Spacer()
            
            HStack {
                Button(action: {
                    isQuestDone.toggle()
                }, label: {
                    Image(systemName: isQuestDone ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                })
                
                Spacer()
                
                Button(action: {
                    let openPanel = NSOpenPanel()
                    openPanel.allowedFileTypes = ["pdf", "jpg", "png"]
                    if openPanel.runModal() == NSApplication.ModalResponse.OK {
                        fileURL = openPanel.url
                    }
                }, label: {
                    Text("Upload File")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
            }
            .padding()
        }
        .padding()
    }
}
