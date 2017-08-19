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
    }
    
    static func retrieve() -> Game? {
    let def = UserDefaults.standard
        let maxLevels = def.integer(forKey: "maxLevels")
        if maxLevels != 0 {
            let levelsLeft = def.integer(forKey: "levelsLeft")
            let maxLives = def.integer(forKey: "MaxLives")
            let lives = def.integer(forKey: "lives")
            return Game(maxLevels: maxLevels, levelsLeft: levelsLeft, maxLives: maxLives, lives: lives)
        } else {
            return nil
        }
    }
    
    func reset() {
        self.lives = self.maxLives
        self.levelsLeft = self.maxLevels
    }
    
    func won() {
        if self.levelsLeft > 0 {
            self.levelsLeft -= 1
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
    
}
