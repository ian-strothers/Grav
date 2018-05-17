import SpriteKit

extension SKAction { //convinient new action!
    //time 1.0s
    class func swapText(text: SKLabelNode, to newString: String?) -> SKAction { //returns action sequence to swap text w/ fade
        return SKAction.sequence([ //time = 1.0s
            SKAction.run{
                text.run(SKAction.sequence([ //time = 1.0s
                    SKAction.fadeAlpha(to: 0.0, duration: 0.5),
                    SKAction.run{text.text = newString},
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                    ]))
            },
            SKAction.wait(forDuration: 1.0)
        ])
    }
}

class TutorialScene : SKScene, SKPhysicsContactDelegate {
    let arena = SKSpriteNode(imageNamed: "Arena")
    let scoreText = SKLabelNode(fontNamed: "HoeflerText")
    var balls:[Ball] = []
    let blackHole = SKSpriteNode(imageNamed: "BlackHole")
    let forceManager:ForceManager
    let text = SKLabelNode(fontNamed: "HoeflerText")
    
    var isFading = false //true after fading is introduced
    
    override init(size: CGSize) {
        forceManager = ForceManager(blackHole: blackHole)
        forceManager.gravOn = true
        
        super.init(size: size)
        
        self.backgroundColor = SKColor.black
        self.physicsWorld.gravity.dy = 0
        self.physicsWorld.contactDelegate = self
        
        text.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        text.fontSize = 20
        text.color = SKColor.white
        text.zPosition = 3
        self.addChild(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isInArena(p:CGPoint) -> Bool { //function to check whether a point is within the arena ellipse
        let a = 1.06 * arena.frame.width / 2 //width of ellipse
        let b = 1.06 * arena.frame.height / 2 //height of ellipse
        
        //convert point p to polar coords
        let r1 = sqrt(pow(p.x - self.frame.midX, 2) + pow(p.y - self .frame.midY, 2))
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
    
    //tutorial segments
    //time = 7.5s
    func introBallBHole() -> SKAction {
        return SKAction.sequence([ //time = 9.5s
            SKAction.run{
                self.initArena() //we need these
                self.initBlackHole()
                
                let startBall = Ball(pos: CGPoint(x: self.frame.width / 2 - 50, y: self.frame.height / 2 - 50), charge: -1) //example ball
                startBall.zPosition = 4
                self.addChild(startBall)
                self.balls.append(startBall)
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.swapText(text: text, to: "This is the arena. Your goal is to keep the yellow and red balls within it."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "The balls are attracted to the black dot in the center."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "Move the dot by tapping or dragging it anywhere in the arena."),
            SKAction.run{self.blackHole.position.x += 50;},
            SKAction.wait(forDuration: 2.0)
        ])
    }
    //time = 9.0s
    func introChargeInter() -> SKAction {
        return SKAction.sequence([ //9.0s
            SKAction.run{
                self.blackHole.removeFromParent() //get rid of BH for now
                self.forceManager.gravOn = false
                
                //add 2 new balls
                let b1 = Ball(pos: CGPoint(x: self.frame.width / 2 - 50, y: self.frame.height / 2 - 50), charge: 1)
                let b2 = Ball(pos: CGPoint(x: self.frame.width / 2 + 50, y: self.frame.height / 2 + 50), charge: -1)
                
                self.addChild(b1)
                self.addChild(b2)
                
                self.balls.append(b1)
                self.balls.append(b2)
            },
            SKAction.swapText(text: text, to: "Red and yellow balls interact with each other."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "Differently colored balls attract."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "Balls of the same color repel."),
            SKAction.run{
                //add 2 new balls
                let b1 = Ball(pos: CGPoint(x: self.frame.width / 2 + 50, y: self.frame.height / 2 - 50), charge: 1)
                let b2 = Ball(pos: CGPoint(x: self.frame.width / 2 - 50, y: self.frame.height / 2 + 50), charge: 1)
                
                self.addChild(b1)
                self.addChild(b2)
                
                self.balls.append(b1)
                self.balls.append(b2)
            },
            SKAction.wait(forDuration: 2.0),
        ])
    }
    //time = 3.0s
    func forcesTogether() -> SKAction {
        return SKAction.sequence([ //time = 3.0s
            SKAction.swapText(text: text, to: "These forces work together."),
            SKAction.run{
                self.blackHole.position = self.arena.position
                
                self.addChild(self.blackHole) //put BH back
                self.forceManager.gravOn = true
                
                //add 4 new balls
                let b1 = Ball(pos: CGPoint(x: self.frame.width / 2 - 100, y: self.frame.height / 2 - 100), charge: 1)
                let b2 = Ball(pos: CGPoint(x: self.frame.width / 2 - 100, y: self.frame.height / 2 - 140), charge: -1)
                let b3 = Ball(pos: CGPoint(x: self.frame.width / 2 + 100, y: self.frame.height / 2 + 100), charge: 1)
                let b4 = Ball(pos: CGPoint(x: self.frame.width / 2 + 100, y: self.frame.height / 2 + 140), charge: -1)
                
                self.addChild(b1)
                self.addChild(b2)
                self.addChild(b3)
                self.addChild(b4)
                
                self.balls.append(b1)
                self.balls.append(b2)
                self.balls.append(b3)
                self.balls.append(b4)
            },
            SKAction.wait(forDuration: 3.0)
        ])
    }
    //time = 15.0s
    func introTargets() -> SKAction {
        return SKAction.sequence([ //time = 15.0s
            SKAction.run{
                self.initTargetSpawner()
                
                //add 4 new balls
                let b1 = Ball(pos: CGPoint(x: self.frame.width / 2 - 100, y: self.frame.height / 2 - 100), charge: 1)
                let b2 = Ball(pos: CGPoint(x: self.frame.width / 2 - 100, y: self.frame.height / 2 - 140), charge: -1)
                let b3 = Ball(pos: CGPoint(x: self.frame.width / 2 + 100, y: self.frame.height / 2 + 100), charge: 1)
                let b4 = Ball(pos: CGPoint(x: self.frame.width / 2 + 100, y: self.frame.height / 2 + 140), charge: -1)
                
                self.addChild(b1)
                self.addChild(b2)
                self.addChild(b3)
                self.addChild(b4)
                
                self.balls.append(b1)
                self.balls.append(b2)
                self.balls.append(b3)
                self.balls.append(b4)
            },
            SKAction.swapText(text: text, to: "Hit the orbiting targets to increase your score."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "The targets and balls will destroy each other."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "The destroyed target will eventually reappear."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "A new ball will appear for every target hit."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "New balls will also appear every fifteen seconds."),
            SKAction.run{
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
            },
            SKAction.wait(forDuration: 2.0)
        ])
    }
    //time = 12.0s
    func introLoss() -> SKAction {
        return SKAction.sequence([ //time = 12.0s
            SKAction.swapText(text: text, to: "The black dot loses strength when targets are not hit."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "It will fade away as it weakens"),
            SKAction.run{self.isFading = true},
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "You lose if the dot fades completely or you run out of balls."),
            SKAction.wait(forDuration: 2.0),
            SKAction.swapText(text: text, to: "Good Luck!"),
            SKAction.wait(forDuration: 2.0),
            SKAction.run{ //move straight to GameScreen
                let scene = GameScene(size: self.size)
                
                self.view?.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
            }
        ])
    }
    
    override func didMove(to view: SKView) {
        let back = Button(text: "Back", color: SKColor.yellow) { //button to go to game scene
            //send notification to view controller to show ad
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowAd"), object: nil)
            
            let scene = MenuScene(size: self.size)
            
            self.view?.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
        }
        back.position = CGPoint(x: self.frame.minX + 50, y: 3 * self.frame.minY + 30)
        back.name = "Back Button"
        back.zPosition = 3
        
        self.addChild(back)
        
        self.run(SKAction.sequence([ //time = 46.5s
            introBallBHole(),
            introChargeInter(),
            forcesTogether(),
            introTargets(),
            introLoss()
        ]))
    }
    
    func didBeginContact(contact: SKPhysicsContact) { //contact delegate
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
            
            //add new ball near center
            let newBall = Ball(pos: CGPoint(x: self.frame.width / 2 + CGFloat(arc4random() % 100) - 50, y: self.frame.height / 2 + CGFloat(arc4random() % 100) - 50),
                               charge: (arc4random() % 2 == 0) ? 1 : -1) //random charge
            self.addChild(newBall)
            balls.append(newBall)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        forceManager.handleGravity(balls: balls)
        if self.isFading {
            blackHole.physicsBody!.mass -= 1000
            blackHole.alpha = blackHole.physicsBody!.mass / 5e5
        }
        
        for ball in balls { //update all balls
            ball.update()
        }
        
        for ball in balls { //delete balls as they leave arena
            if !isInArena(p: ball.position) {
                ball.removeFromParent()
                balls.remove(at: balls.index(of: ball)!)
            }
        }
    }
    
    override func willMove(from view: SKView) {
        self.removeAllChildren()
        self.removeFromParent()
    }
}
