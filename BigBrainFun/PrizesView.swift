//
//  PrizesView.swift
//  BigBrainFun
//
//  Created by Ed on 11/05/2023.
//

import SwiftUI

struct ChallengeView: View {
    var title: String
    var completed: Bool
    var rewardAlreadyCollected: Bool
    var action: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(completed ? Color.green : Color.yellow)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.white)
                )
            
            HStack {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom, 5)
                    if rewardAlreadyCollected {
                        Text("Reward claimed")
                            .font(.caption)
                            .foregroundColor(.white)
                    } else if completed {
                        Button(action: action) {
                            Text("Claim Reward")
                                .foregroundColor(.white)
                                .font(.footnote)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    } else {
                        Text("In Progress")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
            }
            .padding(10)
        }
        .frame(height: 100)
    }
}


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
                ChallengeView(title: "Complete at least one quest today", completed: todayChallengeCompleted, rewardAlreadyCollected: completedChallengeDates.contains(where: { Calendar.current.isDateInToday($0) })) {
                    // Give points or some other reward
                    points.points += 50
                    
                    // Reset the challenges/achievements
                    todayChallengeCompleted = false
                    checkChallenges()
                }
                
                ChallengeView(title: "Complete 5 quests on 5 consecutive days", completed: consecutiveDaysChallengeCompleted, rewardAlreadyCollected: completedChallengeDates.contains(where: { Calendar.current.isDateInToday($0) })) {
                    // Give points or some other reward
                    points.points += 100
                    
                    // Reset the challenges/achievements
                    consecutiveDaysChallengeCompleted = false
                    checkChallenges()
                }
                
                ChallengeView(title: "Complete 20 quests", completed: questsCompletedChallengeCompleted, rewardAlreadyCollected: completedChallengeDates.contains(where: { Calendar.current.isDateInToday($0) })) {
                    // Give points or some other reward
                    points.points += 200
                    
                    // Reset the challenges/achievements
                    questsCompletedChallengeCompleted = false
                    checkChallenges()
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
    
    private func checkTodayChallenge() -> Bool {
        let completedQuests = questsManager.getAllQuests().filter { $0.isCompleted }
        let todayCompleted = completedQuests.contains(where: { Calendar.current.isDateInToday($0.completionDate!) })
        if todayCompleted && !completedChallengeDates.contains(Date()) {
            completedChallengeDates.append(Date())
            return true
        }
        return false
    }

    private func checkConsecutiveDaysChallenge() -> Bool {
        let completedQuests = questsManager.getAllQuests().filter { $0.isCompleted }
        let sortedQuests = completedQuests.sorted(by: { $0.completionDate! < $1.completionDate! })
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
                return true
            }
        }
        return false
    }

    private func checkQuestsCompletedChallenge() -> Bool {
        let completedQuests = questsManager.getAllQuests().filter { $0.isCompleted }
        if completedQuests.count >= 20 && !completedChallengeDates.contains(Date()) {
            completedChallengeDates.append(Date())
            return true
        }
        return false
    }

    private func checkChallenges() {
        todayChallengeCompleted = checkTodayChallenge()
        consecutiveDaysChallengeCompleted = checkConsecutiveDaysChallenge()
        questsCompletedChallengeCompleted = checkQuestsCompletedChallenge()

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
