//
//  SpinningBackgroundView.swift
//  BigBrainFun
//
//  Created by Ed on 04/04/2023.
//

import SwiftUI

struct SpinningBackgroundView: View {
    let elementCount = 100 // Change the number of elements here
    let elementSize: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.85, blue: 0.4), Color(red: 0.96, green: 0.48, blue: 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .overlay(
                    ZStack {
                        ForEach(0..<elementCount) { index in
                            let xOffset = CGFloat.random(in: 0...geometry.size.width)
                            let yOffset = CGFloat.random(in: 0...geometry.size.height)
                            
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.system(size: elementSize))
                                .offset(x: xOffset, y: yOffset)
                                .rotationEffect(.degrees(Double.random(in: 0...360)))
                                .animation(Animation.linear(duration: Double.random(in: 6...8)).repeatForever(autoreverses: true))
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: elementSize))
                                .offset(x: xOffset, y: yOffset)
                                .rotationEffect(.degrees(Double.random(in: 0...360)))
                                .animation(Animation.linear(duration: Double.random(in: 6...8)).repeatForever(autoreverses: true))
                        }
                    }
                )
        }
    }
}

struct FocusBackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color(red: 0.7, green: 0.5, blue: 0.9), Color(red: 0.4, green: 0.2, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct SpinningBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SpinningBackgroundView()
    }
}
