//
//  NAngle.swift
//  orient
//
//  Created by Frank on 04/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import Foundation
import CoreGraphics
import Darwin

class NAngle: CustomStringConvertible {
    var value: CGFloat
    
    init(_ angle: CGFloat) {
        // Make sure it is in the +pi to -pi range.
        let pi = CGFloat(Double.pi)
        value = angle
        while (value > pi) {
            value = value - (2*pi)
        }
        while (value < -pi) {
            value = value + (2*pi)
        }
    }
    func difference(_ otherAngle: NAngle) -> NAngle {
        return NAngle(value - otherAngle.value)
    }
    func absolute() -> NAngle{
        return NAngle(abs(value))
    }
    var description: String {
        let deg = degreeValue()
        return "\(deg) rads"
    }
    func degreeValue() -> CGFloat {
        let pi = CGFloat(Double.pi)
        return CGFloat((180 / pi) * value)
    }
}
