//
//  Game.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 18/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation


class Game {
    
    var levelsLeft = 0
    var maxLevels = 0
    var maxLives = 0
    var lives = 0
    var path : WebPath!
    var settings: LevelSettings!
    
    convenience init(maxLevels: Int, lives: Int) {
        self.init(maxLevels: maxLevels, levelsLeft: maxLevels, maxLives: lives, lives: lives)
    }
    convenience init() {
        self.init(maxLevels: 0, levelsLeft: 0, maxLives: 0, lives: 0)
    }
    
    init(maxLevels: Int, levelsLeft: Int, maxLives: Int, lives: Int) {
        self.levelsLeft = levelsLeft
        self.maxLevels = max(maxLevels, levelsLeft)
        self.maxLives = max(maxLives, lives)
        self.lives = lives
        self.loadPathAndLevel()
    }
    
    static func retrieve() -> Game? {
    let def = UserDefaults.standard
        let maxLevels = def.integer(forKey: "maxLevels")
        if maxLevels != 0 {
            let levelsLeft = def.integer(forKey: "levelsLeft")
            let maxLives = def.integer(forKey: "MaxLives")
            let lives = def.integer(forKey: "lives")
            print("retrieved ", levelsLeft )
            return Game(maxLevels: maxLevels, levelsLeft: levelsLeft, maxLives: maxLives, lives: lives)
        } else {
            return nil
        }
    }
    
    func setMaxLevels(_ maxLevels: Int) {
        let level = self.level()
        self.maxLevels = maxLevels
        self.setLevel(level)
    }
    
    func setLevel(_ level: Int) {
        if level <= self.maxLevels {
            if level != self.level() {
                self.levelsLeft = self.maxLevels-level+1
                self.loadPathAndLevel()
            }
        }
    }
    
    func reset() {
        self.lives = self.maxLives
        self.setLevel(1)
    }
    
    func won() {
        if levelsLeft == 1 {
            levelsLeft = 0
        } else {
            if levelsLeft > 0 {
                self.setLevel(self.level()+1)
            }
        }
    }
    
    func lose() {
        if self.lives != 0 {
            self.lives -= 1
        }
    }
    
    func over() -> Bool {
        return self.lives == 0
    }
    
    func isEnded() -> Bool {
        return self.levelsLeft == 0
    }
    
    func level() -> Int {
        return (self.maxLevels - self.levelsLeft) + 1
    }
    
    func save() {
        let def = UserDefaults.standard
        def.set(self.levelsLeft, forKey: "levelsLeft")
        def.set(self.maxLevels, forKey: "maxLevels")
        def.set(self.maxLives, forKey: "maxLives")
        def.set(self.lives, forKey: "lives")
        def.synchronize()
    }
    
    func syncWithScene(scene: GameScene) {
        path = scene.load(path: path, game: self)
    }
    
    private func loadPathAndLevel() {
        if !self.isEnded() {
            let levelName = "level\(self.level())"
            let pathFile = Bundle.main.path(forResource: levelName, ofType: "svg", inDirectory: "Paths.bundle")
            let gameFile = Bundle.main.path(forResource: levelName, ofType: "json", inDirectory: "Paths.bundle")
            
            path = WebPolylineLoader().pathFromFile(filePath: pathFile!)
            if path.isEmpty() {
                path = WebPathLoader().pathFromFile(filePath: pathFile!)
            }
            path.cleanUp()
            //print("path length", levelName, "  ", String(describing: path.length()))
            if path.first().y < path.last().y {
                path.flipHorizontal()
            }
            settings = LevelSettingsLoader().settingsFromFile(filePath: gameFile!)
        } else {
            path = nil
            settings = nil
        }
    }
    
}
