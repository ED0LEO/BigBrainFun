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
    @State private var createNotification = false
    @EnvironmentObject var points: Points
    @State private var showCompletedQuests = false
    @FocusState private var focused: Bool
    
    var onQuestSelected: ((Quest) -> Void)?
    
    var sortedQuests: [Quest] {
        let quests = questsManager.getAllQuests()
        return quests.sorted(by: { $0.title < $1.title })
    }
    
    var filteredQuests: [Quest] {
        if showCompletedQuests {
            return sortedQuests.filter { $0.isCompleted && $0.category == selectedCategory }
        } else {
            return sortedQuests.filter { !$0.isCompleted && $0.category == selectedCategory }
        }
    }
    
    var categories: [Category] {
        Category.allCases
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Current quests")
                        .titleStyle()
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        showCompletedQuests.toggle()
                    }) {
                        Image(systemName: showCompletedQuests ? "checkmark.seal.fill" : "checkmark.seal")
                            .font(.system(size: 24))
                            .foregroundColor(showCompletedQuests ? Color.white : Color.gray)
                            .frame(width: 40, height: 40)
                            .background(showCompletedQuests ? Color.green : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                }
                
                CategoryPickerView(selectedCategory: $selectedCategory)
                
                ScrollView {
                    ForEach(filteredQuests) { oldQuest in
                        let quest = returnQuestbyId(id: oldQuest.id)
                        
                        Button(action: {
                            onQuestSelected?(quest)
                        }) {
                            HStack {
                                Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
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
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 8)
                        
                        
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
            }
            .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                PopoverView(isPresented: $isPopoverPresented)
            }
            
            if isComplete == true {
                RollsAvailableView()
                    .transition(.move(edge: .bottom))
                    .animation(.easeOut(duration: 0.5))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                // set the state variable back to false to hide the view after a delay
                                isComplete = false
                            }
                        }
                    }
            }
            
            if createNotification {
                QuestCreatedView()
                    .transition(.move(edge: .bottom))
                    .animation(.easeOut(duration: 0.5))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                // set the state variable back to false to hide the view after a delay
                                createNotification = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
    
    private func returnQuestbyId(id: String) -> Quest{
        return questsManager.getQuestById(id: id)!
    }
    
    private func checkIfQuestCompleted() {
        if points.points < 3 {
            isPopoverPresented = true
            return
        }
        
        for quest in sortedQuests {
            if quest.isCompleted {
                isComplete = true
                return
            }
        }
        isPopoverPresented = true
    }
    
    private func markQuestCompleted(quest: Quest) {
        questsManager.updateQuest(id: quest.id, title: quest.title, category: quest.category, isCompleted: !quest.isCompleted, documentURL: quest.documentURL!)
    }
    
    private func addQuest(title: String, category: Category) {
        if !title.isEmpty {
            let q = Quest(id: UUID().uuidString, title: title, category: category)
            questsManager.insertQuest(quest: q)
            print("addQuest: tit = " + q.title + ", cat = " + q.category.rawValue + ", id = " + q.id)
            createNotification = true
        }
        newQuest = ""
    }
}


struct QuestDetailsView: View {
    @EnvironmentObject var questsManager: QuestsManager
    @State var quest: Quest
    @Binding var analyzing: Bool
    
    let onClose: () -> Void
    
    private func deleteQuest() {
        questsManager.deleteQuest(quest: quest)
        print("deleteQuest: tit = " + quest.title + ", cat = " + quest.category.rawValue + ", id = " + quest.id)
        
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
            
            
            HStack {
                Image(systemName: quest.isCompleted ? "checkmark.seal.fill" : "checkmark.seal")
                    .font(.system(size: 32))
                    .foregroundColor(quest.isCompleted ? Color.green : Color.gray)
                    .frame(width: 50, height: 50)
                    .background(quest.isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.leading, 10)
                
                Spacer()
                
                Text("Quest details go here...")
                    .padding()
                    .foregroundColor(.black)
                
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
            
            Spacer()
            
            if let docURL = quest.documentURL, let imageData = try? Data(contentsOf: docURL), let image = NSImage(data: imageData) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            
            if !quest.isCompleted{
                Button(action: {
                    analyzing.toggle()
                }) {
                    Text("Send to analysis")
                }
                .buttonStyle(AnalyzeButton())
                .padding(.bottom, 30)
            }
            else
            {
                Spacer()
            }
        }
        .frame(width: 500, height: 500)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
