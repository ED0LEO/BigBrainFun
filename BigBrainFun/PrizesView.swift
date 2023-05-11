//
//  PrizesView.swift
//  BigBrainFun
//
//  Created by Ed on 11/05/2023.
//

import SwiftUI

struct PrizesView: View {
    var body: some View {
        VStack {
            Text("Congratulations! You completed quests for 5 days in a row and received +100 points!")
                .font(.title)
                .multilineTextAlignment(.center)
            // Add more prize information and styling here
        }
    }
}

struct PrizesView_Previews: PreviewProvider {
    static var previews: some View {
        PrizesView()
    }
}
