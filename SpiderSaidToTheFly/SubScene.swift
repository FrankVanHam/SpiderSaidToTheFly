//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class SubScene: SKScene {
    
    private var callback: ()->Void
    
    init(size: CGSize, callback: @escaping ()->Void) {
        self.callback = callback
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCenterLabel(text: String, aligmnent: SKLabelVerticalAlignmentMode, size: CGFloat) {
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        label.text = text
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = aligmnent
        label.fontSize = 20
        label.fontColor = UIColor.black
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(label)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        callback()
    }

}
