//
//  PublicExtensions.swift
//  SHSlider
//
//  Created by WangRex on 11/26/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa

public extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        
        return path
    }
}

extension FloatingPoint {
    func map(start1: Self, stop1: Self, start2: Self, stop2: Self) -> Self {
        var output = start2 + (stop2 - start2) * ((self - start1) / (stop1 - start1))
        output = output < min(start2, stop2) ? min(start2, stop2) : output
        output = output > max(start2, stop2) ? max(start2, stop2) : output
        return output
    }
    
}

extension BinaryInteger {
    func map(start1: Self, stop1: Self, start2: Self, stop2: Self) -> Self {
        let s1 = Double(start1)
        let e1 = Double(stop1)
        let s2 = Double(start2)
        let e2 = Double(stop2)
        var output = s2 + (e2 - s2) * ((Double(self) - s1) / (e1 - s1))
        output = output < min(s2, e2) ? min(s2, e2) : output
        output = output > max(s2, e2) ? max(s2, e2) : output
        return Self(output)
    }
}


public extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
