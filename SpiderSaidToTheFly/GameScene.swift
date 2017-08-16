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
    
    private var speedLabel : SKLabelNode?
    
    override func didMove(to view: SKView) {
        self.buildBackground()
        self.loadDefaultPath()
        self.addPath()
        
        self.spider = SKSpriteNode(imageNamed: "spider")
        self.spiderPos = self.path.firstPosition()
        self.spiderSpeed = SpeedControl(maxSpeed: 10, speed: 10)
        self.spider!.position = self.spiderPos!.point()
        self.addChild(self.spider!)
        
        self.fly = SKSpriteNode(imageNamed: "fly")
        self.flySpeed = SpeedControl(maxSpeed: 10, speed: 0)
        self.flyPos = self.path.positionForDistance(self.path.length()*0.5)
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
        let filePath = Bundle.main.path(forResource: "path", ofType: "svg", inDirectory: "Paths.bundle")
        do {
            let content = try String.init(contentsOfFile: filePath!, encoding: String.Encoding.utf8 )
            let range  = content.range(of: "path", options: NSString.CompareOptions.caseInsensitive)
            
            let quote1Range = content.range(of: "\"", options: NSString.CompareOptions.caseInsensitive, range: range!.lowerBound..<content.endIndex)
            let newStart = content.index(quote1Range!.lowerBound, offsetBy: 1)
            let quote2Range = content.range(of: "\"", options: NSString.CompareOptions.caseInsensitive, range: newStart..<content.endIndex)
            //let newEnd = content.index(quote2Range!.lowerBound, offsetBy: 1)
            
            let pathString = content[newStart..<quote2Range!.lowerBound]
            print(pathString)
            let separators = CharacterSet(charactersIn: "MlLhHvVcCsSQqTtAaZz")
            var scanIndex = pathString.startIndex
            var endOfPath = false
            repeat {
                let sepStartRange = pathString.rangeOfCharacter(from: separators, range: scanIndex..<pathString.endIndex)
                if (sepStartRange != nil) {
                    scanIndex = pathString.index(after:sepStartRange!.lowerBound)
                    let charRange = sepStartRange!.lowerBound..<scanIndex
                    let char = pathString.substring(with: charRange)
                    let sepEndRange = pathString.rangeOfCharacter(from: separators, range: scanIndex..<pathString.endIndex)
                    var pieceString: String
                    if (sepEndRange != nil) {
                        pieceString = pathString[scanIndex..<sepEndRange!.lowerBound]
                    } else {
                        endOfPath = true
                        pieceString = pathString[scanIndex..<pathString.endIndex]
                    }
                    var xString = ""
                    var yString = ""
                    var commaIndex = pieceString.startIndex
                    repeat {
                        xString = ""; yString = ""
                        let xrange = pieceString.range(of: ",", range: commaIndex..<pieceString.endIndex)
                        if xrange != nil {
                            xString = pieceString[commaIndex..<xrange!.lowerBound]
                            commaIndex = pieceString.index(after:xrange!.lowerBound)
                            let yrange = pieceString.range(of: ",", range: commaIndex..<pieceString.endIndex)
                            if yrange != nil {
                                yString = pieceString[commaIndex..<yrange!.lowerBound]
                            } else {
                                yString = pieceString[commaIndex..<pieceString.endIndex]
                            }
                        }
                        
                        if (yString != "") {
                            let x : Int? = Int(xString)
                            let y : Int? = Int(yString)
                            if (x != nil) && (y != nil) {
                                switch char {
                                case "M":
                                    path.addPoint(CGPoint(x: x!,y: y!))
                                case "l":
                                    let last = path.last()
                                    path.addPoint(CGPoint(x: Int(last.x) + x!, y: Int(last.y) + y!))
                                    print( Int(last.x) + x!,  Int(last.y) + y!)
                                case "L":
                                    path.addPoint(CGPoint(x: x!,y: y!))
                                default:
                                    path.addPoint(CGPoint(x: x!,y: y!))
                                }
                            }
                        }
                        
                    } while (yString != "")
                    if !endOfPath {
                        scanIndex = sepEndRange!.lowerBound
                    }
                } else {
                    endOfPath = true
                }
            } while (!endOfPath)
            
            //let pieceEnd = pathString.index(sepEndRange!.lowerBound, offsetBy: 1)
            
//            var runningPoint: CGPoint
//            for pieceOfString in elements {
//                let index = pieceOfString.index(0, offsetBy: 1)
//                let char = pieceOfString[index]
//                switch char {
//                    case "M":
//            }
            
            //let commaRange = content.range(of: ",", options: NSString.CompareOptions.caseInsensitive, range: isRange)
            
            //print(commaRange!.lowerBound)
            //print(isRange!.lowerBound..<commaRange!.lowerBound)
        }  catch {
            path.addPoint(CGPoint(x:50,y:300))
            path.addPoint(CGPoint(x:150,y:150))
            path.addPoint(CGPoint(x:50,y:50))
        }
        path.fitIn(xmin: 10, ymin: 10, xmax: self.size.width-20, ymax: self.size.height-40)
        if path.first().y < path.last().y {
            path.flipHorizontal()
        }

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
        let s = NSString(format: "%.2f", self.flySpeed!.percentage())
        self.speedLabel!.text = "Speed \(s) %"
        self.moveWithSpeed(speed: self.flySpeed!, pos: self.flyPos!, node: self.fly!, currentTime: currentTime)
    }
    
    private func updateFlySpeed() {
        let pathAngle = self.path.angleAt(self.flyPos!)
        let angDif = self.gravityAngle.difference(pathAngle)
        //print("path:",pathAngle.degreeValue(), "gravity", self.gravityAngle.degreeValue(), " dif:", angDif.degreeValue())
    
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
