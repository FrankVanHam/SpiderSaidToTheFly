//
//  GameViewController.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 14/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameViewController: UIViewController {

    private var motionManager = CMMotionManager()
    private var queue = OperationQueue()
    
    private var gameScene: GameScene!
    private var game: Game!
    private var isRunning = false
    private var gravityAngle: NAngle!
    private var spiderPos: WebPathPosition!
    private var spiderSpeed: SpeedControl!
    private var flyPos: WebPathPosition!
    private var flySpeed: SpeedControl!
    
    private var isDebugging = false
    private var spiderLabel: UILabel?
    private var spiderSlider: UISlider?
    private var flyLabel: UILabel?
    private var flySlider: UISlider?
    private var levelLabel: UILabel?
    private var levelSlider: UISlider?
    
    private var drumBeat = TimeInterval(0.2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameOn()
        
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        if isDebugging {
            self.setupDebug()
        }
        self.gotoStartupScene()
    }
    
    private func gameOn() {
        let max = self.determineMaxLevels()
        if game == nil {
            let g = Game.retrieve()
            if g != nil {
                game = g
            } else {
                game = Game(maxLevels: max, lives: 3)
            }
        }
        game.setMaxLevels(max)
        if game.isEnded() {
            game.reset()
        }
    }
    
    private func determineMaxLevels() -> Int{
        var maxi = 0
        let files = Bundle.main.paths(forResourcesOfType: "svg", inDirectory: "Paths.bundle")
        for file in files {
            let url = URL(fileURLWithPath: file)
            let name = url.deletingPathExtension().lastPathComponent
            if name.contains("level") {
                let nrIndex = name.index(name.startIndex, offsetBy: 5)
                let nrStr = name.substring(from: nrIndex)
                if let nr = Int(nrStr) {
                    maxi = max(nr, maxi)
                }
            }
        }
        return maxi
    }

    func startup() {
        self.bootMotion()
        
        gameScene = GameScene(size: view.bounds.size,
                              startCallback: self.startLoop,
                              collisionCallback: self.collisionDetected)
        gameScene.scaleMode = .aspectFill
        self.gotoNextScene()
    }
    
    func resetPressed(_ sender: UIButton) {
        game.syncWithScene(scene: gameScene)
        self.resetPositions()
    }
    
    func spiderValueChanged(_ sender: UISlider) {
        let speed = CGFloat(Float(sender.value))
        self.levelSettings().spiderSpeed = speed
        self.spiderSpeed = SpeedControl(maxSpeed: self.levelSettings().spiderSpeed, speed: self.levelSettings().spiderSpeed)
        self.updateSpeedLabels()
    }
    
    func flyValueChanged(_ sender: UISlider) {
        let speed = CGFloat(Float(sender.value))
        self.levelSettings().flySpeed = speed
        self.flySpeed = SpeedControl(maxSpeed: self.levelSettings().flySpeed, speed: self.levelSettings().flySpeed)
        self.updateSpeedLabels()
    }
    
    func levelValueChanged(_ sender: UISlider) {
        let level = Int(sender.value)
        game.setLevel(level)
        self.levelLabel!.text = "Level \(game.level())"
    }
    
    private func updateSpeedLabels() {
        if !isDebugging {return}
        self.spiderSlider!.value = Float(self.levelSettings().spiderSpeed)
        self.flySlider!.value = Float(self.levelSettings().flySpeed)
        self.spiderLabel!.text = "Spider \(Int(self.levelSettings().spiderSpeed))"
        self.flyLabel!.text = "Fly \(Int(self.levelSettings().flySpeed))"
    }
    
    private func startLevel() {
        if self.game!.isEnded() {
            self.game!.reset()
            self.game!.save()
        }
        game.syncWithScene(scene: gameScene)
        self.updateSpeedLabels()
        self.resetPositions()
        
        let skView = self.view as! SKView
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        skView.presentScene(gameScene, transition: transition)
    }
    
    private func startLoop() {
        isRunning = true
        self.loop()
    }
    
    private func loop() {
        if !isRunning {return}
        self.winDetect()
        
        if !isRunning {return}
        self.advancePositions()
        gameScene.updatePositions(flyPos: flyPos, spiderPos: spiderPos, interval: drumBeat, callback: self.loop)
        gameScene.updateSpeedLabel(self.flySpeed)
    }
    
    private func advancePositions() {
        self.updateFlySpeed()
        self.updatePathPosition(speed: self.flySpeed, pos: self.flyPos)
        self.updatePathPosition(speed: self.spiderSpeed, pos: self.spiderPos)
    }
    
    private func updateFlySpeed() {
        let path = game.path!
        let pathAngle = path.angleAt(self.flyPos)
        let angDif = gravityAngle.difference(pathAngle)
        //print("path:",pathAngle.degreeValue(), "gravity", self.gravityAngle.degreeValue(), " dif:", angDif.degreeValue())
        
        let angValue = angDif.absolute().degreeValue()
        if angValue < 90 {
            self.flySpeed.throttle((90-angValue)/90)
        } else {
            let perpAngValue = 180-angValue
            self.flySpeed.throttle(-(90-perpAngValue)/90)
        }
    }
    
    private func updatePathPosition(speed: SpeedControl, pos: WebPathPosition) {
        let dist = speed.moveDistanceIn(drumBeat)
        if abs(Float(dist)) > 1.0 {
            //let tDif = speed.advance(current: currentTime)
            let path = game.path!
            let newPos = path.movePosition(pos, moveDist: dist)
            pos.copyFrom(newPos)
        }
    }
    
    private func resetPositions() {
        let path = game.path!
        let set = self.levelSettings()
        self.spiderSpeed = SpeedControl(maxSpeed: set.spiderSpeed, speed: set.spiderSpeed)
        self.spiderPos = path.firstPosition()
        self.flySpeed = SpeedControl(maxSpeed: set.flySpeed, speed: set.flySpeed)
        let relDist = path.length() * set.flyPosition
        self.flyPos = path.positionForDistance(relDist)
        gameScene.setPositions(flyPos: self.flyPos, spiderPos: self.spiderPos)
    }
    
    func collisionDetected() {
        isRunning = false
        gameScene.animateEaten(callback: self.lose)
    }
    
    private func winDetect() {
        if self.flyPos!.isAtEnd() {
            isRunning = false
            gameScene.ignoreCollision()
            self.won()
        }
    }
    
    private func won() {
        self.isRunning = false
        self.game!.won()
        self.game!.save()
        if self.game!.isEnded() {
            self.animateEnd()
        } else {
            self.animateWin()
        }
    }
    private func lose() {
        self.isRunning = false
        self.game!.lose()
        if self.game!.over() {
            self.gameOver()
        } else {
            self.tryAgain()
        }
    }
    
    private func gameOver() {
        let skView = self.view as! SKView
        let scene = GameOverScene(size: (skView.bounds.size), callback: self.gotoNextScene)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: transition)
    }
    
    private func tryAgain() {
        let skView = self.view as! SKView
        let scene = TryAgainScene(size: (skView.bounds.size), callback: self.gotoNextScene)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: transition)
    }

    private func animateWin() {
        gameScene.animateWin(callback: self.gotoWonScene)
    }
    
    private func animateEnd() {
        gameScene.animateEnd(callback: self.gotoEndScene)
    }
    
    private func gotoWonScene() {
        let scene = WonScene(size: (view.bounds.size), callback: self.gotoNextScene)
        self.transitionScene(scene: scene)
    }
    
    private func gotoEndScene() {
        let scene = EndScene(size: (view.bounds.size), callback: self.gotoNextScene)
        self.transitionScene(scene: scene)
    }
    
    private func gotoNextScene() {
        let scene = NextScene(size: (view.bounds.size), callback: self.startLevel)
        scene.setGame(game)
        self.transitionScene(scene: scene)
    }
    
    private func gotoCreditsScene() {
        let scene = CreditsScene(size: (view.bounds.size), callback: self.gotoStartupScene)
        self.transitionScene(scene: scene)
    }
    
    private func gotoStartupScene() {
        let scene = StartupScene(size: view.bounds.size, callback: self.startup, creditCallback: self.gotoCreditsScene)
        self.transitionScene(scene: scene)
    }
    
    private func transitionScene(scene: SKScene) {
        let skView = self.view as! SKView
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: transition)
    }
    
    private func bootMotion() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: handleMove)
        }
        else {
            print("motion not supported")
            gravityAngle = NAngle(CGFloat(Double.pi * -0.5))
        }
    }
    
    func handleMove(motion: CMDeviceMotion?, error: Error?) {
        if let gravity = motion?.gravity {
            let rotation = atan2(gravity.y, gravity.x)
            gravityAngle = NAngle(CGFloat(rotation))
        }
    }
    
    private func levelSettings() -> LevelSettings{
        return game.settings
    }
    
    private func setupDebug() {
        let b = UIButton(frame: CGRect(x: 20, y: 20, width: 100, height: 50))
        b.setTitle("Reset", for: .normal)
        b.backgroundColor = .gray
        b.addTarget(self, action: #selector(self.resetPressed), for: .touchUpInside)
        self.view.addSubview(b)
        
        spiderLabel = UILabel(frame: CGRect(x: 0, y: 70, width: 100, height: 50))
        self.view.addSubview(spiderLabel!)
        spiderSlider = UISlider(frame: CGRect(x: 110, y: 70, width: 200, height: 50))
        spiderSlider!.value = 10
        spiderSlider!.minimumValue = 0
        spiderSlider!.maximumValue = 300
        spiderSlider!.addTarget(self, action: #selector(self.spiderValueChanged), for: .valueChanged)
        self.view.addSubview(spiderSlider!)
        
        flyLabel = UILabel(frame: CGRect(x: 0, y: 120, width: 100, height: 50))
        self.view.addSubview(flyLabel!)
        flySlider = UISlider(frame: CGRect(x: 110, y: 120, width: 200, height: 50))
        flySlider!.value = 10
        flySlider!.minimumValue = 0
        flySlider!.maximumValue = 300
        flySlider!.addTarget(self, action: #selector(self.flyValueChanged), for: .valueChanged)
        self.view.addSubview(flySlider!)
        
        levelLabel = UILabel(frame: CGRect(x: 0, y: 170, width: 100, height: 50))
        self.view.addSubview(levelLabel!)
        levelSlider = UISlider(frame: CGRect(x: 110, y: 170, width: 200, height: 50))
        levelSlider!.value = 1
        levelSlider!.minimumValue = 1
        let max = self.determineMaxLevels()
        levelSlider!.maximumValue = Float(max)
        levelSlider!.addTarget(self, action: #selector(self.levelValueChanged), for: .valueChanged)
        self.view.addSubview(levelSlider!)
        
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
