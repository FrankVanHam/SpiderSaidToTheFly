//
//  PathLoader.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 17/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation
import SpriteKit

class WebPolylineLoader {
    
    func pathFromFile( filePath: String ) -> WebPath! {
        let content = self.getFileContent(filePath)
        return self.pathFromString(content!)
    }
    
    func pathFromString(_ content: String) -> WebPath {
        let quoteString = self.quoteString(content: content)
        let pieces = quoteString.components(separatedBy: CharacterSet(charactersIn: ", "))
        return self.pathFromPieces(pieces: pieces)
    }
    
    func pathFromPieces(pieces: [String]) -> WebPath {
        let path = WebPath()
        var xString = ""
        var yString = ""
        for piece in pieces {
            if xString == "" {
                xString = piece
            } else {
                yString = piece
                self.addPoint(path, x: Int(Float(xString)!), y: Int(Float(yString)!))
                xString = ""; yString = ""
            }
        }
        return path
    }
    
    private func quoteString(content: String) -> String {
        let range  = content.range(of: "<polyline", options: NSString.CompareOptions.caseInsensitive)
        if range == nil {return ""}
        
        let quote1Range = content.range(of: "points=\"", options: NSString.CompareOptions.caseInsensitive, range: range!.lowerBound..<content.endIndex)
        if quote1Range == nil {return ""}
        
        let newStart = content.index(quote1Range!.lowerBound, offsetBy: 8)
        let quote2Range = content.range(of: "\"", options: NSString.CompareOptions.caseInsensitive, range: newStart..<content.endIndex)
        if quote2Range == nil {return ""}
        
        return content[newStart..<quote2Range!.lowerBound]
    }
    
    private func addPoint(_ path: WebPath, x: Int, y: Int ) {
        path.addPoint(CGPoint(x: x, y:y))
    }
    
    private func getFileContent(_ filePath: String) -> String? {
        do {
            return try String.init(contentsOfFile: filePath, encoding: String.Encoding.utf8 )
        } catch {
            return nil
        }
    }
}

