//
//  GameScene.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 14/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    private var spider : SKSpriteNode?
    private var spiderPos: WebPathPosition?
    private var spiderSpeed: SpeedControl?
    private var fly : SKSpriteNode?
    private var flyPos: WebPathPosition?
    private var flySpeed: SpeedControl?
    private var manager = CMMotionManager()
    private var queue = OperationQueue()
    private var path = WebPath()
    private var gravityAngle = NAngle(CGFloat(Double.pi * -0.5))
    private var running = false
    private var lifeCount = 3
    private var level = 1
    private var maxLevels = 0
    private var levelSettings: LevelSettings?
    private var speedLabel : SKLabelNode?
    private var levelLabel : SKLabelNode?
    private var livesLabel : SKLabelNode?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.determineMaxLevels()
        self.buildBackground()
        self.loadDefaultPath()
        self.addPath()
        
        self.spider = SKSpriteNode(imageNamed: "spider")
        self.addChild(self.spider!)
        
        self.fly = SKSpriteNode(imageNamed: "fly")
        self.addChild(self.fly!)
        
        self.lifeCount = 3
        self.bootMotion()
    }
    
    private func determineMaxLevels() {
        var maxi = 0
        let files = Bundle.main.paths(forResourcesOfType: "svg", inDirectory: "Paths.bundle")
        for file in files {
            let url = URL(fileURLWithPath: file)
            let name = url.deletingPathExtension().lastPathComponent
            if name.contains("level") {
                let nrIndex = name.index(name.startIndex, offsetBy: 6)
                let nrStr = name.substring(from: nrIndex)
                if let nr = Int(nrStr) {
                    maxi = max(nr, maxi)
                }
            }
        }
        self.maxLevels = maxi
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.animateStart()
        self.resetPositions()
        self.updateStats()
        self.resetForGameOver()
        self.spider!.position = self.spiderPos!.point()
        self.fly!.position = self.flyPos!.point()
        
        self.animateStart()
        super.didMove(to: view)
    }
    
    private func animateStart() {
        let centerPosition = CGPoint(x: self.size.width/2, y: self.size.height/2)
        let dur = 0.8
        for i in 0..<3 {
            let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
            scoreLabel.isHidden = true
            scoreLabel.fontSize = 20
            scoreLabel.fontColor = .blue
            scoreLabel.text = String(3-i)
            scoreLabel.position = centerPosition
            self.addChild(scoreLabel)
            let moveAction = SKAction.move(by: CGVector(dx: 0, dy: self.size.height/3), duration: dur)
            moveAction.timingMode = .easeOut
            let myDur = 0.8 * (dur * Double(i))
            let waitAction = SKAction.wait(forDuration: TimeInterval(myDur))
            scoreLabel.run(SKAction.sequence([waitAction, SKAction.unhide(), moveAction, SKAction.removeFromParent()]))
        }
        let myDur = 0.8 * (dur * 3)
        let waitForAll = SKAction.wait(forDuration: myDur)
        self.run(SKAction.sequence([waitForAll, SKAction.run(self.becomeAlive)]))
    }
    
    func becomeAlive() {
        self.running = true
    }
    
    private func resetForLifeLost() {
    }
    
    private func resetForGameOver() {
        self.lifeCount = 3
    }
    
    private func resetPositions() {
        let set = self.levelSettings!
        self.spiderSpeed = SpeedControl(maxSpeed: set.spiderSpeed, speed: set.spiderSpeed)
        self.spiderPos = self.path.firstPosition()
        self.flySpeed = SpeedControl(maxSpeed: set.spiderSpeed, speed: set.flySpeed)
        let relDist = self.path.length() * set.flyPosition
        self.flyPos = self.path.positionForDistance(relDist)
    }
    
    private func buildBackground() {
        self.backgroundColor = SKColor.white
        self.speedLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        self.speedLabel!.fontSize = 16
        self.speedLabel!.fontColor = .black
        self.speedLabel!.horizontalAlignmentMode = .right
        self.speedLabel!.verticalAlignmentMode = .top
        self.speedLabel!.position = CGPoint(x:self.size.width, y:self.size.height)
        self.addChild(self.speedLabel!)
    
        self.livesLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        self.livesLabel!.fontSize = 16
        self.livesLabel!.fontColor = .black
        self.livesLabel!.horizontalAlignmentMode = .left
        self.livesLabel!.verticalAlignmentMode = .top
        self.livesLabel!.position = CGPoint(x:0, y:self.size.height)
        self.addChild(self.livesLabel!)

        self.levelLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        self.levelLabel!.fontSize = 16
        self.levelLabel!.fontColor = .black
        self.levelLabel!.horizontalAlignmentMode = .center
        self.levelLabel!.verticalAlignmentMode = .top
        self.levelLabel!.position = CGPoint(x:self.size.width/2, y:self.size.height)
        self.addChild(self.levelLabel!)
    }
    
    private func updateStats() {
        self.livesLabel!.text = "lives: \(self.lifeCount)"
        self.levelLabel!.text = "level \(self.level)\\\(self.maxLevels)"
    }
    
    private func loadDefaultPath() {
        let levelName = "level\(self.level)"
        
        let pathFile = Bundle.main.path(forResource: levelName, ofType: "svg", inDirectory: "Paths.bundle")
        let gameFile = Bundle.main.path(forResource: levelName, ofType: "json", inDirectory: "Paths.bundle")
        
        self.path = WebPathLoader().pathFromFile(filePath: pathFile!)
        self.levelSettings = LevelSettingsLoader().settingsFromFile(filePath: gameFile!)
    }
    
    private func addPath() {
        var points = self.path.points
        let ball = SKShapeNode(points: &points,
                               count: points.count)
        ball.lineWidth = 1
        ball.strokeColor = .darkGray
        ball.glowWidth = 2
        self.addChild(ball)
    }
    
    private func bootMotion() {
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdates(to: queue, withHandler: handleMove)
        }
        else {
            print("motion not supported")
        }
    }
    
    func handleMove(motion: CMDeviceMotion?, error: Error?) {
        if let gravity = motion?.gravity {
            let rotation = atan2(gravity.y, gravity.x)
            self.gravityAngle = NAngle(CGFloat(rotation))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !self.running {return}
        
        self.moveWithSpeed(speed: self.spiderSpeed!, pos: self.spiderPos!, node: self.spider!, currentTime: currentTime)
        self.updateFlySpeed()
        let s = NSString(format: "%.2f", self.flySpeed!.percentage())
        self.speedLabel!.text = "Speed \(s) %"
        self.moveWithSpeed(speed: self.flySpeed!, pos: self.flyPos!, node: self.fly!, currentTime: currentTime)
        self.collisionDetect()
        self.winDetect()
    }
    
    private func winDetect() {
        if self.flyPos!.isAtEnd() {
            self.won()
        }
    }
    
    private func won() {
        self.running = false
        if self.level == self.maxLevels {
            self.animateEnd()
        } else {
            self.animateWin()
        }
        self.level += 1
    }
    
    private func animateWin() {
        let pos = self.fly!.position
        let moveAction = SKAction.move(by: CGVector(dx: -pos.x, dy: self.size.height-pos.y), duration: 2)
        moveAction.timingMode = .easeIn
        self.fly!.run(SKAction.sequence([moveAction, SKAction.run(self.gotoWonScene)]))
    }
    
    private func animateEnd() {
        let pos = self.fly!.position
        let moveAction = SKAction.move(by: CGVector(dx: -pos.x, dy: self.size.height-pos.y), duration: 2)
        moveAction.timingMode = .easeIn
        self.fly!.run(SKAction.sequence([moveAction, SKAction.run(self.gotoEndScene)]))
    }
    
    private func gotoWonScene() {
        let skView = self.view as SKView!
        let gameScene = WonScene(size: (skView?.bounds.size)!, returnScene: self)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        skView?.presentScene(gameScene, transition: transition)
    }
    
    private func gotoEndScene() {
        let skView = self.view as SKView!
        let gameScene = EndScene(size: (skView?.bounds.size)!, returnScene: self)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        skView?.presentScene(gameScene, transition: transition)
    }
    
    private func collisionDetect() {
        if self.flyPos!.distanceTo(self.spiderPos!) < 5 {
            self.running = false
            let sound = SKAction.playSoundFileNamed("eaten.wav", waitForCompletion: true)
            let wait = SKAction.wait(forDuration: 2)
            let toLose = SKAction.run(self.loselife)
            self.run(SKAction.sequence([sound, wait, toLose]))
        }
    }
    
    private func loselife() {
        self.lifeCount -= 1
        self.updateStats()
        if self.lifeCount == 0 {
            self.gameOver()
        } else {
            self.tryAgain()
        }
    }
    
    private func gameOver() {
        let skView = self.view as SKView!
        let gameScene = GameOverScene(size: (skView?.bounds.size)!, returnScene: self)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        self.resetForGameOver()
        skView?.presentScene(gameScene, transition: transition)
    }
    
    private func tryAgain() {
        let skView = self.view as SKView!
        let gameScene = TryAgainScene(size: (skView?.bounds.size)!, returnScene: self)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        self.resetForLifeLost()
        skView?.presentScene(gameScene, transition: transition)
    }
    
    private func updateFlySpeed() {
        let pathAngle = self.path.angleAt(self.flyPos!)
        let angDif = self.gravityAngle.difference(pathAngle)
        //print("path:",pathAngle.degreeValue(), "gravity", self.gravityAngle.degreeValue(), " dif:", angDif.degreeValue())
    
        let angValue = angDif.absolute().degreeValue()
        if angValue < 90 {
            self.flySpeed!.setSpeed(50*((90-angValue)/90))
        } else {
            let perpAngValue = 180-angValue
            self.flySpeed!.setSpeed(-50*((90-perpAngValue)/90))
        }
    }
    
    private func moveWithSpeed(speed: SpeedControl, pos: WebPathPosition, node: SKSpriteNode, currentTime: TimeInterval) {
        let dist = speed.moveDistance(currentTime)
        if abs(Float(dist)) > 1.0 {
            let tDif = speed.advance(current: currentTime)
            let newPos = self.path.movePosition(pos, moveDist: dist)
            pos.copyFrom(newPos)
            let moveNodeUp = SKAction.move(to: newPos.point(),
                                           duration: tDif)
            node.run(moveNodeUp, withKey: "advance")
        }

    }
}
