//
//  GameScene.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 14/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var spider : SKSpriteNode!
    var fly : SKSpriteNode!
    private var speedLabel : SKLabelNode!
    private var levelLabel : SKLabelNode!
    private var livesLabel : SKLabelNode!
    private var pathNode : SKShapeNode!
    private var backgroundMusic: AVAudioPlayer!
    
    let eatenSound = SKAction.playSoundFileNamed("eaten.wav", waitForCompletion: true)
    
    private var startCallback: (()->Void)!
    private var collisionCallback: (()->Void)!
    private var collisionReported = false
    
    init(size: CGSize, startCallback: @escaping ()->Void, collisionCallback: @escaping ()->Void) {
        self.startCallback = startCallback
        self.collisionCallback = collisionCallback
        super.init(size: size)
        
        do {
            if let url = Bundle.main.url(forResource: "flyContinuous", withExtension: "aiff") {
                try backgroundMusic = AVAudioPlayer(contentsOf: url)
                backgroundMusic.numberOfLoops = -1
            }
        } catch {
            backgroundMusic = nil
        }
        self.buildBackground()
        
        self.spider = SKSpriteNode(imageNamed: "spider")
        self.addChild(self.spider!)
        
        self.fly = SKSpriteNode(imageNamed: "fly")
        self.addChild(self.fly!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.animateStart()
        super.didMove(to: view)
    }
    
    func load(path: WebPath, game: Game) -> WebPath {
        path.fitIn(xmin: 10, ymin: 10, xmax: self.size.width-20, ymax: self.size.height-40)
        self.addPath(path)
        self.updateStats(game: game)
        return path
    }
    
    
    func becomeAlive() {
        if (backgroundMusic != nil ) {
            backgroundMusic.play()
        }
        collisionReported = false
        self.startCallback()
    }
    
    private func buildBackground() {
        backgroundColor = SKColor.white
        
        speedLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        speedLabel.fontSize = 16
        speedLabel.fontColor = .black
        speedLabel.horizontalAlignmentMode = .right
        speedLabel.verticalAlignmentMode = .top
        speedLabel.position = CGPoint(x:self.size.width, y:self.size.height)
        self.addChild(speedLabel)
    
        livesLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        livesLabel.fontSize = 16
        livesLabel.fontColor = .black
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .top
        livesLabel.position = CGPoint(x:0, y:self.size.height)
        self.addChild(livesLabel)

        levelLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
        levelLabel.fontSize = 16
        levelLabel.fontColor = .black
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.verticalAlignmentMode = .top
        levelLabel.position = CGPoint(x:self.size.width/2, y:self.size.height)
        self.addChild(levelLabel)
    }
    
    private func updateStats(game: Game) {
        livesLabel.text = "lives: \(game.lives)"
        levelLabel.text = "level \(game.level())\\\(game.maxLevels)"
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !collisionReported {
            if self.distance(p1: self.fly.position, p2: self.spider.position) < 5 {
                collisionReported = true 
                collisionCallback()
            }
        }
        super.update(currentTime)
    }
    
    fileprivate func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xd = p2.x - p1.x
        let yd = p2.y - p1.y
        return sqrt(xd*xd + yd*yd)
    }
    
    private func addPath(_ path: WebPath) {
        if self.pathNode != nil {
            self.pathNode!.removeFromParent()
            self.pathNode = nil
        }
        var points = path.points
        self.pathNode = SKShapeNode(points: &points,
                                    count: points.count)
        self.pathNode!.lineWidth = 1
        self.pathNode!.strokeColor = .darkGray
        self.pathNode!.glowWidth = 2
        self.addChild(self.pathNode!)
    }
    
    func updatePositions(flyPos: WebPathPosition, spiderPos: WebPathPosition, interval: TimeInterval, callback: @escaping ()->Void) {
        let halfPi = CGFloat(Double.pi/2)
        let flyAngle = flyPos.angle().value - halfPi
        let rotateFly = SKAction.rotate(toAngle: flyAngle, duration: interval)
        let moveFly = SKAction.move(to: flyPos.point(), duration: interval)
        fly.run(SKAction.group([rotateFly, moveFly]))
        
        let spiderAngle = spiderPos.angle().value + halfPi
        let rotateSpider = SKAction.rotate(toAngle: spiderAngle, duration: interval)
        let moveSpider = SKAction.move(to: spiderPos.point(), duration: interval)
        let cb = SKAction.run(callback)
        spider.run( SKAction.group( [rotateSpider,
                                     SKAction.sequence([moveSpider, cb]) ]) )
    }
    
    func setPositions(flyPos: WebPathPosition, spiderPos: WebPathPosition) {
        fly.position = flyPos.point()
        spider.position = spiderPos.point()
    }

    func updateSpeedLabel(_ speed: SpeedControl) {
        let s = String(format: "%.0f", speed.percentage())
        speedLabel.text = "Speed \(s) %"
    }
    func animateEaten(callback: @escaping ()->Void) {
        self.stopMusic()
        
        let sound = self.eatenSound
        let wait = SKAction.wait(forDuration: 2)
        let cb = SKAction.run(callback)
        self.run(SKAction.sequence([sound,
                                    wait,
                                    cb]))
    }

    func animateWin(callback: @escaping ()->Void) {
        let pos = self.fly!.position
        let moveAction = SKAction.move(by: CGVector(dx: -pos.x, dy: self.size.height-pos.y), duration: 2)
        moveAction.timingMode = .easeIn
        self.fly!.run(SKAction.sequence([moveAction,
                                         SKAction.run(self.stopMusic),
                                         SKAction.run(callback)]))
    }
    
    func animateEnd(callback: @escaping ()->Void) {
        let pos = self.fly!.position
        let moveAction = SKAction.move(by: CGVector(dx: -pos.x, dy: self.size.height-pos.y), duration: 2)
        moveAction.timingMode = .easeIn
        self.fly!.run(SKAction.sequence([moveAction,
                                         SKAction.run(self.stopMusic),
                                         SKAction.run(callback)]))
    }
    
    private func animateStart() {
        let centerPosition = CGPoint(x: self.size.width/2, y: self.size.height/2)
        let dur = 0.8
        for i in 0..<3 {
            let scoreLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")
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
            
            let fade = SKAction.fadeOut(withDuration: dur)
            let wait = SKAction.sequence([waitAction, SKAction.unhide()])
            let raise = SKAction.sequence([moveAction, SKAction.removeFromParent()])
            scoreLabel.run( SKAction.sequence([wait,
                                               SKAction.group([raise, fade])]))
        }
        let myDur = 0.8 * (dur * 3)
        let waitForAll = SKAction.wait(forDuration: myDur)
        self.run(SKAction.sequence([waitForAll, SKAction.run(self.becomeAlive)]))
    }

    func stopMusic() {
        if (backgroundMusic != nil) {
            backgroundMusic.stop()
        }
    }
    
}
