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
    @Binding var winnerVideo: YouTubeVideoPlayerView
    
    var body: some View {
        VStack {
            Text("Congratulations, you've won!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
                .foregroundColor(.white)
            
            Spacer()
            
            winnerVideo
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
    @State private var videos: [YouTubeVideoPlayerView] = [
        YouTubeVideoPlayerView(videoID: "cYcbNdV2bO8"),
        YouTubeVideoPlayerView(videoID: "iYjpElPF8K0"),
        YouTubeVideoPlayerView(videoID: "OYWZF43A5MU")
    ]
    @State private var reel1: YouTubeVideoPlayerView = YouTubeVideoPlayerView(videoID: "cYcbNdV2bO8")
    @State private var reel2: YouTubeVideoPlayerView = YouTubeVideoPlayerView(videoID: "iYjpElPF8K0")
    @State private var reel3: YouTubeVideoPlayerView = YouTubeVideoPlayerView(videoID: "OYWZF43A5MU")
    @Binding var won: Bool
    @Binding var winnerVideo: YouTubeVideoPlayerView
    
    var body: some View{
        VStack{
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 24))
                Text("Dash")
                    .titleStyle()
                    .fontWeight(.bold)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 24))
                
            }
            .padding(.bottom)
            .padding(.horizontal, 30)
            
            
            GeometryReader { geometry in
                HStack(spacing: 40) {
                    Spacer()
                    VStack(spacing: 0) {
                        Spacer()
                        reel1
                            .frame(width: min(geometry.size.width * 0.27, geometry.size.height * 1.77), height: min(geometry.size.height * 0.5, geometry.size.width / 1.77))
                            .aspectRatio(contentMode: .fill)
                            .disabled(true)
                        Spacer()
                    }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        reel2
                            .frame(width: min(geometry.size.width * 0.27, geometry.size.height * 1.77), height: min(geometry.size.height * 0.5, geometry.size.width / 1.77))
                            .aspectRatio(contentMode: .fill)
                            .disabled(true)
                        Spacer()
                    }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        reel3
                            .frame(width: min(geometry.size.width * 0.27, geometry.size.height * 1.77), height: min(geometry.size.height * 0.5, geometry.size.width / 1.77))
                            .aspectRatio(contentMode: .fill)
                            .disabled(true)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            Button("Roll", action: spinReels)
                .buttonStyle(GrowingGradButton())
                .padding(.vertical, 20)
                .padding(.horizontal, 80)
                .disabled(isRolling)
                .opacity(isRolling ? 0.5 : 1)
                .animation(.easeInOut(duration: 0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
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
            if reel1.videoID == reel2.videoID && reel2.videoID == reel3.videoID {
                won = true
                winnerVideo = reel1
            }
            isRolling = false
        }
    }
}

struct DashView: View{
    @State private var winningTime = false
    @State private var winnerVideo = YouTubeVideoPlayerView(videoID: "cYcbNdV2bO8")
    
    var body: some View{
        VStack{
            if !winningTime {
                PlayView(won: $winningTime, winnerVideo: $winnerVideo)
                    .animation(
                        Animation.spring(response: 0.5, dampingFraction: 0.5)
                            .speed(1.5)
                    )
            } else {
                WinView(won: $winningTime, winnerVideo: $winnerVideo)
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

