//
//  BigBrainFunApp.swift
//  BigBrainFun
//
//  Created by Ed on 01/04/2023.
//

import SwiftUI

@main
struct BigBrainFunApp: App {
    let questsManager = QuestsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(questsManager)
        }
    }
}

