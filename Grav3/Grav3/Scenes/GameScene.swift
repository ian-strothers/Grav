//
//  GameScene.swift
//  Grav
//
//  Created by ian on 7/14/15.
//  Copyright (c) 2015 ian. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var score = 0
    
    let arena = SKSpriteNode(imageNamed: "Arena")
    let scoreText = SKLabelNode(fontNamed: "HoeflerText")
    var balls:[Ball] = []
    let blackHole = SKSpriteNode(imageNamed: "BlackHole")
    let forceManager:ForceManager
    
    override init(size: CGSize) {
        forceManager = ForceManager(blackHole: blackHole)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isInArena(p:CGPoint) -> Bool { //function to check whether a point is within the arena ellipse
        let a = 1.06 * arena.frame.width / 2 //width of ellipse
        let b = 1.06 * arena.frame.height / 2 //height of ellipse
        
        //convert point p to polar coords
        let r1 = sqrt(pow(p.x - self.frame.midX, 2) + pow(p.y - self.frame.midY, 2))
        let theta = atan2(p.y - self.frame.midY, p.x - self.frame.midX)
        
        let r2 = (a * b) / sqrt((pow(b * cos(theta), 2)) + (pow(a * sin(theta), 2))) //get radius of arena at theta
        
        return r1 <= r2
    }
    
    func initArena() {
        //set up arena elipse
        arena.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        arena.xScale = 0.93 * self.frame.width / arena.frame.width //scale to fit screen
        arena.yScale = 0.93 * (9 / 16) * arena.xScale //width is 9/16 of height
        arena.name = "Arena"
        arena.zPosition = 0
        
        self.addChild(arena)
    }
    
    func initScore() {
        scoreText.position.x = arena.position.x
        scoreText.position.y = arena.position.y +  50
        scoreText.fontColor = SKColor.white
        scoreText.fontSize = 20
        scoreText.text = "Score: \(score)"
        scoreText.name = "score"
        scoreText.zPosition = 1
        
        self.addChild(scoreText)
    }
    
    func initBalls() {
       //add initial ball to array
        let startBall = Ball(pos: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 50), charge: -1)
        startBall.zPosition = 4
        
        self.addChild(startBall)
        
        balls.append(startBall)
        
        self.run(SKAction.repeatForever(SKAction.sequence([ //add new ball every 15 seconds
            SKAction.wait(forDuration: 5.0),
            SKAction.run{
                //add new ball near center
                let newBall = Ball(pos: CGPoint(x: self.frame.width / 2 + CGFloat(arc4random() % 100) - 50, y: self.frame.height / 2 + CGFloat(arc4random() % 100) - 50),
                    charge: (arc4random() % 2 == 0) ? 1 : -1) //random charge
                self.addChild(newBall)
                self.balls.append(newBall)
            }
        ])))
    }
    
    func initBlackHole() {
        blackHole.position = arena.position
        blackHole.xScale = 0.2
        blackHole.yScale = 0.2
        blackHole.physicsBody = SKPhysicsBody(circleOfRadius: blackHole.size.width / 2)
        blackHole.physicsBody!.mass = 5e5
        blackHole.physicsBody!.restitution = 0.0
        blackHole.physicsBody!.affectedByGravity = false
        blackHole.physicsBody!.isDynamic = false
        blackHole.name = "BlackHole"
        blackHole.zPosition = 2
        
        self.addChild(blackHole)
    }
    
    func initTargetSpawner() {
        //create path for targets to follow
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: arena.position.x - (arena.frame.width / 2), y: arena.position.y - (arena.frame.height / 2), width: arena.frame.width, height: arena.frame.height))
        //set up spawner for targets
        self.run(SKAction.repeat(SKAction.sequence([
            SKAction.run{ //target spawner
                let target = SKSpriteNode(imageNamed: "Target")
                target.size = CGSize(width: 14, height: 52)
                target.physicsBody = SKPhysicsBody(rectangleOf: target.frame.size)
                target.physicsBody!.restitution = 1.0
                target.physicsBody!.affectedByGravity = false
                target.physicsBody!.isDynamic = false
                target.physicsBody!.categoryBitMask = 0xF //make targets not collide with other targets
                target.physicsBody!.collisionBitMask = 0xF0
                target.zPosition = 2
                target.name = "Target"
            
                self.addChild(target)
            
                target.run(SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: true, duration: 5.0)))
            },
            SKAction.wait(forDuration: 1.0 / 2.0)
        ]), count: 10)) //TEMP NEEDS BALANCING
    }
    
    func didBegin(_ contact: SKPhysicsContact) { //contact delegate
        if (contact.bodyA.node?.name ?? "") == "Target" || (contact.bodyB.node?.name ?? "") == "Target" { //if ball hits target
            let target:SKSpriteNode
            let ball:Ball
            
            //decide whice body is the ball and which is the target
            if (contact.bodyA.node?.name ?? "") == "Ball" {
                ball = contact.bodyA.node! as! Ball
                target = contact.bodyB.node! as! SKSpriteNode
            } else {
                target = contact.bodyA.node! as! SKSpriteNode
                ball = contact.bodyB.node! as! Ball
            }
            
            blackHole.physicsBody!.mass = 5e5 //reset black hole mass
            //forceManager.gravOn = false
            
            //remove ball on contact
            ball.removeFromParent()
            balls.remove(at: balls.index(of: ball)!) //remove from balls array
            
            target.run(SKAction.sequence([ //make target invisible and stop collisions for ? full rotations (? * 5 secs) then put it back
                SKAction.run{
                    target.alpha = 0.0
                    target.physicsBody!.categoryBitMask = 0x0
                    target.physicsBody!.collisionBitMask = 0x00
                },
                SKAction.wait(forDuration: 10),
                SKAction.run{
                    target.alpha = 1.0
                    target.physicsBody!.categoryBitMask = 0xF
                    target.physicsBody!.collisionBitMask = 0xF0
                }
            ]))
            score += 1
            scoreText.text = "Score: \(score)" //increment score
            
            //play ball on target sound
            if Globals.soundOn {
                self.run(SKAction.playSoundFileNamed("BallOnTarget", waitForCompletion: false))
            }
            
            //add new ball near center
            let newBall = Ball(pos: CGPoint(x: self.frame.width / 2 + CGFloat(arc4random() % 100) - 50, y: self.frame.height / 2 + CGFloat(arc4random() % 100) - 50),
                charge: (arc4random() % 2 == 0) ? 1 : -1) //random charge
            self.addChild(newBall)
            balls.append(newBall)
        }
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor.black
        self.physicsWorld.gravity.dy = 0
        self.physicsWorld.contactDelegate = self
        
        self.initArena()
        self.initScore()
        self.initTargetSpawner()
        self.initBalls()
        self.initBlackHole()
    }
    
    override func willMove(from view: SKView) {
        self.removeAllChildren()
        self.removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        for var touch:AnyObject in touches {
            if arena.contains((touch as! UITouch).location(in: self)) {
                if isInArena(p: (touch as! UITouch).location(in: self)) {
                    blackHole.position = (touch as! UITouch).location(in: self)
                    forceManager.gravOn = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for var touch:AnyObject in touches {
            if arena.contains((touch as! UITouch).location(in: self)) {
                if isInArena(p: (touch as! UITouch).location(in: self)) {
                    blackHole.position = (touch as! UITouch).location(in: self)
                    forceManager.gravOn = true
                }
            }
        }
    }
    
    func checkBounds() { //if any ball leaves the arena, delete it
        for ball in balls { //nemerical for loop to have access to current ball's index
            if !isInArena(p: ball.position) {
                ball.removeFromParent()
                balls.remove(at: balls.index(of: ball)!)
            }
        }
    }
   
    override func update(_ currentTime: CFTimeInterval) {
        if blackHole.physicsBody!.mass >= 1000 { //reduce black hole mass
            blackHole.physicsBody!.mass -= 1000
            blackHole.alpha = blackHole.physicsBody!.mass / 5e5
        } else { //reset if mass == 0
            let scene = PlayAgainScene(size: self.size)
            
            scene.userData = [:]
            scene.userData!.setObject(score, forKey: "Score" as NSCopying) //pass score on to play again scene with userData dictionary
            
            self.view?.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
        }
        
        forceManager.handleGravity(balls: balls)
        
        for ball in balls { //update all balls
            ball.update()
        }
        
        checkBounds() //delete balls that have left the arena
        
        if balls.count == 0 { //reset if there are no balls left
            let scene = PlayAgainScene(size: self.size)
            
                //forward gamecenter data through scenes
            scene.userData = [:]
            scene.userData!.setObject(score, forKey: "Score" as NSCopying) //pass score on to play again scene with userData dictionary
            
            self.view?.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
        }
    }
}

