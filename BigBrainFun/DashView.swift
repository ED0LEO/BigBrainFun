//
//  DashView.swift
//  BigBrainFun
//
//  Created by Ed on 02/04/2023.
//

import SwiftUI

struct WinView: View{
    var body: some View{
        VStack{
            Text("You've won:")
                .font(.title)
                .padding()
            Image(systemName: "dollar")
                .foregroundColor(.green)
        }
    }
}


struct PlayView: View{
    @State private var isRolling = false
    @State private var fruits = ["star", "heart", "questionmark"]
    @State private var reel1 = "star"
    @State private var reel2 = "heart"
    @State private var reel3 = "questionmark"
    
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
            
            Spacer()
                .frame(height: 50)
            
            HStack(spacing: 40) {
                Image(systemName: reel1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.yellow)
                Image(systemName: reel2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.pink)
                Image(systemName: reel3)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.green)
            }
            .frame(height: 150)
            Spacer()
                .frame(height: 50)
            Group{
                Button("Roll", action: spinReels)
                    .buttonStyle(GrowingGradButton())
                    .padding()
                    .disabled(isRolling)
                    .opacity(isRolling ? 0.5 : 1)
                    .animation(.easeInOut(duration: 0.3))
                
                Spacer()
                    .frame(height: 50)
            }
            
        }
    }
    
    func spinReels() {
        isRolling = true
        let newReel1 = fruits.randomElement()!
        let newReel2 = fruits.randomElement()!
        let newReel3 = fruits.randomElement()!
        
        withAnimation(.easeInOut(duration: 1)) {
            reel1 = newReel1
            reel2 = newReel2
            reel3 = newReel3
        }
        
        if reel1 == reel2 && reel2 == reel3 {
            NavigationView {
                NavigationLink(destination: WinView()) {
                    Text("Dash")
                        .padding()
                }
                .buttonStyle(GrowingButton())
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            isRolling = false
        }
    }
}

struct DashView: View{
    @State private var winningTime = false
    
    var body: some View{
        VStack{
            if !winningTime {
                PlayView()
            } else {
                WinView()
            }
            
            Button("Go back:") {
                winningTime.toggle()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
    
}

struct DashView_Previews: PreviewProvider {
    static var previews: some View {
        DashView()
    }
}
