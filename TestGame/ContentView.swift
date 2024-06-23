//
//  ContentView.swift
//  TestGame
//
//  Created by Наташа Яковчук on 22.06.2024.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @StateObject var vm = ViewModel()
    @State var scene = SKScene(fileNamed: "MyScene") as? GameScene
        
    var body: some View {
        VStack {
            if let scene = scene {
                
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .overlay {
                        VStack {
                            Text(vm.timeString(from: vm.timeRemaining))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .foregroundStyle(.green)
                            
                            Spacer()
                        }
                    }
                
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.0)
            }
            
        }.overlay {
            
            if let pause = scene?.isPaused, pause {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    Button {
                        withAnimation {
                            vm.startGame()
                        }
                    } label: {
                        Text("Start")
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $vm.showWebView) {
            VStack {
                Button {
                    vm.showWebView = false
                    scene = SKScene(fileNamed: "MyScene") as? GameScene
                    scene?.isPaused = true
                    vm.timeRemaining = 30
                } label: {
                    Text("<- Back")
                        .foregroundStyle(.red)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                }
                
                if let url = vm.webURL {
                    WebView(url: url)
                }
                
            }.onAppear {
                scene = nil
            }
        }
        .onChange(of: scene?.lose) { newValue in
            
            guard newValue == true else {return}
            vm.fetchURLs(lose: true)
            
        }
        .onChange(of: vm.webURL) { newValue in
            if vm.webURL != nil {
                vm.timer?.invalidate()
                vm.showWebView = true
            }
        }
        
        .onAppear {
            vm.serverRequest()
        }
    }
}

#Preview {
    ContentView()
}

