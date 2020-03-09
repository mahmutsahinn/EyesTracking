//
//  SpaceScene.swift
//  BIL496
//
//  Created by Mahmut  Şahin on 6.03.2019.
//  Copyright © 2019 Mahmut  Şahin. All rights reserved.
//

import Foundation
import SpriteKit

extension SpaceScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == rocket || contact.bodyB.node == rocket {
            [contact.bodyA, contact.bodyB].filter { $0.node! != rocket }.forEach { $0.node?.removeFromParent() }
            let textures: [SKTexture] = [
                SKTexture(imageNamed: "Explosion-0"),
                SKTexture(imageNamed: "Explosion-1"),
                SKTexture(imageNamed: "Explosion-2"),
                SKTexture(imageNamed: "Explosion-3"),
                SKTexture(imageNamed: "Explosion-4"),
                SKTexture(imageNamed: "Explosion-5"),
                SKTexture(imageNamed: "Explosion-6")
            ]
            rocket.run(.animate(with: textures, timePerFrame: 0.05)) {
                self.rocket.removeFromParent()
                self.removeAllActions()
                self.removeAllChildren()
                self.addGameOver()
            }
            return
        }
        if let laser = [contact.bodyA, contact.bodyB].filter({ $0.node!.name == "laser" }).first,
            let asteroid = [contact.bodyA, contact.bodyB].filter({ $0.node!.name == "asteroid" }).first {
            let textures: [SKTexture] = [
                SKTexture(imageNamed: "Explosion-0"),
                SKTexture(imageNamed: "Explosion-1"),
                SKTexture(imageNamed: "Explosion-2"),
                SKTexture(imageNamed: "Explosion-3"),
                SKTexture(imageNamed: "Explosion-4"),
                SKTexture(imageNamed: "Explosion-5"),
                SKTexture(imageNamed: "Explosion-6")
            ]
            asteroid.node?.run(.animate(with: textures, timePerFrame: 0.05)) {
                laser.node?.removeFromParent()
                asteroid.node?.removeFromParent()
                self.score += 1
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {

    }
}

protocol SpaceSceneDelegate: Any {
    func addGameOver()
}

class SpaceScene: SKScene {

    var score = 0
    private lazy var rocket = SKSpriteNode(imageNamed: "Rocket")
    private var gravity: CGFloat!
    var gameDelegate: SpaceSceneDelegate?
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        gravity = physicsWorld.gravity.dy
        backgroundColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        startGame()
    }
    
    func eyeCoordinate(_ x: CGFloat,_ y: CGFloat) {
        var x = x + 150
        if x < 0 {
            x = 0
        } else if x > UIScreen.main.bounds.width {
            x = UIScreen.main.bounds.width
        }
        let move = SKAction.move(to: CGPoint(x: x, y: 100), duration: 0.1)
        rocket.run(move)
    }
    
    func stopGame() {
        self.removeAllActions()
        self.removeAllChildren()
        self.score = 0
    }

    func startGame() {
        stopGame()
        physicsWorld.gravity.dy = gravity / 4
        run(.repeatForever(.sequence([
            .wait(forDuration: 2),
            .run({ [weak self] in
                self?.spawnAsteroid()
            })
            ])))
        run(.repeatForever(.sequence([
            .wait(forDuration: 0.1),
            .run({ [weak self] in
                self?.spawnLaser()
            })
            ])))
        spawnRocket()
        physicsWorld.contactDelegate = self
    }

    private func spawnAsteroid() {
        var asteroid = SKSpriteNode(imageNamed: "Asteroid")
        switch Int.random(in: 0 ..< 4) {
        case 0:
            asteroid = SKSpriteNode(imageNamed: "world")
        case 1:
            asteroid = SKSpriteNode(imageNamed: "moon")
        case 2:
            asteroid = SKSpriteNode(imageNamed: "jupiter")
        default:
            asteroid = SKSpriteNode(imageNamed: "Asteroid")
        }
        asteroid.setScale(0.5)
        asteroid.name = "asteroid"
        addChild(asteroid)
        asteroid.position.x = randomXPosition()
        asteroid.position.y = size.height
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: asteroid.size.width, height: asteroid.size.height ))
        physicsBody.collisionBitMask = 1
        asteroid.physicsBody = physicsBody
        let moveDuration: TimeInterval = 5
        let actionGroup = SKAction.group([
            .rotate(byAngle: 0, duration: moveDuration)
            ])
        asteroid.run(actionGroup) { [weak asteroid] in
            asteroid?.removeFromParent()
        }
    }

    private func spawnRocket() {
        rocket = SKSpriteNode(imageNamed: "Rocket")
        rocket.setScale(1.0)
        addChild(rocket)
        rocket.position.x = size.height / 2
        rocket.position.y = 100
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rocket.size.width, height: rocket.size.height))
        physicsBody.collisionBitMask = 0
        rocket.physicsBody = physicsBody
        rocket.physicsBody?.isDynamic = false
        rocket.physicsBody?.contactTestBitMask = 1
    }

    private func spawnLaser() {
        let laser = SKSpriteNode(imageNamed: "Laser")
        laser.setScale(0.2)
        laser.blendMode = .add
        laser.name = "laser"
        addChild(laser)
        laser.position.x = rocket.position.x
        laser.position.y = 160
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width, height: laser.size.height ))
        laser.physicsBody = physicsBody
        laser.physicsBody?.isDynamic = false
        laser.physicsBody?.contactTestBitMask = 1
        let actionGroup = SKAction.group([
            .move(to: CGPoint(x: laser.position.x, y: size.height), duration: 0.2)
            ])
        laser.run(actionGroup) { [weak laser] in
            laser?.removeFromParent()
        }
    }
    
    private func addGameOver() {
        gameDelegate?.addGameOver()
    }
}

