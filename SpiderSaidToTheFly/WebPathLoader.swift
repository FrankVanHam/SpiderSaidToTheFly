//
//  PathLoader.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 17/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation
import SpriteKit

class WebPathLoader {
    
    func pathFromFile( filePath: String ) -> WebPath! {
        let content = self.getFileContent(filePath)
        return self.pathFromString(content!)
    }
    
    func pathFromString(_ content: String) -> WebPath {
        let path = WebPath()
        let seq: WebPathStringSequence = self.pathIter(content)
        for (char, x, y) in seq {
            switch char {
            case "M":
                self.addPoint(path, x: x,y: y)
            case "l":
                let last = path.last()
                self.addPoint(path, x: Int(last.x) + x, y: Int(last.y) + y)
            case "L":
                self.addPoint(path, x: x, y: y)
            default:
                self.addPoint( path, x: x,y: y)
            }
        }
        return path
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
    
    private func pathIter(_ content: String ) -> WebPathStringSequence {
        return WebPathStringSequence(content: content)
    }
}


struct WebPathStringSequence: Sequence {
    let content: String
    
    func makeIterator() -> WebPathStringIterator {
        return WebPathStringIterator(content)
    }
}

struct WebPathStringIterator: IteratorProtocol {
    typealias Element = (String, Int, Int)
    
    let content: String
    var char = ""
    var scanIndex : String.Index
    var commaIndex: String.Index
    var quoteString = ""
    var pieceString = ""
    
    init(_ content: String ) {
        self.content = content
        self.scanIndex = self.content.startIndex
        self.commaIndex = self.scanIndex
    }
    
    mutating func next() -> Element? {
        if self.quoteString == "" { self.loadQuoteString()}
        if self.quoteString == "" {return nil}
        
        if self.pieceString == "" {self.loadPieceString()}
        if self.pieceString == "" {return nil}
        
        let (x,y, atEnd) = self.nextXY()
        if atEnd { self.pieceString = "" }
        
        return (self.char, x, y)
    }
    
    private func atPieceEnd() -> Bool {
        return self.commaIndex == self.pieceString.endIndex
    }
    
    private func atQuoteEnd() -> Bool {
        return self.scanIndex == self.quoteString.endIndex
    }
    
    mutating private func loadQuoteString() {
        let range  = self.content.range(of: "path", options: NSString.CompareOptions.caseInsensitive)
        if range == nil {return}
        
        let quote1Range = self.content.range(of: " d=\"", options: NSString.CompareOptions.caseInsensitive, range: range!.lowerBound..<content.endIndex)
        if quote1Range == nil {return}
        
        let newStart = self.content.index(quote1Range!.lowerBound, offsetBy: 4)
        let quote2Range = self.content.range(of: "\"", options: NSString.CompareOptions.caseInsensitive, range: newStart..<content.endIndex)
        if quote2Range == nil {return}
        
        //let newEnd = content.index(quote2Range!.lowerBound, offsetBy: 1)
        self.quoteString = self.content[newStart..<quote2Range!.lowerBound]
        self.scanIndex = self.quoteString.startIndex
    }
    
    mutating private func loadPieceString() {
        
        if (self.scanIndex == self.quoteString.endIndex) { return }
        
        let separators = CharacterSet(charactersIn: "MlLhHvVcCsSQqTtAaZz")
        let sepStartRange = self.quoteString.rangeOfCharacter(from: separators, range: scanIndex..<self.quoteString.endIndex)
        if (sepStartRange == nil) { return }
        
        scanIndex = self.quoteString.index(after:sepStartRange!.lowerBound)
        let charRange = sepStartRange!.lowerBound..<scanIndex
        self.char = self.quoteString.substring(with: charRange)
        let sepEndRange = self.quoteString.rangeOfCharacter(from: separators, range: scanIndex..<self.quoteString.endIndex)
        
        if (sepEndRange != nil) {
            self.pieceString = self.quoteString[scanIndex..<sepEndRange!.lowerBound]
            self.scanIndex = sepEndRange!.lowerBound
        } else {
            self.pieceString = self.quoteString[scanIndex..<self.quoteString.endIndex]
            self.scanIndex = self.quoteString.endIndex
        }
        self.commaIndex = pieceString.startIndex
    }
    
    // Return the x and y Int value and if we reached the end.
    mutating private func nextXY() -> (Int, Int, Bool) {
        let xrange = self.pieceString.range(of: ",", range: commaIndex..<pieceString.endIndex)
        var xString = pieceString[commaIndex..<xrange!.lowerBound]
        self.commaIndex = pieceString.index(after:xrange!.lowerBound)
        let yrange = pieceString.range(of: ",", range: commaIndex..<pieceString.endIndex)
        var yString: String
        if yrange != nil {
            yString = pieceString[commaIndex..<yrange!.lowerBound]
            self.commaIndex = yrange!.lowerBound
        } else {
            yString = pieceString[commaIndex..<pieceString.endIndex]
            self.commaIndex = pieceString.endIndex
        }
        
        xString = xString.trimmingCharacters(in: CharacterSet(charactersIn: " \n\t"))
        yString = yString.trimmingCharacters(in: CharacterSet(charactersIn: " \n\t"))
        
        let atEnd = (self.commaIndex == pieceString.endIndex)
        let x = Int(Float(xString)!)
        let y = Int(Float(yString)!)
        return (x, y, atEnd)
    }
}

