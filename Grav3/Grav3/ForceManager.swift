import SpriteKit

class ForceManager {
    let blackHole:SKSpriteNode? //references to scene's black hole's and balls
    
    let G:CGFloat = 6.673 //universal gravitation constant
    
    var gravOn:Bool = true //gravity turns off temporarily after target is hit
    
    init(blackHole: SKSpriteNode?) {
        self.blackHole = blackHole
    }
    
    convenience init() { //allow force manager with no black hole
        self.init(blackHole: nil)
    }
    
    func handleGravity(balls: [Ball]) { //handle gravity between balls and black hole
        for var ball1 in balls { //loop through all balls
            for var ball2 in balls { //balls repel eachother
                if ball1 !== ball2 { //ball doesn't apply force on self
                    let distance = sqrt(pow(ball1.position.x - ball2.position.x, 2) + pow(ball1.position.y - ball2.position.y, 2)) //distance between two objects
                    let dir = atan2(ball1.position.y - ball2.position.y, ball1.position.x - ball2.position.x) //force vec's direction
                    let mag = CGFloat(ball1.charge * ball2.charge) * 1e3 * (G * ball1.physicsBody!.mass * ball2.physicsBody!.mass) / pow(distance, 2) //get magnitude of vec w/ universal gravitation equation
                    let forceVec = CGVector(dx: mag * cos(dir), dy: mag * sin(dir)) //create force vec by converting from polar to cartesian coords
                    
                    ball1.physicsBody!.applyForce(forceVec) //apply the force vector
                }
            }
            
            //black hole also applies gravity
            if let bh = blackHole {
                if gravOn {
                    let distance = sqrt(pow(ball1.position.x - bh.position.x, 2) + pow(ball1.position.y - bh.position.y, 2)) //distance between two objects
                    let dir = atan2(ball1.position.y - bh.position.y, ball1.position.x - bh.position.x) //force vec's direction
                    let mag = -(G * ball1.physicsBody!.mass * bh.physicsBody!.mass) / pow(distance, 2) //get magnitude of vec w/ universal gravitation equation
                    let forceVec = CGVector(dx: mag * cos(dir), dy: mag * sin(dir)) //create force vec by converting from polar to cartesian coords
            
                    ball1.physicsBody!.applyForce(forceVec) //apply force vector
                }
            }
        }
    }
}
