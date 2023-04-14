//
//  QuestViews.swift
//  BigBrainFun
//
//  Created by Ed on 10/04/2023.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: Category
    
    var categories: [Category] {
        Category.allCases
    }
    
    var body: some View {
        Picker(selection: $selectedCategory, label: Text("Category")) {
            ForEach(categories, id: \.self) { category in
                Text(category.rawValue)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if selectedCategory == category {
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.gray.opacity(0.4)
                            }
                        }
                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedCategory == category ? Color.blue : Color.clear, lineWidth: 2)
                    )
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

struct QuestsView: View {
    @EnvironmentObject var questsManager: QuestsManager
    @State private var newQuest = ""
    @State private var isComplete = false
    @State private var isPopoverPresented = false
    @State private var selectedCategory: Category = .study
    @State private var addCategory: Category = .study
    
    var onQuestSelected: ((Quest) -> Void)?
    @FocusState private var focused: Bool
    
    var sortedQuests: [Quest] {
        let quests = questsManager.getAllQuests()
        return quests.sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    var categories: [Category] {
        Category.allCases
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Current quests")
                    .titleStyle()
                    .padding(.bottom)
                
                CategoryPickerView(selectedCategory: $selectedCategory)
                
                ScrollView {
                    ForEach(sortedQuests.filter { $0.category == selectedCategory }) { oldQuest in
                        let quest = returnQuestbyId(id: oldQuest.id)
                        HStack {
                            Button(action: {
                                onQuestSelected?(quest)
                            }) {
                                Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.trailing, 8)
                            
                            Text(quest.title)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .bold()
                            
                            Text(quest.category.rawValue)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.pink)
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
                HStack {
                    TextField("New quest", text: $newQuest, onCommit: {addQuest(title: newQuest, category: addCategory) })
                        .focused($focused)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {addQuest(title: newQuest, category: addCategory) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
                    
                    Picker("", selection: $addCategory) {
                        ForEach(Category.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .onAppear {
                    self.focused = true
                }
                
                HStack{
                    Button("Check", action: checkIfQuestCompleted)
                        .buttonStyle(GrowingButton())
                        .padding()
                        .animation(.easeInOut(duration: 0.3))
                    
                    Button("DELETEALL", action: {
                        questsManager.emptyDatabase()
                    })
                    .buttonStyle(GrowingButton())
                    .padding()
                    .animation(.easeInOut(duration: 0.3))
                }
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                }
            }
            .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                PopoverView(isPresented: $isPopoverPresented)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
    
    private func returnQuestbyId(id: String) -> Quest{
        return questsManager.getQuestById(id: id)!
    }
    
    private func checkIfQuestCompleted() {
        for quest in sortedQuests {
            if quest.isCompleted {
                isComplete = true
                return
            }
        }
        isComplete = false
        isPopoverPresented = true
    }
    
    private func markQuestCompleted(quest: Quest) {
        questsManager.updateQuest(id: quest.id, title: quest.title, category: quest.category, isCompleted: !quest.isCompleted, documentURL: quest.documentURL!)
    }
    
    private func deleteQuest(quest: Quest) {
        questsManager.deleteQuest(quest: quest)
        print("deleteQuest: tit = " + quest.title + ", cat = " + quest.category.rawValue + ", id = " + quest.id)
        
        print("ALL:")
        questsManager.printAllQuests()
    }
    
    private func addQuest(title: String, category: Category) {
        if !title.isEmpty {
            let q = Quest(id: UUID().uuidString, title: title, category: category)
            questsManager.insertQuest(quest: q)
            print("addQuest: tit = " + q.title + ", cat = " + q.category.rawValue + ", id = " + q.id)
        }
        newQuest = ""
    }
}


struct QuestDetailsView: View {
    @EnvironmentObject var questsManager: QuestsManager
    @Binding var fileURL: URL?
    @State var quest: Quest
    @Binding var analyzing: Bool
    
    let onClose: () -> Void
    
    private func deleteQuest() {
        questsManager.deleteQuest(quest: quest)
        print("deleteQuest: tit = " + quest.title + ", cat = " + quest.category.rawValue + ", id = " + quest.id)
        
        print("ALL:")
        questsManager.printAllQuests()
    }
    
    private func toggleCompletion() {
        questsManager.updateQuest(id: quest.id, title: quest.title, category: quest.category, isCompleted: !quest.isCompleted, documentURL: quest.documentURL!)
        quest.isCompleted.toggle() // update the local quest state variable as well
        
        print("ALL:")
        questsManager.printAllQuests()
    }
    
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
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .buttonStyle(CloseButton())
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
                    toggleCompletion()
                }, label: {
                    Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
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
                })
                .buttonStyle(SelectFileButton())
                
                Spacer()
                
                Button(action: {
                    deleteQuest()
                    onClose()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .buttonStyle(SubtleTrashButton())
                .padding(8)
            }
            .padding(.bottom, 30)
            
            Button(action: {
                toggleCompletion()
            }) {
                Text(quest.isCompleted ? "Mark as Incomplete" : "Mark as Completed")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 30)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
            
            Spacer()
            if let fileURL = fileURL {
                ImageView(fileURL: fileURL)
            }
            Button(action: {
                analyzing.toggle()
            }) {
                Text("Send to analysis")
            }
            .buttonStyle(AnalyzeButton())
            .padding(.bottom, 30)
            
        }
        .frame(width: 500, height: 500)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
