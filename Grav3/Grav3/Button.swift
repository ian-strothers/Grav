//
//  Button.swift
//  Grav
//
//  Created by ian on 7/14/15.
//  Copyright © 2015 ian. All rights reserved.
//

import SpriteKit

class Button: SKNode {
    let onPress: () -> Void
    
    init(text:String, color:SKColor, onComplete: @escaping () -> Void) {
        onPress = onComplete //set func to be run on button press
        
        //set up the text
        let label = SKLabelNode(fontNamed: "HoeflerText-BlackItalic")
        label.text = text
        label.fontColor = SKColor.black
        label.fontSize = 15
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1
        
        //set up button
        let button = SKSpriteNode(imageNamed: "ResizableButton")
        button.color = color
        button.colorBlendFactor = 0.9
        button.centerRect = CGRect(x: 0.42, y: 0.42, width: 0.14, height: 0.14)
        button.xScale = label.frame.width / button.frame.width + 0.3 //txtWidth = x(btnWidth); txtWidth/btnWidth = x; x = scaleFactor
        button.yScale = label.frame.height / button.frame.height + 0.2
        button.zPosition = 0
        
        super.init()
        
        self.isUserInteractionEnabled = true //allow touch events
        
        self.addChild(button)
        self.addChild(label)
    }
    
    init(img: SKSpriteNode, onComplete: @escaping () -> Void) {
        onPress = onComplete
        
        super.init()
        
        self.isUserInteractionEnabled = true //allow touch events
        
        self.addChild(img)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //log and run OnPress when button is pressed
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Button \(self.name!) pressed.")
        onPress()
    }
}
