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


struct PlanView: View {
    @State private var newQuest = ""
    @State private var quests = [Quest]()
    @State private var isComplete = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.71, blue: 0.21), Color(red: 0.91, green: 0.20, blue: 0.62)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
                .ignoresSafeArea()
            
            
            VStack {
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .padding(.trailing, 6)
                    Text("Current quests")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 255/255, green: 102/255, blue: 102/255))
                .cornerRadius(20)
                
                
                ScrollView {
                    ForEach(quests) { quest in
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
                    TextField("Enter new quest", text: $newQuest, onCommit: addQuest)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: addQuest) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
                
                Button("Check", action: addQuest)
                    .buttonStyle(GrowingButton())
                    .padding()
                    .animation(.easeInOut(duration: 0.3))
                
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                } else {
                    ChestView()
                }
            }
            .padding(.top, 44)
        }
    }
    
    private func markQuestCompleted(quest: Quest) {
        if let index = quests.firstIndex(of: quest) {
            quests[index].isCompleted.toggle()
        }
    }
    
    private func deleteQuest(at index: Int) {
        quests.remove(at: index)
    }
    
    private func addQuest() {
        if !newQuest.isEmpty {
            quests.append(Quest(title: newQuest))
            newQuest = ""
        }
    }
}

struct Quest: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var isCompleted = false
    var deleteButtonIsShown = false
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
