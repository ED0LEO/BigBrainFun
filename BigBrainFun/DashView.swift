//
//  DashView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI

struct WinView: View {
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @Binding var won: Bool
    
    var body: some View {
        VStack {
            Text("Congratulations, you've won!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 150))
                .foregroundColor(.green)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
                .animation(Animation.easeOut(duration: 1.0))
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 0.5)) {
                        scale = 1.0
                        rotation = 360
                        opacity = 1.0
                    }
                }
            
            Spacer()
            
            Button("Go back") {
                won.toggle()
            }
            .buttonStyle(GrowingButton())
            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.71, blue: 0.21), Color(red: 0.91, green: 0.20, blue: 0.62)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .edgesIgnoringSafeArea(.all)
    }
}



struct PlayView: View{
    @State private var isRolling = false
    @State private var videos = ["star", "heart", "questionmark"]
    @State private var reel1 = "star"
    @State private var reel2 = "heart"
    @State private var reel3 = "questionmark"
    @Binding var won: Bool
    
    var body: some View{
        VStack{
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Enhancer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            .padding(.top, 50)
            .padding(.horizontal, 30)
            
            Spacer()
            
            HStack(spacing: 40) {
                Image(systemName: reel1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                Image(systemName: reel2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                Image(systemName: reel3)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
            }
            .frame(height: 150)
            
            Spacer()
            
            Button("Roll", action: spinReels)
                .buttonStyle(GrowingGradButton())
                .padding(.vertical, 20)
                .padding(.horizontal, 80)
                .disabled(isRolling)
                .opacity(isRolling ? 0.5 : 1)
                .animation(.easeInOut(duration: 0.3))
            
            Spacer()
                .frame(height: 50)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.71, blue: 0.21), Color(red: 0.91, green: 0.20, blue: 0.62)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        
    }
    
    
    func spinReels() {
        isRolling = true
        let newReel1 = videos.randomElement()!
        let newReel2 = videos.randomElement()!
        let newReel3 = videos.randomElement()!
        
        let delay1 = Double.random(in: 0.5...1.5)
        let delay2 = Double.random(in: 0.5...1.5)
        let delay3 = Double.random(in: 0.5...1.5)
        let duration1 = Double.random(in: 0.8...1.2)
        let duration2 = Double.random(in: 0.8...1.2)
        let duration3 = Double.random(in: 0.8...1.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay1) {
            withAnimation(.easeInOut(duration: duration1)) {
                reel1 = newReel1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay2) {
            withAnimation(.easeInOut(duration: duration2)) {
                reel2 = newReel2
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay3) {
            withAnimation(.easeInOut(duration: duration3)) {
                reel3 = newReel3
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if reel1 == reel2 && reel2 == reel3 {
                won = true
            }
            isRolling = false
        }
    }
}

struct DashView: View{
    @State private var winningTime = false
    
    var body: some View{
        VStack{
            if !winningTime {
                PlayView(won: $winningTime)
                    .animation(
                        Animation.spring(response: 0.5, dampingFraction: 0.5)
                            .speed(1.5)
                    )
            } else {
                WinView(won: $winningTime)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 100, damping: 10)
                    )
            }
        }
    }
    
}

struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView()
    }
}

