//
//  GameViewController.swift
//  GameTest
//
//  Created by Kyle Tsuyemura on 7/8/16.
//  Copyright (c) 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        scene.size = self.view.bounds.size
        
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
