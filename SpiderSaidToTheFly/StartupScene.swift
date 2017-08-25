//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class StartupScene: SubScene {
    
    var credit: SKShapeNode?
    var creditCallback: () -> Void
    
    init(size: CGSize, callback: @escaping ()->Void, creditCallback: @escaping ()->Void) {
        self.creditCallback = creditCallback
        super.init(size:size, callback: callback)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        let center = CGPoint( x: size.width/2, y: 3*size.height/4)
        self.setupAnimation(center: center, width: 80 )
        
        self.addCenterLabels(mains: ["Let the game begin"],
                             subs: ["Tilt your device to let the fly slide down the rope.",
                                    "Outrun the spider that is out to get you.",
                                    "",
                                    "Dont drop your device :-)",
                                    "",
                                    "touch the screen to start the game"
            ])
        
        let rect = CGRect(x: size.width/2 - 40, y: 40, width: 80, height: 40)
        credit = SKShapeNode(rect: rect)
        credit?.fillColor = .gray
        
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        label.text = "credits..."
        label.fontSize = 12
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: rect.midX, y: rect.midY)
        self.addChild(label)
        self.addChild(credit!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        // Check if the location of the touch is within the button's bounds
        if credit!.contains(touchLocation) {
            creditCallback()
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
    private func setupAnimation(center: CGPoint, width: Int) {
        let d = width
        var points = [CGPoint(x:-d,y:d), CGPoint(x:d,y:-d)]
        let rope = SKShapeNode(points: &points, count: points.count)
        rope.lineWidth = 1
        rope.strokeColor = .darkGray
        rope.glowWidth = 2
        rope.position = center
        self.addChild(rope)
        
        let fly = SKSpriteNode(imageNamed: "fly")
        let flyAngle = CGFloat(Double.pi/2 + Double.pi/4)
        fly.zRotation = flyAngle
        fly.position = center
        self.addChild(fly)
        
        
        let wait1 = SKAction.wait(forDuration: TimeInterval(1))
        let tilt1 = SKAction.rotate(byAngle: CGFloat(-Double.pi/4), duration: TimeInterval(1))
        let wait2 = SKAction.wait(forDuration: TimeInterval(2))
        let tilt2 = SKAction.rotate(byAngle: CGFloat(Double.pi/4), duration: TimeInterval(0.1))
        let tilt3 = SKAction.rotate(byAngle: CGFloat(Double.pi/2), duration: TimeInterval(0.1))
        let move = SKAction.move(by: CGVector(dx:0, dy:-d), duration: TimeInterval(2))
        let reset = SKAction.group([ SKAction.move(to: center, duration: 0.1),
                                     SKAction.rotate(toAngle: flyAngle, duration: 0.1) ])
        rope.run(SKAction.repeatForever(SKAction.sequence([wait1, tilt1, wait2, tilt2])))
        fly.run(SKAction.repeatForever(SKAction.sequence([wait1, tilt1,
                                                          SKAction.group([move,tilt3]),
                                                          reset])))
    }
}
