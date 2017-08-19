//
//  GameViewController.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 14/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        let scene = StartupScene(size: view.bounds.size, callback: self.startup)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    func startup() {
        let skView = self.view as! SKView
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: transition)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
