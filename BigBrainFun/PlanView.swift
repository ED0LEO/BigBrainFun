//
//  PlanView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI

struct PlanView: View {
    @State private var text = "Next quest to accomplish"
    @State private var quests = [String]()
    @State private var isComplete = false
    
    var body: some View {
        VStack{
            Group{
                //list of tasks
                Text("Current quests")
                    .padding()
                
                List(quests, id: \.self) { text in
                    Text(text)
                }
                
                //to add new task
                TextField("Enter quest here", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    self.quests.append(self.text)
                    self.text = ""
                }) {
                    Text("Play this quest")
                }
                .buttonStyle(GrowingButton())
                Spacer()
                    .frame(height: 30)
                //check and go to roll
                if isComplete {
                    Image(systemName: "mark")
                        .resizable()
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "questionmark")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                
                Spacer()
                    .frame(height: 30)
            }
        }
        
    }
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
