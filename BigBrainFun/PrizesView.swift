//
//  PrizesView.swift
//  BigBrainFun
//
//  Created by Ed on 11/05/2023.
//

import SwiftUI

struct PrizesView: View {
    @EnvironmentObject var questsManager: QuestsManager
    @EnvironmentObject var points: Points
    @State private var prizeButtonVisible = false
    @State private var todayChallengeCompleted = false
    @State private var consecutiveDaysChallengeCompleted = false
    @State private var questsCompletedChallengeCompleted = false
    
    @State var completedChallengeDates: [Date] = []

    var body: some View {
        VStack {
            Divider()
            
            HStack {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                Text("Completed")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            ForEach(Category.allCases, id: \.self) { category in
                HStack {
                    Text(category.rawValue)
                        .frame(maxWidth: .infinity)
                    Text("\(completedQuestsCount(category: category))")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            if prizeButtonVisible {
                Button("Get Prize!") {
                    // Give points or some other reward
                    points.points += 50
                    
                    // Reset the challenges/achievements
                    todayChallengeCompleted = false
                    consecutiveDaysChallengeCompleted = false
                    questsCompletedChallengeCompleted = false
                    checkChallenges()
                }
            }
            
            // Display challenge progress
            VStack {
                if todayChallengeCompleted {
                    Text("✅ Complete at least one quest today").foregroundColor(.green)
                } else {
                    Text("❌ Complete at least one quest today").foregroundColor(.red)
                }
                
                if consecutiveDaysChallengeCompleted {
                    Text("✅ Complete 5 quests on 5 consecutive days").foregroundColor(.green)
                } else {
                    Text("❌ Complete 5 quests on 5 consecutive days").foregroundColor(.red)
                }
                
                if questsCompletedChallengeCompleted {
                    Text("✅ Complete 20 quests").foregroundColor(.green)
                } else {
                    Text("❌ Complete 20 quests").foregroundColor(.red)
                }
            }
        }
        .onAppear {
            checkChallenges()
        }
    }
    
    private func completedQuestsCount(category: Category) -> Int {
        let allQuests = questsManager.getAllQuests()
        let completedQuests = allQuests.filter { quest in
            quest.category == category && quest.isCompleted
        }
        return completedQuests.count
    }
    
    private func checkChallenges() {
        // Check challenges and set prizeButtonVisible to true if a challenge has been completed
        let allQuests = questsManager.getAllQuests()
        let completedQuests = allQuests.filter { $0.isCompleted }
        let sortedQuests = completedQuests.sorted(by: { $0.completionDate! < $1.completionDate! })

        // Check for completed quests on current day
        let todayCompleted = completedQuests.contains(where: { Calendar.current.isDateInToday($0.completionDate!) })
        if todayCompleted && !completedChallengeDates.contains(Date()) {
            completedChallengeDates.append(Date())
            todayChallengeCompleted = true
        } else {
            todayChallengeCompleted = false
        }

        // Check for completed quests on 5 consecutive days
        var daysCompleted = 0
        var previousCompletionDate: Date?
        for quest in sortedQuests {
            if let previousDate = previousCompletionDate {
                if Calendar.current.isDate(previousDate, inSameDayAs: quest.completionDate!) {
                    continue // Quest completed on same day as previous quest, skip
                } else if let days = Calendar.current.dateComponents([.day], from: previousDate, to: quest.completionDate!).day, days == 1 {
                    daysCompleted += 1 // Quest completed on consecutive day
                } else {
                    daysCompleted = 0 // Quest not completed on consecutive day, reset count
                }
            }
            previousCompletionDate = quest.completionDate

            if daysCompleted >= 4 && !completedChallengeDates.contains(quest.completionDate!) {
                completedChallengeDates.append(quest.completionDate!)
                consecutiveDaysChallengeCompleted = true
                break // Prize already available, no need to check other challenges
            }
        }

        // Check for completion of 20 quests
        if completedQuests.count >= 20 && !completedChallengeDates.contains(Date()) {
            completedChallengeDates.append(Date())
            questsCompletedChallengeCompleted = true
        } else {
            questsCompletedChallengeCompleted = false
        }

        // Check if prize button should be visible
        let rewardAlreadyCollected = completedChallengeDates.contains(where: { Calendar.current.isDateInToday($0) })
        prizeButtonVisible = !rewardAlreadyCollected && (todayChallengeCompleted || consecutiveDaysChallengeCompleted || questsCompletedChallengeCompleted)
    }

}

struct PrizesView_Previews: PreviewProvider {
    static var previews: some View {
        PrizesView()
    }
}
