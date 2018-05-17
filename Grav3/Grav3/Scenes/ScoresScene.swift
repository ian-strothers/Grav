import Foundation
import SpriteKit
import GameKit

class ScoresScene : SKScene {
    override func didMove(to view: SKView) {
        //send notification to view controller to show GC leaderboards. will return to menu when done
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowLeaderboard"), object: nil)
    }
    
    override func willMove(from view: SKView) {
        self.removeAllChildren()
        self.removeFromParent()
    }
}
