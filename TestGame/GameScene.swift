//
//  GameScene.swift
//  TestGame
//
//  Created by Наташа Яковчук on 22.06.2024.
//

import Foundation
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let motionManager = CMMotionManager()
    var ball: SKSpriteNode!
    var lose: Bool = false
    
    enum PhysicsCategory: UInt32 {
        case ball = 0b1
        case platform = 0b10
    }
    
    
    override func didMove(to view: SKView) {
            backgroundColor = .clear
            
            var isSE = UIScreen.main.bounds.height < 680
            size = CGSize(width: isSE ? UIScreen.main.bounds.width + 20: 400, height: isSE ? 600: 700)
            scaleMode = .fill
            
        let frameWithExtendedTop = CGRect(
                    x: self.frame.origin.x,
                    y: self.frame.origin.y,
                    width: self.frame.size.width,
                    height: self.frame.size.height + 200
                )
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frameWithExtendedTop)
        
            setUpView()
        
        self.isPaused = true
        }
    
    override func update(_ currentTime: TimeInterval) {
            super.update(currentTime)
            
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 9.8, dy: accelerometerData.acceleration.y * 9.8)
            }
        
        checkBallOutOfBounds()
            
        }
    
    func checkBallOutOfBounds() {
           if !self.frame.contains(ball.position) {
               self.removeAllActions()
               lose = true
           }
       }
    
    func setUpView() {
        physicsWorld.contactDelegate = self
        motionManager.startAccelerometerUpdates()
        for node in self.children {
            if let spriteNode = node as? SKSpriteNode {
                addPlatformPhysicsBody(to: spriteNode)
            }
        }
        
        for node in self.children {
            if node.name == "mainPlatform" {
                for secondaryNode in node.children {
                    if let spriteNode = secondaryNode as? SKSpriteNode {
                        addPlatformPhysicsBody(to: spriteNode)
                    }
                }
            }
        }
        
        copyAnimatedPlatform()
    }
    
    func copyAnimatedPlatform() {
        guard let referencNode = self.children.first(where: { $0.name == "mainPlatform" })  else { return }
        
        for index in 1...40 {
            let newNode = referencNode.copy() as! SKNode
            newNode.position = .init(x: CGFloat.random(in: 0...self.size.width), y: referencNode.position.y - CGFloat(80 * index))
            self.addChild(newNode)
        }
    }
     
    
    func addPlatformPhysicsBody(to sprite: SKSpriteNode) {
        if let texture = sprite.texture {
            sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        } else {
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        }
        
        sprite.physicsBody?.isDynamic = sprite.name == "ball" ? true : false
        sprite.physicsBody?.allowsRotation = sprite.name == "ball" ? true : false
        
        if sprite.name == "ball" {
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.ball.rawValue
            
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.platform.rawValue
            sprite.physicsBody?.collisionBitMask = PhysicsCategory.platform.rawValue
        } else {
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.platform.rawValue
            
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.ball.rawValue
            sprite.physicsBody?.collisionBitMask = PhysicsCategory.ball.rawValue
        }
        
        if sprite.name == "ball" {
            ball = sprite
        }
        
    }
//    
//    func didBegin(_ contact: SKPhysicsContact) {
//            
//            var firstBody = contact.bodyA
//            var secondBody = contact.bodyB
//            
//            
//            if firstBody.categoryBitMask == PhysicsCategory.ball.rawValue && secondBody.categoryBitMask == PhysicsCategory.platform.rawValue {
//
//            }
//        }
    
}
