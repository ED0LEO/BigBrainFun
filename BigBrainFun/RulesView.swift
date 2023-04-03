//
//  RulesView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI

struct RulesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group{
                    Text("User Guide")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Welcome to our productivity game app!")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("This is a user guide for our app. Here you will find all the information you need to get started and make the most of our app.")
                    
                    Text("Getting Started")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("To get started, all you need is to download this app.")
                    
                    Text("Using the App")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("Our app is designed to help you increase your productivity and achieve your goals. You can earn points by completing tasks, and use those points to unlock rewards and level up.")
                }
                Group{
                    Text("Completing Tasks")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("To complete a task, first add a task to the list of available tasks. You can filter the list by category or search for a specific task. Once you have chosen a task, click the 'Start' button to begin the task timer. You will earn points for completing the task on time.")
                    
                    Text("Rewards")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("You can use your earned points to unlock rewards, such as new backgrounds or avatar items. You can access the rewards section from the bottom menu.")
                    
                    Text("Leveling Up")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("As you earn points, you will level up and unlock new features and tasks. You can see your current level and progress in the 'Profile' section.")
                }
            }
            .padding()
        }
    }
}


struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
    }
}
