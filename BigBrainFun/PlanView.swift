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
    @EnvironmentObject var questsManager: QuestsManager
    @State private var newQuest = ""
    @State private var quests = [Quest]()
    @State private var isComplete = false
    @State private var isPopoverPresented = false
    @State private var selectedCategory: Category = .study
    @State private var addCategory: Category = .study
    @FocusState private var focused: Bool
    
    var sortedQuests: [Quest] {
//        quests.sorted { $0.category.rawValue < $1.category.rawValue }
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
                
                ScrollView {
                    ForEach(sortedQuests.filter { $0.category == selectedCategory }) { quest in
                        HStack {
                            Button(action: {
                                markQuestCompleted(quest: quest)
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
                            
                            if let index = quests.firstIndex(of: quest) {
                                Button(action: {
                                    deleteQuest(at: index)
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .opacity(quests[index].deleteButtonIsShown ? 1 : 0)
                                .animation(.default)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onHover { isHovering in
                            guard let index = quests.firstIndex(of: quest) else { return }
                            quests[index].deleteButtonIsShown = isHovering
                        }
                    }
                }
                .padding()
                
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
                .padding(.bottom)
                .onAppear {
                    self.focused = true
                }
                
                Button("Check", action: checkIfQuestCompleted)
                    .buttonStyle(GrowingButton())
                    .padding()
                    .animation(.easeInOut(duration: 0.3))
                
                
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
            .padding(.top, 44)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
    
    private func checkIfQuestCompleted() {
        for quest in quests {
            if quest.isCompleted {
                isComplete = true
                return
            }
        }
        isComplete = false
        isPopoverPresented = true
    }
    
    private func markQuestCompleted(quest: Quest) {
        if let index = quests.firstIndex(of: quest) {
            quests[index].isCompleted.toggle()
        }
    }
    
    private func deleteQuest(at index: Int) {
        quests.remove(at: index)
    }
    
    private func addQuest(title: String, category: Category) {
        if !title.isEmpty {
//            quests.append(Quest(title: title, category: category))
            questsManager.insertQuest(quest: Quest(title: title, category: category))
        }
        newQuest = ""
        
        questsManager.printAllQuests()
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
    let id = UUID()
    var title: String
    var isCompleted = false
    var deleteButtonIsShown = false
    var category: Category
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
