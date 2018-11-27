//
//  KnobRing.swift
//  SHSlider
//
//  Created by WangRex on 11/25/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa

@IBDesignable public class SHKnobRing: NSControl {
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    public var isGated: Bool = false {
        didSet {
            delegate?.gateModeChanged(isGated)
        }
    }
    public var isReversed: Bool = false {
        didSet {
            delegate?.reversedModeChanged(isReversed)
        }
    }
    
    public var delegate: SHKnobRingDelegate?
    
    private let trackLayer = CAShapeLayer()
    private let pointerLayer = CAShapeLayer()
    private let minPointerLayer = CAShapeLayer()
    private let maxPointerLayer = CAShapeLayer()
    private let valueLayer = CAShapeLayer()
    
    var min: Float = 0
    
    var max: Float = 127
    
    private var lowerBound: Float = 0
    
    private var upperBound: Float = 127
    
    
    private (set) var displayValue: Float = 0
    
    var lowerClicked = false
    var upperClicked = false
    
    var ringColor: NSColor = .orange {
        didSet {
            trackLayer.strokeColor = ringColor.cgColor
        }
    }
    
    
    var tintColor: NSColor = .orange {
        didSet {
            valueLayer.strokeColor = tintColor.cgColor
        }
    }
    
    var pointerColor: NSColor = .white {
        didSet {
            minPointerLayer.strokeColor = pointerColor.cgColor
            maxPointerLayer.strokeColor = pointerColor.cgColor
        }
    }
    
    var ringWidth: CGFloat = 5 {
        didSet {
            trackLayer.lineWidth = ringWidth
            valueLayer.lineWidth = ringWidth + 2
            updateTrackLayerPath()
        }
    }
    
    var startAngle: CGFloat = CGFloat(Double.pi * 11 / 8).radiansToDegrees {
        didSet {
            updateTrackLayerPath()
        }
    }
    
    var endAngle: CGFloat = CGFloat(-Double.pi * 3 / 8).radiansToDegrees {
        didSet {
            updateTrackLayerPath()
        }
    }
    
    var pointerWidth: CGFloat = 6 {
        didSet {
            pointerLayer.lineWidth = pointerWidth
            updatePointerLayerPath()
        }
    }
    
    var boundPointerWidth: CGFloat = 4 {
        didSet {
            minPointerLayer.lineWidth = boundPointerWidth
            maxPointerLayer.lineWidth = boundPointerWidth
            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }
    
    private var lowerAngle: CGFloat = CGFloat(Double.pi * 11 / 8).radiansToDegrees
    private var upperAngle: CGFloat = CGFloat(-Double.pi * 3 / 8).radiansToDegrees
    private var valueAngle: CGFloat = CGFloat(Double.pi * 11 / 8).radiansToDegrees
    
    func setPointerAngle(_ newAngle: CGFloat, animated: Bool = false, _ toPointerLayer: CAShapeLayer) {
//        toPointerLayer.transform = CATransform3DMakeRotation(newAngle, 0, 0, 1)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        toPointerLayer.setAffineTransform(CGAffineTransform(rotationAngle: newAngle))
        CATransaction.commit()
    }
    
    func updateValueLayer(_ newValue: CGFloat) {
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = Swift.max(boundPointerWidth, ringWidth / 2)
        let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
        let path = NSBezierPath()
        if displayValue < lowerBound {
            valueLayer.path = nil
        } else {
            let end = displayValue < upperBound ? newValue.radiansToDegrees : upperAngle.radiansToDegrees
            path.appendArc(withCenter: center, radius: radius, startAngle: lowerAngle.radiansToDegrees, endAngle: end, clockwise: true)
            valueLayer.path = path.cgPath
        }
        delegate?.knobValueUpdated(value: Int(displayValue).map(start1: Int(lowerBound), stop1: Int(upperBound), start2: 0, stop2: 127))
    }
    
    
    
    func setValue(_ newValue: Float, animated: Bool = false) {
        let cal = calculateValue(newValue)
        displayValue = cal.value
        setPointerAngle(cal.angle, pointerLayer)
        updateValueLayer(cal.angle)
        valueAngle = cal.angle
    }
    
    func setLowerBoundValue(_ newValue: Float) {
        let cal = calculateValue(newValue)
        lowerBound = cal.value
        setPointerAngle(cal.angle, minPointerLayer)
        lowerAngle = cal.angle
    }
    
    func setUppderBoundValue(_ newValue: Float) {
        let cal = calculateValue(newValue)
        upperBound = cal.value
        setPointerAngle(cal.angle, maxPointerLayer)
        upperAngle = cal.angle
    }
    
    func calculateValue(_ newValue: Float) -> (value: Float, angle: CGFloat) {
        let value = Swift.min(max, Swift.max(min, newValue))
        let angleRange = endAngle.degreesToRadians - startAngle.degreesToRadians
        let valueRange = max - min
        return (value: value, angle: CGFloat(value - min) / CGFloat(valueRange) * angleRange + startAngle.degreesToRadians)
    }
    
    
    private func updateTrackLayerPath() {
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = Swift.max(boundPointerWidth, ringWidth / 2)
        let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
        
        let ringPath = NSBezierPath()
        ringPath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        trackLayer.path = ringPath.cgPath
        
    }
    
    private func updatePointerLayerPath() {
        let bounds = trackLayer.bounds
        
        let boundPointers = NSBezierPath()
        let pointer = NSBezierPath()
        
        boundPointers.move(to: NSPoint(x: bounds.width - boundPointerWidth - ringWidth / 2, y: bounds.midY))
        boundPointers.line(to: NSPoint(x: bounds.width, y: bounds.midY))

//        pointer.move(to: NSPoint(x: bounds.width - pointerLength - ringWidth / 2, y: bounds.midY))
        pointer.move(to: NSPoint(x: bounds.width - pointerWidth - ringWidth / 2, y: bounds.midY))
        pointer.line(to: NSPoint(x: bounds.width, y: bounds.midY))

        minPointerLayer.path = boundPointers.cgPath
        maxPointerLayer.path = boundPointers.cgPath
        pointerLayer.path = pointer.cgPath
    }
    
    func updateBounds(_ bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        updateTrackLayerPath()
        
        minPointerLayer.bounds = trackLayer.bounds
        minPointerLayer.position = trackLayer.position
        maxPointerLayer.bounds = trackLayer.bounds
        maxPointerLayer.position = trackLayer.position
        pointerLayer.bounds = trackLayer.bounds
        pointerLayer.position = trackLayer.position
        valueLayer.bounds = trackLayer.bounds
        valueLayer.position = trackLayer.position
        
        updatePointerLayerPath()
    }
    
    private func setupUI() {
        wantsLayer = true
        valueLayer.fillColor = NSColor.clear.cgColor
        trackLayer.fillColor = NSColor.black.withAlphaComponent(0.2).cgColor
        minPointerLayer.fillColor = NSColor.clear.cgColor
        maxPointerLayer.fillColor = NSColor.clear.cgColor
        updateBounds(bounds)
        ringColor = NSColor.darkGray
        pointerColor = NSColor.white
        tintColor = NSColor.orange
        pointerLayer.strokeColor = NSColor.red.cgColor
        setLowerBoundValue(0)
        setUppderBoundValue(127)
        setValue(64)
        ringWidth = 5
        pointerWidth = 6
        boundPointerWidth = 4
        layer?.addSublayer(trackLayer)
        layer?.addSublayer(valueLayer)
        layer?.addSublayer(minPointerLayer)
        layer?.addSublayer(maxPointerLayer)
        layer?.addSublayer(pointerLayer)
        
    }
    
    public func reset() {
        setLowerBoundValue(0)
        setUppderBoundValue(127)
        delegate?.knobBoundsUpdated(lower: 0, upper: 127)
        setValue(0)
    }
    
    public override func mouseDown(with event: NSEvent) {
        let eventLoc = event.locationInWindow
        let localLoc = self.convert(eventLoc, from: nil)
        let clickAngle = angle(for: localLoc)
        if (normalizeDifferenceAngleInRadians(a1: clickAngle, lowerAngle).magnitude < 0.12) {
            lowerClicked = true
        } else if (normalizeDifferenceAngleInRadians(a1: clickAngle, upperAngle).magnitude < 0.12) {
            upperClicked = true
        }
        delegate?.knobBoundsUpdated(lower: Int(lowerBound), upper: Int(upperBound))
        if event.modifierFlags.contains(.command) {
            reset()
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        lowerClicked = false
        upperClicked = false
        delegate?.knobBoundsFinishUpdate()
    }
    
    public override func mouseDragged(with event: NSEvent) {
        let eventLoc = event.locationInWindow
        let localLoc = self.convert(eventLoc, from: nil)
        var clickAngle = angle(for: localLoc)
        
        if clickAngle > 0 {
            clickAngle = (clickAngle - CGFloat.pi).magnitude + (startAngle.degreesToRadians - CGFloat.pi)
        } else {
            if clickAngle < -(2*CGFloat.pi - startAngle.degreesToRadians) {
                clickAngle = clickAngle * -1 - (2*CGFloat.pi - startAngle.degreesToRadians)
            } else if clickAngle > -(startAngle.degreesToRadians - CGFloat.pi) {
                clickAngle = clickAngle * -1 + (CGFloat.pi + (startAngle.degreesToRadians - CGFloat.pi))
            } else {
                return
            }
        }
        
        let value = round(Float(clickAngle.map(start1: 0, stop1: CGFloat.pi + 2*(startAngle.degreesToRadians-CGFloat.pi), start2: 0, stop2: 127)))
        if lowerClicked {
            guard value < upperBound else {return}
            setLowerBoundValue(value)
            updateValueLayer(valueAngle)
            delegate?.knobBoundsUpdated(lower: Int(lowerBound), upper: Int(upperBound))
        } else if upperClicked {
            guard value > lowerBound else {return}
            setUppderBoundValue(value)
            updateValueLayer(valueAngle)
            delegate?.knobBoundsUpdated(lower: Int(lowerBound), upper: Int(upperBound))
        }
    }
    
    private func angle(for point: CGPoint) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - self.bounds.midX, y: point.y - self.bounds.midY)
        return atan2(centerOffset.y, centerOffset.x)
    }
    
    func normalizeDifferenceAngleInRadians(a1: CGFloat, _ a2: CGFloat)->CGFloat {
        let twoPi = 2 * CGFloat.pi
        let d: CGFloat = (a2 - a1).remainder(dividingBy: twoPi)
        let s: CGFloat = d < 0 ? -1.0 : 1.0
        return d * s < CGFloat.pi ? d : (d - s * twoPi)
    }
    
    
}

public protocol SHKnobRingDelegate {
    func knobValueUpdated(value: Int)
    func knobBoundsUpdated(lower: Int, upper: Int)
    func knobBoundsFinishUpdate()
    func gateModeChanged(_ isGated: Bool)
    func reversedModeChanged(_ isReversed: Bool)
}
