//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class StartupScene: SKScene {
    
    private var callback: ()->Void
    
    init(size: CGSize, callback: @escaping ()->Void) {
        self.callback = callback
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        self.addCenterLabel(text: "Tilt your device to let the", aligmnent: .bottom, size: 10)
        self.addCenterLabel(text: "fly slide down the rope.", aligmnent: .top, size: 12)
    }
    
    private func addCenterLabel(text: String, aligmnent: SKLabelVerticalAlignmentMode, size: CGFloat) {
        let label = SKLabelNode(text: text)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = aligmnent
        label.fontSize = size
        label.fontColor = UIColor.white
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(label)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.callback()
    }

}
