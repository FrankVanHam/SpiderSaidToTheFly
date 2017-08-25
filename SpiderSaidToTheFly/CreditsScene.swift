//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class CreditsScene: SubScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        self.addCenterLabels(mains: ["Credits"], subs: self.credits())
//        let txt = UITextView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height/2))
//        txt.font = UIFont(name: "ChalkboardSE-Regular", size: 12)
//        txt.allowsEditingTextAttributes = false
//        txt.isEditable = false
//        txt.backgroundColor = .white
//        txt.text = self.credits()
//        view.addSubview(txt)
    }
    
    private func credits() -> [String] {
        return ["Icon of fly by Freepik from www.flaticon.com",
        "spider on launchscreen by Roundicons from www.flaticon.com",
        "fly on launchscreen by Freepik from www.flaticon.com",
        "game spider from https://icons8.com/icon/1652/Spider",
        "game fly by Freepik from www.flaticon.com",
        "bite sound by j1987 from https://freesound.org",
        "beep sound by pan14 from https://freesound.org",
        "backgroundmusic by carpuzi from freesound.org"]
    }
}
