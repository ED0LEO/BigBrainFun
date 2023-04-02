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

        let chestGeometry = SCNBox(width: 1.0, height: 0.8, length: 0.6, chamferRadius: 0.1)
        let chestMaterial = SCNMaterial()
        chestMaterial.diffuse.contents = NSImage(named: "chest_texture")
        chestGeometry.materials = [chestMaterial]

        let chestNode = SCNNode(geometry: chestGeometry)
        chestNode.position = SCNVector3(0, 0, -2)
        scene.rootNode.addChildNode(chestNode)

        let lidNode = SCNNode(geometry: SCNBox(width: 1.0, height: 0.05, length: 0.6, chamferRadius: 0.1))
        lidNode.geometry?.firstMaterial?.diffuse.contents = Color.brown
        lidNode.position = SCNVector3(0, 0.5, -2)
        scene.rootNode.addChildNode(lidNode)

        let hingeNode = SCNNode()
        hingeNode.position = SCNVector3(0, 0.5, -2)
        hingeNode.eulerAngles = SCNVector3(0, -CGFloat.pi/4, 0)
        hingeNode.addChildNode(lidNode)
        chestNode.addChildNode(hingeNode)

        let lockNode = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0.03))
        lockNode.geometry?.firstMaterial?.diffuse.contents = Color.black
        lockNode.position = SCNVector3(0, 0.25, 0.31)
        hingeNode.addChildNode(lockNode)

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
        VStack {
            Text("Current quests")
                .font(.title)
                .padding()
            
            List {
                ForEach(quests) { quest in
                    HStack {
                        Button(action: {
                            markQuestCompleted(quest: quest)
                        }) {
                            Image(systemName: quest.isCompleted ? "checkmark.square" : "square")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text(quest.title)
                        
                        Spacer()
                        
                        if let index = quests.firstIndex(of: quest) {
                            Button(action: {
                                deleteQuest(at: index)
                            }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .opacity(quests[index].deleteButtonIsShown ? 1 : 0)
                            .animation(.default)
                        }
                    }
                    .onHover { isHovering in
                        guard let index = quests.firstIndex(of: quest) else { return }
                        quests[index].deleteButtonIsShown = isHovering
                    }
                }
            }
            .listStyle(PlainListStyle())
            .padding()
            
            HStack {
                TextField("Enter new quest", text: $newQuest, onCommit: addQuest)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                Button(action: addQuest) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .buttonStyle(GrowingButton())
            }

            
            Spacer()
                .frame(height: 30)
            
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
            } else {
                ChestView()
            }
            
            Spacer()
                .frame(height: 30)
        }
    }
    
    private func addQuest() {
        guard !newQuest.isEmpty else { return }
        quests.append(Quest(title: newQuest))
        newQuest = ""
    }
    
    private func deleteQuest(at index: Int) {
        quests.remove(at: index)
    }
    
    private func markQuestCompleted(quest: Quest) {
        guard let index = quests.firstIndex(of: quest) else { return }
        quests[index].isCompleted.toggle()
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
