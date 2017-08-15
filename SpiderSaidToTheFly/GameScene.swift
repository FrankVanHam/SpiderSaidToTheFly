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
    private var gravityAngle = NAngle(CGFloat(Double.pi * 0.5))
    
    private var speedLabel : SKLabelNode?
    
    override func didMove(to view: SKView) {
        self.buildBackground()
        self.loadDefaultPath()
        self.addPath()
        
        self.spider = SKSpriteNode(imageNamed: "spider")
        self.spiderPos = self.path.firstPosition()
        self.spiderSpeed = SpeedControl(10)
        self.spider!.position = self.spiderPos!.point()
        self.addChild(self.spider!)
        
        self.fly = SKSpriteNode(imageNamed: "fly")
        self.flySpeed = SpeedControl(0)
        self.flyPos = self.path.positionForDistance(self.path.length()*0.1)
        self.fly!.position = self.flyPos!.point()
        self.addChild(self.fly!)
        
        self.bootMotion()
    }
    
    private func buildBackground() {
        self.backgroundColor = SKColor.white
        self.speedLabel = SKLabelNode(text: "Speed: 0%")
        self.speedLabel!.fontColor = .black
        self.speedLabel!.horizontalAlignmentMode = .right
        self.speedLabel!.verticalAlignmentMode = .top
        self.speedLabel!.position = CGPoint(x:self.size.width, y:self.size.height)
        self.addChild(self.speedLabel!)
    }
    
    private func loadDefaultPath() {
        path.empty()
        path.addPoint(CGPoint(x:50,y:300))
        path.addPoint(CGPoint(x:150,y:150))
        path.addPoint(CGPoint(x:50,y:50))
    }
    
    private func addPath() {
        var points = self.path.points
        let ball = SKShapeNode(points: &points,
                               count: points.count)
        ball.lineWidth = 1
        ball.strokeColor = .black
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
            let pi = Double.pi
            let rotation = atan2(gravity.y, gravity.x)
            self.gravityAngle = NAngle(CGFloat(rotation))
        }
    }
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        self.moveWithSpeed(speed: self.spiderSpeed!, pos: self.spiderPos!, node: self.spider!, currentTime: currentTime)
        self.updateFlySpeed()
        self.speedLabel!.text = "Speed " + String(describing: self.flySpeed!.speed)
        self.moveWithSpeed(speed: self.flySpeed!, pos: self.flyPos!, node: self.fly!, currentTime: currentTime)
    }
    
    private func updateFlySpeed() {
        let pathAngle = self.path.angleAt(self.flyPos!)
        let angDif = self.gravityAngle.difference(pathAngle)
        print("path:",pathAngle.degreeValue(), "gravity", self.gravityAngle.degreeValue(), " dif:", angDif.degreeValue())
    
        let angValue = angDif.absolute().degreeValue()
        if angValue < 90 {
            self.flySpeed!.setSpeed(10*((90-angValue)/90))
        } else {
            let perpAngValue = 180-angValue
            self.flySpeed!.setSpeed(-10*((90-perpAngValue)/90))
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
