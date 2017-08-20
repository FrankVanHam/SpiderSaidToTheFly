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
    private var path: WebPath!
    private var game: Game!
    private var levelSettings: LevelSettings!
    private var isRunning = false
    private var gravityAngle: NAngle!
    private var spiderPos: WebPathPosition!
    private var spiderSpeed: SpeedControl!
    private var flyPos: WebPathPosition!
    private var flySpeed: SpeedControl!
    
    private var drumBeat = TimeInterval(0.2)
    @IBOutlet weak var spiderLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var spiderSLider: UISlider!
    @IBOutlet weak var flySlider: UISlider!
    @IBOutlet weak var flyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameOn()
    
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        self.showStartup()
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
    
    private func loadPath() {
        let levelName = "level\(self.game!.level())"
        
        let pathFile = Bundle.main.path(forResource: levelName, ofType: "svg", inDirectory: "Paths.bundle")
        let gameFile = Bundle.main.path(forResource: levelName, ofType: "json", inDirectory: "Paths.bundle")
        
        path = WebPathLoader().pathFromFile(filePath: pathFile!)
        path.cleanUp()
        if path.first().y < path.last().y {
            path.flipHorizontal()
        }
        path = gameScene.load(path: path, game: game)
        self.levelSettings = LevelSettingsLoader().settingsFromFile(filePath: gameFile!)
    }

    private func showStartup() {
        let skView = self.view as! SKView
        let scene = StartupScene(size: view.bounds.size, callback: self.startup)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    func startup() {
        self.bootMotion()
        
        gameScene = GameScene(size: view.bounds.size,
                              startCallback: self.startLoop,
                              collisionCallback: self.collisionDetected)
        gameScene.scaleMode = .aspectFill
        self.continueGame()
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        self.resetPositions()
    }
    
    @IBAction func spiderValueChanged(_ sender: UISlider) {
        let speed = CGFloat(Float(sender.value))
        levelSettings.spiderSpeed = speed
        self.updateSpeedLabels()
    }
    
    @IBAction func flyValueChanged(_ sender: UISlider) {
        let speed = CGFloat(Float(sender.value))
        levelSettings.flySpeed = speed
        self.updateSpeedLabels()
    }
    
    private func updateSpeedLabels() {
        self.spiderLabel.text = "Spider \(Int(levelSettings.spiderSpeed))"
        self.flyLabel.text = "Fly \(Int(levelSettings.flySpeed))"
    }
    
    private func continueGame() {
        if self.game!.isEnded() {
            self.game!.reset()
        }
        self.loadPath()
        self.spiderSLider.value = Float(levelSettings.spiderSpeed)
        self.flySlider.value = Float(levelSettings.flySpeed)
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
        let dist = speed.moveDistanceIn(drumBeat)*5
        if abs(Float(dist)) > 1.0 {
            //let tDif = speed.advance(current: currentTime)
            let newPos = path.movePosition(pos, moveDist: dist)
            pos.copyFrom(newPos)
        }
    }
    
    private func resetPositions() {
        let set = self.levelSettings!
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
        let scene = GameOverScene(size: (skView.bounds.size), callback: self.continueGame)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: transition)
    }
    
    private func tryAgain() {
        let skView = self.view as! SKView
        let scene = TryAgainScene(size: (skView.bounds.size), callback: self.continueGame)
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
        let skView = self.view as! SKView
        let scene = WonScene(size: (skView.bounds.size), callback: self.continueGame)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: transition)
    }
    
    private func gotoEndScene() {
        let skView = self.view as! SKView
        let scene = EndScene(size: (skView.bounds.size), callback: self.continueGame)
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
