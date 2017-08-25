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
    
    func addCenterLabels( mains: [String], subs: [String]) {
        let (big, small) = self.figureFontSizes()
        var runningY = self.frame.midY
        for main in mains {
            runningY = self.addLabel( text: main, y: runningY, size: big )
        }
        for sub in subs {
            runningY = self.addLabel( text: sub, y: runningY, size: small )
        }
    }
    
    func addLabel(text: String, y: CGFloat, size: CGFloat) -> CGFloat {
        let label = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        label.text = text
        label.horizontalAlignmentMode = .center
        label.fontSize = size
        label.fontColor = UIColor.black
        label.position = CGPoint(x: self.frame.midX, y: y)
        self.addChild(label)
        return y - size - 5.0
    }
    
    private func figureFontSizes() -> (CGFloat, CGFloat) {
        let width = size.width
        print(width)
        switch width {
            case 0..<320-1:   return (20, 10)
            case 320..<375-1: return (24, 12)
            case 375..<414-1: return (26, 13)
            case 414..<768-1: return (28, 14)
            default: return (32,16)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        callback()
    }

}
