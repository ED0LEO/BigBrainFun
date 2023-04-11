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
    
    let onClose: () -> Void
    
    let quest: Quest

    var body: some View {
        VStack {
            HStack {
                Text(quest.title)
                    .font(.title)
                    .padding()
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 20)
            }
            .padding(.horizontal, 20)
            
            Text(quest.category.rawValue)
                .font(.headline)
                .padding(.bottom)
                .foregroundColor(.black)
            
            Text("Quest details go here...")
                .padding()
                .foregroundColor(.black)
            
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
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
            }
            .padding(.bottom, 30)
            
            Spacer()
            
            Button(action: {
                onClose()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 30)
                    .background(Color.red)
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
