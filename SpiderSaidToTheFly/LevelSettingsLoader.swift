//
//  GameSettingsLoader.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 17/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation
import SpriteKit

class LevelSettingsLoader {
    
    func settingsFromFile(filePath: String) -> LevelSettings {
        do {
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            
            let json = try JSONSerialization.jsonObject(with: data) as! NSDictionary
            
            let spiderSpeed: CGFloat = json["spiderSpeed"] as! CGFloat
            let flySpeed: CGFloat = json["flySpeed"] as! CGFloat
            let flyPosition: CGFloat = json["flyPosition"] as! CGFloat
            let subText: [String] = json["subtext"] as! [String]
            
            return LevelSettings(spiderSpeed: spiderSpeed, flySpeed: flySpeed, flyPosition: flyPosition, subText: subText)
        } catch {
            return LevelSettings(spiderSpeed: 10, flySpeed: 10, flyPosition: 0.2, subText: [])
        }
    }
            
}
