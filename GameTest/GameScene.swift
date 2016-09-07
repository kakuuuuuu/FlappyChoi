//
//  GameScene.swift
//  GameTest
//
//  Created by Kyle Tsuyemura on 7/8/16.
//  Copyright (c) 2016 Kyle Tsuyemura. All rights reserved.
//

import SpriteKit
import AVFoundation


struct Physics{
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4

}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var deathSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "mp3")!)
    var jumpSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("jump", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLabel = SKLabelNode()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    var restartLabel = SKLabelNode()
    var restartPair = SKNode()
    
    var sprites = ["michael-choi", "jay", "brendan", "oscar", "jimmy", "pareiece"]
    var counter = 0
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        if counter < sprites.count-1{
            counter += 1
        }
        else{
            counter = 0
        }
        CreateScene()
    }
    
    func CreateScene(){
        

        self.physicsWorld.contactDelegate = self
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOfURL: jumpSound)
//            audioPlayer.volume = 0.1
//            audioPlayer.prepareToPlay()
//        }
//        catch let error {
//            // handle error
//        }
//        audioPlayer.prepareToPlay()
        for i in 0..<2{
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        
        
        Ground = SKSpriteNode(imageNamed:"Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = Physics.Ground
        Ground.physicsBody?.collisionBitMask = Physics.Ghost
        Ground.physicsBody?.contactTestBitMask = Physics.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        
        Ghost = SKSpriteNode(imageNamed: sprites[counter])
        Ghost.size = CGSize(width: 60, height: 60)
        Ghost.position = CGPoint(x: self.frame.width / 2 - Ghost.frame.width, y: self.frame.height / 2)
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = Physics.Ghost
        Ghost.physicsBody?.collisionBitMask = Physics.Ground | Physics.Wall
        Ghost.physicsBody?.contactTestBitMask = Physics.Ground | Physics.Wall | Physics.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.dynamic = true
        Ghost.zPosition = 3
        
        self.addChild(Ghost)
        

    }
    
    override func didMoveToView(view: SKView) {
        /* Setup Scene */
        
        CreateScene()
    }
    
    func createBTN(){
        
        restartPair = SKNode()
        
        restartBTN = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: 200, height:100))
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        
        restartLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartLabel.text = "Keep Struggling"
        restartLabel.fontName = "04b_19"
        restartLabel.fontSize = 20
        restartLabel.zPosition = 7
        
        restartPair.addChild(restartBTN)
        restartPair.addChild(restartLabel)
        restartPair.setScale(0)
        self.addChild(restartPair)
        restartPair.runAction(SKAction.scaleTo(1.0, duration:0.3))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == Physics.Score && secondBody.categoryBitMask == Physics.Ghost || secondBody.categoryBitMask == Physics.Score && firstBody.categoryBitMask == Physics.Ghost{
            
            score += 1
            scoreLabel.text = "\(score)"
            
        }
        
        if firstBody.categoryBitMask == Physics.Ghost && secondBody.categoryBitMask == Physics.Wall || secondBody.categoryBitMask == Physics.Ghost && firstBody.categoryBitMask == Physics.Wall{
            if died == false{
                print("Died")
                died = true
                do {
                    audioPlayer = try AVAudioPlayer(contentsOfURL: deathSound)
                    audioPlayer.volume = 4
                    audioPlayer.play()
                }
                catch let error {
                    // handle error
                }
                let burstPath = NSBundle.mainBundle().pathForResource(
                    "explosion", ofType: "sks")
                
                if burstPath != nil {
                    let burstNode =
                        NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
                            as! SKEmitterNode
                    burstNode.position = CGPointMake(Ghost.position.x, Ghost.position.y)
                    burstNode.zPosition = 7
                    self.addChild(burstNode)
                    
                }
                createBTN()
            }
        }
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false{
            
            gameStarted = true
            
            Ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let SpawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(SpawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 40, y:0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVectorMake(0,0)
            Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 65))
//            audioPlayer.play()
            
        }else{
            
            if died == true{
                
            }
            else{
                Ghost.physicsBody?.velocity = CGVectorMake(0,0)
                Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 65))
//                if audioPlayer.playing{
//                    audioPlayer.stop()
//                    audioPlayer.currentTime = 0
//                    audioPlayer.play()
//                }
//                else{
//                    audioPlayer.play()
//                }
            }
            
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if died == true{
                if restartBTN.containsPoint(location){
                    restartScene()
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if gameStarted == true{
            enumerateChildNodesWithName("background", usingBlock: ({
                (node, error) in
                var bg = node as! SKSpriteNode
                bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                }
            }))
        }
        
    }
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width:1, height: 200)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = Physics.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = Physics.Ghost
        
        wallPair = SKNode()
        
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = Physics.Wall
        topWall.physicsBody?.collisionBitMask = Physics.Ghost
        topWall.physicsBody?.contactTestBitMask = Physics.Ghost
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = Physics.Wall
        btmWall.physicsBody?.collisionBitMask = Physics.Ghost
        btmWall.physicsBody?.contactTestBitMask = Physics.Ghost
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        wallPair.addChild(scoreNode)
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
}