//
//  PrizesView.swift
//  BigBrainFun
//
//  Created by Ed on 11/05/2023.
//

import SwiftUI

struct PrizesView: View {
    @EnvironmentObject var questsManager: QuestsManager

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
        }
    }
    
    private func completedQuestsCount(category: Category) -> Int {
        let allQuests = questsManager.getAllQuests()
        let completedQuests = allQuests.filter { quest in
            quest.category == category && quest.isCompleted
        }
        return completedQuests.count
    }
}

struct PrizesView_Previews: PreviewProvider {
    static var previews: some View {
        PrizesView()
    }
}
