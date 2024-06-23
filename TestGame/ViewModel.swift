//
//  ViewModel.swift
//  TestGame
//
//  Created by Наташа Яковчук on 23.06.2024.
//

import Foundation
import SpriteKit

final class ViewModel: ObservableObject {
    
    @Published var showWebView =  false
    @Published  var webURL: URL?

    @Published var timeRemaining = 30
    @Published var timer: Timer?
    
    var scene = SKScene(fileNamed: "MyScene") as? GameScene
    
    func startTimer() {
        timer?.invalidate()
        timeRemaining = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                
            } else {
                
                self.timer?.invalidate()
                self.scene?.isPaused = true
                self.fetchURLs(lose: false)
            }
        }
    }

    func startGame() {
        timer?.invalidate()
        startTimer()
        scene?.isPaused = false
    }
    
    
    
    func serverRequest() {
        guard UserDefaults.standard.string(forKey: "savedURLs") == nil else { return }
        
        guard let url = URL(string: "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let winner = json["winner"],
                   let loser = json["loser"] {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set("\(winner)---\(loser)", forKey: "savedURLs")
                    }
                }
            } catch {
                print("Failed to parse JSON")
            }
        }
        task.resume()
    }
    
    func fetchURLs(lose: Bool) {
        if let savedURLs = UserDefaults.standard.string(forKey: "savedURLs"), !savedURLs.isEmpty {
            let urls = savedURLs.components(separatedBy: "---")
            if urls.count == 2 {
                webURL = URL(string: lose ? urls[1] : urls[0])
            }
        }
    }
    
func timeString(from seconds: Int) -> String {
    let minutes = seconds / 60
    let seconds = seconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

}
