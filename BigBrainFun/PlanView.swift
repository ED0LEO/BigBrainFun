//
//  PlanView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI
import SceneKit

struct ChestView: View {
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        SceneView(scene: createScene(), options: [.allowsCameraControl])
            .frame(width: 200, height: 200)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        rotation += value.translation.width / 50
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            rotation = 0
                        }
                    }
            )
    }
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // Create chest geometry and material
        let chestGeometry = SCNBox(width: 1.0, height: 0.8, length: 0.6, chamferRadius: 0.1)
        let chestMaterial = SCNMaterial()
        chestMaterial.diffuse.contents = NSImage(named: "heart_texture")
        chestGeometry.materials = [chestMaterial]
        
        // Create chest node
        let chestNode = SCNNode(geometry: chestGeometry)
        chestNode.position = SCNVector3(0, 0, -2)
        scene.rootNode.addChildNode(chestNode)
        
        // Create lid node
        let lidGeometry = SCNBox(width: 1.0, height: 0.05, length: 0.6, chamferRadius: 0.1)
        let lidMaterial = SCNMaterial()
        lidMaterial.diffuse.contents = Color(red: 0.957, green: 0.835, blue: 0.573)
        lidGeometry.materials = [lidMaterial]
        
        let lidNode = SCNNode(geometry: lidGeometry)
        lidNode.position = SCNVector3(0, 0.4, -0.3)
        chestNode.addChildNode(lidNode)
        
        // Create lock node
        let lockGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0.03)
        let lockMaterial = SCNMaterial()
        lockMaterial.diffuse.contents = Color(red: 0.082, green: 0.082, blue: 0.082)
        lockGeometry.materials = [lockMaterial]
        
        let lockNode = SCNNode(geometry: lockGeometry)
        lockNode.position = SCNVector3(0, 0.25, 0.31)
        lidNode.addChildNode(lockNode)
        
        // Add animations
        let lidOpenAnimation = SCNAction.rotateBy(x: -CGFloat.pi / 4, y: 0, z: 0, duration: 0.5)
        lidOpenAnimation.timingMode = .easeInEaseOut
        
        let lidCloseAnimation = SCNAction.rotateBy(x: CGFloat.pi / 4, y: 0, z: 0, duration: 0.5)
        lidCloseAnimation.timingMode = .easeInEaseOut
        
        lidNode.runAction(lidCloseAnimation)
        
        return scene
    }
}

struct ChestView_Previews: PreviewProvider {
    static var previews: some View {
        ChestView()
    }
}

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

struct SpinningBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.71, blue: 0.21), Color(red: 0.91, green: 0.20, blue: 0.62)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    ForEach(0..<10) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.system(size: 30))
                            .offset(x: CGFloat.random(in: -200...200), y: CGFloat.random(in: -200...200))
                            .rotation3DEffect(.degrees(Double.random(in: 0...360)), axis: (x: 1, y: 1, z: 0))
                            .animation(Animation.linear(duration: Double.random(in: 1...3)).repeatForever(autoreverses: false))
                        
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 30))
                            .offset(x: CGFloat.random(in: -200...200), y: CGFloat.random(in: -200...200))
                            .rotation3DEffect(.degrees(Double.random(in: 0...360)), axis: (x: 0, y: 1, z: 1))
                            .animation(Animation.linear(duration: Double.random(in: 1...3)).repeatForever(autoreverses: false))
                    }
                }
            )
    }
}


struct PlanView: View {
    @State private var newQuest = ""
    @State private var quests = [Quest]()
    @State private var isComplete = false
    @State private var isPopoverPresented = false
    @State private var selectedCategory: Category = .study
    @State private var addCategory: Category = .study
    
    var sortedQuests: [Quest] {
        quests.sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    var categories: [Category] {
        Category.allCases
    }
    
    
    var body: some View {
        ZStack {
            SpinningBackground()
            
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
                    TextField("Enter new quest", text: $newQuest, onCommit: {addQuest(title: newQuest, category: addCategory) })
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
                
                Button("Check", action: checkIfQuestCompleted)
                    .buttonStyle(GrowingButton())
                    .padding()
                    .animation(.easeInOut(duration: 0.3))
                
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                } else {
                    
                }
            }
            .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                PopoverView(isPresented: $isPopoverPresented)
            }
            .padding(.top, 44)
        }
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
            quests.append(Quest(title: title, category: category))
        }
        newQuest = ""
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
        .background(Color.white)
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
    var category: Category = Category.study
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
