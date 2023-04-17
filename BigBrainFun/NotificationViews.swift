//
//  NotificationViews.swift
//  BigBrainFun
//
//  Created by Ed on 17/04/2023.
//

import SwiftUI

struct CelebrationView: View {
    let points: Int
    @State private var showCelebration = false
    
    var body: some View {
        VStack {
            Spacer() // Add a spacer to push the view to the top
            
            if showCelebration {
                Text("+\(points) points")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green)
                            .shadow(radius: 10)
                    )
                    .transition(.move(edge: .top))
                    .animation(.easeOut(duration: 0.5))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut(duration: 0)) {
                                showCelebration = false
                            }
                        }
                    }
            }
        }
        .frame(width: 200, height: 100)
        .onAppear {
            showCelebration = true
        }
        .zIndex(1)
        .overlay(Color.black.opacity(0.001)) // transparent overlay to capture clicks and events
        .alignmentGuide(.top) { $0[.bottom] } // align the view to the top of the screen
    }
}

struct QuestCreatedView: View {
    @State private var showCelebration = false
    
    var body: some View {
        VStack {
            Spacer() // Add a spacer to push the view to the top
            
            if showCelebration {
                Text("Created")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .shadow(radius: 10)
                    )
                    .transition(.move(edge: .top))
                    .animation(.easeOut(duration: 0.5))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut(duration: 0)) {
                                showCelebration = false
                            }
                        }
                    }
            }
        }
        .frame(width: 200, height: 100)
        .onAppear {
            showCelebration = true
        }
        .zIndex(1)
        .overlay(Color.black.opacity(0.001)) // transparent overlay to capture clicks and events
        .alignmentGuide(.top) { $0[.bottom] } // align the view to the top of the screen
    }
}

struct QuestCompletionView: View {
    @State private var showFireworks = false
    @State private var showStars = false
    
    var body: some View {
        ZStack {
            if showFireworks {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.orange)
                    .frame(width: 150, height: 150)
                    .transition(.scale)
                    .animation(.easeOut(duration: 1))
            }
            
            if showStars {
                HStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.yellow)
                        .frame(width: 50, height: 50)
                        .transition(.scale)
                        .animation(.easeOut(duration: 1))
                    
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.yellow)
                        .frame(width: 50, height: 50)
                        .transition(.scale)
                        .animation(.easeOut(duration: 1).delay(0.2))
                    
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.yellow)
                        .frame(width: 50, height: 50)
                        .transition(.scale)
                        .animation(.easeOut(duration: 1).delay(0.4))
                }
            }
        }
        .onAppear {
            showFireworks = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showStars = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                showFireworks = false
                showStars = false
            }
        }
    }
}
