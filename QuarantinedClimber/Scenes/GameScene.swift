//
//  GameScene.swift
//  QuarantinedClimber
//
//  Created by Kevin Nogales on 5/24/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let HITPOINTS = 10
    let MISSPOINTS = -8
    let MINCOUNT = 0
    let NUMROUTES = 8
    let NUMCLIMBERS = 8
    
    var currentClimber: String?
    var currentClimberState: Int?
    
    var leftClimber: String?
    var leftClimberState: Int?
    
    var rightClimber: String?
    var rightClimberState: Int?
    
    var currentRoute: String?
    var currentRouteState: Int?
    
    var nextRoute: String?
    var nextRouteState: Int?
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    
    
    override func didMove(to view: SKView) {
        self.layoutScene()
        self.setUpPhysics()
    }
    
    func setUpPhysics() {
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.03)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        
        self.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        displayScoreLabel()
        spawnClimber()
        spawnRoute()
    }
    
    func displayScoreLabel() {
        self.scoreLabel.fontName = "AvenirNext-Bold"
        self.scoreLabel.fontSize = 60.0
        self.scoreLabel.fontColor = UIColor.white
        self.scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + (self.frame.midY / 2))
        self.scoreLabel.zPosition = ZPositions.label
        self.scoreLabel.name = "RouteLabel"
        self.addChild(scoreLabel)
    }
    
    func updateScoreLabel() {
        self.scoreLabel.text = "\(self.score)"
    }
    
    func spawnClimber() {
        
        if self.currentClimber == nil && self.currentClimberState == nil {
            // If no current climber and climber state, generate new climber and climber state.
            let newClimberState = Int(arc4random_uniform(UInt32(8)))
            let newClimber = Climber.climbers[newClimberState]
            self.currentClimberState = newClimberState
            self.currentClimber = newClimber
        } else if let child = self.childNode(withName: "Climber") as? SKSpriteNode {
            // Remove previous Climber.
            child.removeFromParent()
        }
        
        // Spawn current climber
        let climberTextureScaleUp: CGFloat = 1.8
        let climberTexture = SKTexture(imageNamed: self.currentClimber!)
        let climberTextureSize = climberTexture.size()
        let climber = SKSpriteNode(texture: climberTexture, size: CGSize(width: climberTextureSize.width * climberTextureScaleUp, height: climberTextureSize.height * climberTextureScaleUp))
        climber.name = "Climber"
        climber.position = CGPoint(x: frame.midX, y: (frame.midY / 2) + frame.height * 0.05)
        climber.zPosition = ZPositions.climber
        climber.physicsBody = SKPhysicsBody(circleOfRadius: climber.size.width / 2)
        climber.physicsBody?.categoryBitMask = PhysicsCategories.climberCategory
        climber.physicsBody?.isDynamic = false
        self.addChild(climber)
        
        if (self.currentClimberState == self.currentRouteState) {
            animateHintRoute()
        }
        
    }
    
    func climberRotateLeft() {
        self.currentClimberState! -= 1
        
        if (self.currentClimberState! < self.MINCOUNT) {
            self.currentClimberState = self.NUMCLIMBERS - 1
        }
        
        self.currentClimber = Climber.climbers[self.currentClimberState!]
        self.spawnClimber()
    }
    
    func climberRotateRight() {
        self.currentClimberState! += 1
        
        if (self.currentClimberState! >= self.NUMCLIMBERS) {
            self.currentClimberState = self.MINCOUNT
        }
        
        self.currentClimber = Climber.climbers[self.currentClimberState!]
        self.spawnClimber()
    }
    
    func spawnRoute() {
        if (self.nextRouteState == nil && self.nextRoute == nil) {
            // Generate new current route and current route state
            let newRouteState = Int(arc4random_uniform(UInt32(8)))
            let newRoute = Route.routes[newRouteState]
            self.currentRouteState = newRouteState
            self.currentRoute = newRoute
        } else {
            // Use next route state and next route
            self.currentRouteState = self.nextRouteState
            self.currentRoute = self.nextRoute
        }
        
        let routeTextureScaleUp: CGFloat = 1.8
        let routeTexture = SKTexture(imageNamed: self.currentRoute!)
        let routeTextureSize = routeTexture.size()
        let scaledRouteTextureSize = CGSize(width: routeTextureSize.width * routeTextureScaleUp, height: routeTextureSize.height * routeTextureScaleUp)
        let route = SKSpriteNode(texture: routeTexture, size: scaledRouteTextureSize)
        route.name = "Route"
        route.position = CGPoint(x: frame.midX, y: frame.maxY + routeTextureSize.height)
        route.zPosition = ZPositions.route
        route.physicsBody = SKPhysicsBody(circleOfRadius: route.size.width / 4)
        route.physicsBody?.categoryBitMask = PhysicsCategories.routeCategory
        route.physicsBody?.contactTestBitMask = PhysicsCategories.climberCategory
        route.physicsBody?.collisionBitMask = PhysicsCategories.none
        self.addChild(route)
        
        self.spawnNextRoute()
    }
    
    func spawnNextRoute() {
        let newNextRouteState = Int(arc4random_uniform(UInt32(8)))
        let newNextRoute = Route.routes[newNextRouteState]
        self.nextRouteState = newNextRouteState
        self.nextRoute = newNextRoute
        
        self.displayNextRoutePreview()
    }
    
    func displayNextRoutePreview() {
        if let previousNextRoute = self.childNode(withName: "PreviewRoute") {
            previousNextRoute.removeFromParent()
        }
        
        let previewRouteTextureScaleUp: CGFloat = 1/3
        let previewRouteTexture = SKTexture(imageNamed: self.nextRoute!)
        let previewRouteTextureSize = previewRouteTexture.size()
        let scaledPreviewRouteTextureSize = CGSize(width: previewRouteTextureSize.width * previewRouteTextureScaleUp, height: previewRouteTextureSize.height * previewRouteTextureScaleUp)
        let previewRoute = SKSpriteNode(texture: previewRouteTexture, size: scaledPreviewRouteTextureSize)
        previewRoute.name = "PreviewRoute"
        previewRoute.position = CGPoint(x: frame.maxX - scaledPreviewRouteTextureSize.width, y: frame.maxY - scaledPreviewRouteTextureSize.height)
        
        self.addChild(previewRoute)
        
    }
    
    func hitUpdate(_ climber: SKSpriteNode) {
        
        self.score += self.HITPOINTS
        self.updateScoreLabel()
        self.animateClimberHit(climber)
    }
    
    func animateClimberHit(_ climber: SKSpriteNode) {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.25)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.25)
        
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        
        climber.run(SKAction.repeat(sequence, count: 2))
        
        self.scoreLabel.run(SKAction.repeat(sequence, count: 2))
        
        if let route = self.childNode(withName: "Route") {
            let scaleUpRoute = SKAction.scale(to: 1.3, duration: 0.25)
            let scaleDownRoute = SKAction.scale(to: 1.0, duration: 0.25)
            let sequenceRoute = SKAction.sequence([scaleUpRoute, scaleDownRoute])
            route.run(SKAction.repeat(sequenceRoute, count: 2))
        }
    }
    
    func missUpdate(_ climber: SKSpriteNode) {
        
        self.score += self.MISSPOINTS
        self.updateScoreLabel()
        self.animateClimberMiss(climber)
        
        if (self.score < 0) {
            self.gameOver()
        }
    }
    
    func animateClimberMiss(_ climber: SKSpriteNode) {
        if let currentClimber = self.childNode(withName: "Climber") {
            let moveLeft = SKAction.moveTo(x: currentClimber.position.x - 8, duration: 0.01)
            let moveRight = SKAction.moveTo(x: currentClimber.position.x + 8, duration: 0.01)
            let moveCenter = SKAction.moveTo(x: frame.midX, duration: 0.01)
            let sequence = SKAction.sequence([moveLeft, moveCenter, moveRight, moveCenter])
            
            currentClimber.run(SKAction.repeat(sequence, count: 1))
        }
    }
    
    func animateHintRoute() {
        if let currentRoute = self.childNode(withName: "Route"), let currentClimber = self.childNode(withName: "Climber") {
            let routeMoveLeft = SKAction.moveTo(x: currentRoute.position.x - 16, duration: 0.01)
            let routeMoveRight = SKAction.moveTo(x: frame.midX, duration: 0.01)
            
            let climberMoveLeft = SKAction.moveTo(x: currentClimber.position.x - 16, duration: 0.01)
            let climberMoveRight = SKAction.moveTo(x: frame.midX, duration: 0.01)
            
            let routeSequence = SKAction.sequence([routeMoveLeft, routeMoveRight])
            let climberSequence = SKAction.sequence([climberMoveLeft, climberMoveRight])
            
            currentRoute.run(SKAction.repeat(routeSequence, count: 1))
            currentClimber.run(SKAction.repeat(climberSequence, count: 1))
        }
    }
    
    func gameOver() {
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self.view)
            
            if (location.x < self.view!.frame.width / 2 && location.y > self.view!.frame.height / 3) {
                self.climberRotateLeft()
            } else if (location.x > self.view!.frame.width / 2 && location.y > self.view!.frame.height / 3) {
                self.climberRotateRight()
            } else {
                print("Touched top section!")
            }
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.climberCategory | PhysicsCategories.routeCategory {
            if let route = contact.bodyA.node?.name == "Route" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode,
                let climber = contact.bodyA.node?.name == "Climber" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                
                route.physicsBody?.categoryBitMask = PhysicsCategories.none
                route.physicsBody?.contactTestBitMask = PhysicsCategories.none
                route.physicsBody?.collisionBitMask = PhysicsCategories.none
                
                if self.currentRouteState! == self.currentClimberState! {
                    self.hitUpdate(climber)
                } else {
                    self.missUpdate(climber)
                }
                
                route.run(SKAction.fadeOut(withDuration: 2.0), completion: {
                    route.removeFromParent()
                    self.spawnRoute()
                })
            }
        }
    }
}
