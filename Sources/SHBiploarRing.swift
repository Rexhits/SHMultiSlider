//
//  SHBiploarRing.swift
//  KnobT
//
//  Created by WangRex on 12/1/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa

class SHBipolarRing: SHKnobRing {
    
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setValue(_ newValue: Float, animated: Bool) {
        let cal = calculateValue(newValue)
        setPointerAngle(cal.angle, valuePointerLayer)
        valueAngle = cal.angle
        displayValue = cal.value
        if (displayValue < lowerBound) ||  (displayValue > upperBound) {
            valueLayer.strokeColor = NSColor(red: 1, green: 0, blue: 0.3, alpha: 1).cgColor
        } else {
            valueLayer.strokeColor = tintColor.cgColor
        }
        delegate?.knobValueUpdated(value: Int(displayValue))
        updateValueLayer(cal.angle)
    }
    
    override func updateValueLayer(_ newValue: CGFloat) {
        autoreleasepool {
            let bounds = trackLayer.bounds
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let offset = Swift.max(boundPointerWidth, ringWidth / 2)
            let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
            let path = NSBezierPath()
            let lowS = calculateValue(min).angle.radiansToDegrees
            let lowE = lowerAngle.radiansToDegrees
            let uppS = upperAngle.radiansToDegrees
            let uppE = calculateValue(max).angle.radiansToDegrees
            path.appendArc(withCenter: center, radius: radius, startAngle: lowS, endAngle: lowE, clockwise: true)
            path.move(to: NSPoint(x: center.x + radius * cos(uppS.degreesToRadians), y: center.y + radius * sin(uppS.degreesToRadians)))
            path.appendArc(withCenter: center, radius: radius, startAngle: uppS, endAngle: uppE, clockwise: true)
            valueLayer.path = path.cgPath
        }
    }
    
}
