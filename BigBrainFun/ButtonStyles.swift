//
//  ButtonStyles.swift
//  BigBrainFun
//
//  Created by Ed on 14/04/2023.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: -2, y: -2)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.purple, lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: 2, y: 2)
                }
            )
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
}
struct SelectFileButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 5)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 2)
                        .blur(radius: 3)
                        .offset(x: -1, y: -1)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.green, lineWidth: 2)
                        .blur(radius: 3)
                        .offset(x: 1, y: 1)
                }
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
}

struct AnalyzeButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.orange.opacity(0.5), radius: 10, x: 0, y: 5)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 2)
                        .blur(radius: 3)
                        .offset(x: -1, y: -1)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.orange, lineWidth: 2)
                        .blur(radius: 3)
                        .offset(x: 1, y: 1)
                }
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
}
