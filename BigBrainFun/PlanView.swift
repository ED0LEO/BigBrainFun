//
//  PlanView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI

struct PlanView: View {
    @State private var text = "Next project to accomplish"
    @State private var isComplete = false
    
    var body: some View {
        VStack{
            Group{
                //list of tasks
                Text("Current tasks")
                    .padding()
                
                //to add new task
                TextField("Enter text here", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    
                }) {
                    Text("Play this project")
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
