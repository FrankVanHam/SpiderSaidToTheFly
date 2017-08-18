//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {
    
    private var returnScene: SKScene?
    
    init(size: CGSize, returnScene: SKScene) {
        self.returnScene = returnScene
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        self.addCenterLabel(text: "You beat the spider", aligmnent: .bottom, size: 20)
        self.addCenterLabel(text: "Touch the screen to start all over", aligmnent: .top, size: 12)
    }
    
    private func addCenterLabel(text: String, aligmnent: SKLabelVerticalAlignmentMode, size: CGFloat) {
        let label = SKLabelNode(text: text)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = aligmnent
        label.fontSize = 20
        label.fontColor = UIColor.white
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(label)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let skView = self.view as SKView!
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        //gameScene.scaleMode = .aspectFill
        skView?.presentScene(self.returnScene!, transition: transition)
    }

}
