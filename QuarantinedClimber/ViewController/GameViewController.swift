//
//  GameViewController.swift
//  QuarantinedClimber
//
//  Created by Kevin Nogales on 5/24/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from GameScene
            let scene = MenuScene(size: self.view.bounds.size)
            
            // Set the scale mod eto scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            // Elements of scene can be rendered in a nonfix way
            view.ignoresSiblingOrder = true
            
            // Debug information shwoing FPS and Node Count.
            // Nodes are elements contained inside of a view.
            // SK Scene is a Node.
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
