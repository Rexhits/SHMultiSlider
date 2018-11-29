//
//  KnobRing.swift
//  SHSlider
//
//  Created by WangRex on 11/25/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa


/// A knob-like multislider, contains 1 value ring, 1 value pointer and a pair of bound-selector
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
    
    var popoverMenu = NSMenu()
    let popover = NSPopover()
    
    /// Unused
    @IBInspectable public var isGated: Bool = false
    
    /// Unused
    @IBInspectable public var isReversed: Bool = false
    
    @IBInspectable public var bipolarBounds: Bool = false {
        didSet {
            hardclipValuePointer = !bipolarBounds
            valueNeedsRemap = !bipolarBounds
            delegate?.remapModeChanged(valueNeedsRemap)
            if bipolarBounds {
                layer?.addSublayer(upperBoundLayer)
                layer?.addSublayer(lowerBoundLayer)
                valueLayer.removeFromSuperlayer()
                valuePointerLayer.removeFromSuperlayer()
                layer?.addSublayer(valuePointerLayer)
                updateBipolarBoundsLayers()
            } else {
                layer?.addSublayer(valueLayer)
                upperBoundLayer.removeFromSuperlayer()
                lowerBoundLayer.removeFromSuperlayer()
            }
            
        }
    }
    
    public var valueNeedsRemap: Bool = true
    
    /// Value pointer will jump within upper/lower bounds when it's true, else it will jump between min/map. Default is true
    @IBInspectable public var hardclipValuePointer: Bool = true
    
    @IBInspectable public override var isEnabled: Bool {
        didSet {
            self.tintColor = isEnabled ? self.tintColor : NSColor.disabledControlTextColor
            self.valuePointerLayer.isHidden = !isEnabled
        }
    }
    
    /// Delegate
    public var delegate: SHKnobRingDelegate?
    
    private let trackLayer = CAShapeLayer()
    private let valuePointerLayer = CAShapeLayer()
    private let lowerboundPointerLayer = CAShapeLayer()
    private let upperboundPointerLayer = CAShapeLayer()
    private let valueLayer = CAShapeLayer()
    private let lowerBoundLayer = CAShapeLayer()
    private let upperBoundLayer = CAShapeLayer()
    
    /// Min of input value
    @IBInspectable public var min: Float = 0 {
        didSet {
            if min > lowerBound {
                setLowerBoundValue(min)
            }
            if displayValue < min {
                setValue(min)
            } else {
                setValue(displayValue)
            }
        }
    }
    
    
    /// Max of input value
    @IBInspectable public var max: Float = 127 {
        didSet {
            if max < upperBound {
                setUppderBoundValue(max)
            }
            if displayValue > max {
                setValue(max)
            } else {
                setValue(displayValue)
            }
        }
    }
    
    
    /// Lowerbound of input value, output value will be remapped from min-max to lowerBound-upperBound
    private(set) var lowerBound: Float = 0
    
    /// Upperbound of input value, output value will be remapped from min-max to lowerBound-upperBound
    private(set) var upperBound: Float = 127
    
    
    /// Value displayed on screen
    private (set) var displayValue: Float = 0
    
    var lowerClicked = false
    var upperClicked = false
    
    
    /// Color of the ring outline
    @IBInspectable public var ringColor: NSColor = .orange {
        didSet {
            trackLayer.strokeColor = ringColor.cgColor
        }
    }
    
    
    /// Color of the value ring
    @IBInspectable public var tintColor: NSColor = .orange {
        didSet {
            valueLayer.strokeColor = tintColor.cgColor
            upperBoundLayer.strokeColor = tintColor.cgColor
            lowerBoundLayer.strokeColor = tintColor.cgColor
        }
    }
    
    /// Color of the value pointer
    public var valuePointerColor: NSColor = .red {
        didSet {
            valuePointerLayer.strokeColor = valuePointerColor.cgColor
        }
    }
    
    /// Color of the max/min pointer
    public var boundPointerColor: NSColor = .white {
        didSet {
            lowerboundPointerLayer.strokeColor = boundPointerColor.cgColor
            upperboundPointerLayer.strokeColor = boundPointerColor.cgColor
        }
    }
    
    
    /// Line width for the ring outline, note that value ring's line width will always be ringWidth + 2
    public var ringWidth: CGFloat = 5 {
        didSet {
            trackLayer.lineWidth = ringWidth
            valueLayer.lineWidth = ringWidth + 2
            upperBoundLayer.lineWidth = ringWidth + 2
            lowerBoundLayer.lineWidth = ringWidth + 2
            updateTrackLayerPath()
        }
    }
    
    /// Line Width for the value pointer
    public var pointerWidth: CGFloat = 6 {
        didSet {
            valuePointerLayer.lineWidth = pointerWidth
            updatePointerLayerPath()
        }
    }
    
    
    /// Line width for the lower and upper bounds pointers
    public var boundPointerWidth: CGFloat = 4 {
        didSet {
            lowerboundPointerLayer.lineWidth = boundPointerWidth
            upperboundPointerLayer.lineWidth = boundPointerWidth
            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }
    
    /// Start angle of the ring, default is 247.5˚(11/8*pi), note that this has to be in degree instead of radians
    public var startAngle: CGFloat = CGFloat(Double.pi * 11 / 8).radiansToDegrees {
        didSet {
            updateTrackLayerPath()
        }
    }
    
    /// Engle angle of the ring, default is -67.5˚ (-3/8*pi), note that this has to be in degree instead of radians
    public var endAngle: CGFloat = CGFloat(-Double.pi * 3 / 8).radiansToDegrees {
        didSet {
            updateTrackLayerPath()
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
    
    func updateValueLayer() {
        autoreleasepool {
            let bounds = trackLayer.bounds
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let offset = Swift.max(boundPointerWidth, ringWidth / 2)
            let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
            let path = NSBezierPath()
            let newValue = calculateValue(displayValue).angle
            if displayValue < lowerBound {
                valueLayer.path = nil
            } else {
                let end = displayValue < upperBound ? newValue.radiansToDegrees : upperAngle.radiansToDegrees
                path.appendArc(withCenter: center, radius: radius, startAngle: lowerAngle.radiansToDegrees, endAngle: end, clockwise: true)
                valueLayer.path = path.cgPath
            }
        }
    }
    
    func updateValueLayer(_ newValue: CGFloat) {
        autoreleasepool {
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
        }
    }
    
    /// update bounds layers, only invoked when bipolarBounds = true
    public func updateBipolarBoundsLayers() {
        guard bipolarBounds else {
            return
        }
        autoreleasepool {
            let bounds = trackLayer.bounds
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let offset = Swift.max(boundPointerWidth, ringWidth / 2)
            let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
            let lowerPath = NSBezierPath()
            let upperPath = NSBezierPath()
            lowerPath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: lowerAngle.radiansToDegrees, clockwise: true)
            upperPath.appendArc(withCenter: center, radius: radius, startAngle: upperAngle.radiansToDegrees, endAngle: endAngle, clockwise: true)
            lowerBoundLayer.path = lowerPath.cgPath
            upperBoundLayer.path = upperPath.cgPath
            
        }
    }
    
    public func getBounds() -> (lower: Int, upper: Int) {
        return (lower: Int(round(lowerBound)), upper: Int(round(upperBound)))
    }
    
    /// Set value for value pointer
    ///
    /// - Parameters:
    ///   - newValue: input value to be displayed
    ///   - animated: unused
    public func setValue(_ newValue: Float, animated: Bool = false) {
        autoreleasepool {
            let cal = calculateValue(newValue)
            var v = newValue
            if hardclipValuePointer {
                if newValue < lowerBound {
                    v = lowerBound
                }
                if newValue > upperBound {
                    v = upperBound
                }
                let calV = calculateValue(v)
                setPointerAngle(calV.angle, valuePointerLayer)
                valueAngle = calV.angle
            } else {
                setPointerAngle(cal.angle, valuePointerLayer)
                valueAngle = cal.angle
            }
            displayValue = cal.value
            if bipolarBounds {
                if (displayValue < lowerBound || displayValue > upperBound) {
                    lowerBoundLayer.strokeColor = NSColor(red: 1, green: 0, blue: 0.3, alpha: 1).cgColor
                    upperBoundLayer.strokeColor = NSColor(red: 1, green: 0, blue: 0.3, alpha: 1).cgColor
                    delegate?.knobValueUpdated(value: Int(displayValue))
                } else {
                    lowerBoundLayer.strokeColor = tintColor.cgColor
                    upperBoundLayer.strokeColor = tintColor.cgColor
                }
            } else {
                delegate?.knobValueUpdated(value: Int(displayValue))
            }
            updateValueLayer(cal.angle)
        }
    }
    
    
    /// Set lower bound's value
    ///
    /// - Parameter newValue: new lower bound value, output value will be remapped from min-max to lowerBound-upperBound
    public func setLowerBoundValue(_ newValue: Float) {
        autoreleasepool {
            let cal = calculateValue(newValue)
            lowerBound = cal.value
            setPointerAngle(cal.angle, lowerboundPointerLayer)
            lowerAngle = cal.angle
        }
    }
    
    
    /// Set upper bound's value
    ///
    /// - Parameter newValue: new upper bound value, output value will be remapped from min-max to lowerBound-upperBound
    public func setUppderBoundValue(_ newValue: Float) {
        autoreleasepool {
            let cal = calculateValue(newValue)
            upperBound = cal.value
            setPointerAngle(cal.angle, upperboundPointerLayer)
            upperAngle = cal.angle
        }
    }
    
    func calculateValue(_ newValue: Float) -> (value: Float, angle: CGFloat) {
        var output: (value: Float, angle: CGFloat) = (value: 0, angle: 0)
        autoreleasepool {
            let value = Swift.min(max, Swift.max(min, newValue))
            let angleRange = endAngle.degreesToRadians - startAngle.degreesToRadians
            let valueRange = max - min
            output = (value: value, angle: CGFloat(value - min) / CGFloat(valueRange) * angleRange + startAngle.degreesToRadians)
        }
        return output
    }
    
    
    private func updateTrackLayerPath() {
        autoreleasepool {
            let bounds = trackLayer.bounds
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let offset = Swift.max(boundPointerWidth, ringWidth / 2)
            let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
            
            let ringPath = NSBezierPath()
            ringPath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            trackLayer.path = ringPath.cgPath
        }
    }
    
    private func updatePointerLayerPath() {
        autoreleasepool {
            let bounds = trackLayer.bounds
            
            let boundPointers = NSBezierPath()
            let pointer = NSBezierPath()
            
            boundPointers.move(to: NSPoint(x: bounds.width - boundPointerWidth - ringWidth / 2, y: bounds.midY))
            boundPointers.line(to: NSPoint(x: bounds.width, y: bounds.midY))
            
            pointer.move(to: NSPoint(x: bounds.width - pointerWidth - ringWidth / 2, y: bounds.midY))
            pointer.line(to: NSPoint(x: bounds.width, y: bounds.midY))
            
            lowerboundPointerLayer.path = boundPointers.cgPath
            upperboundPointerLayer.path = boundPointers.cgPath
            valuePointerLayer.path = pointer.cgPath
        }
    }
    
    func updateBounds(_ bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        updateTrackLayerPath()
        updateValueLayer()
        lowerboundPointerLayer.bounds = trackLayer.bounds
        lowerboundPointerLayer.position = trackLayer.position
        upperboundPointerLayer.bounds = trackLayer.bounds
        upperboundPointerLayer.position = trackLayer.position
        valuePointerLayer.bounds = trackLayer.bounds
        valuePointerLayer.position = trackLayer.position
        valueLayer.bounds = trackLayer.bounds
        valueLayer.position = trackLayer.position
        
        updatePointerLayerPath()
    }
    
    private func setupUI() {
        wantsLayer = true
        valueLayer.fillColor = NSColor.clear.cgColor
        trackLayer.fillColor = NSColor.black.withAlphaComponent(0.2).cgColor
        upperBoundLayer.fillColor = NSColor.clear.cgColor
        lowerBoundLayer.fillColor = NSColor.clear.cgColor
        lowerboundPointerLayer.fillColor = NSColor.clear.cgColor
        upperboundPointerLayer.fillColor = NSColor.clear.cgColor
        updateBounds(bounds)
        ringColor = NSColor.darkGray
        boundPointerColor = NSColor.white
        tintColor = NSColor.orange
        valuePointerColor = NSColor.red
        setLowerBoundValue(0)
        setUppderBoundValue(127)
        ringWidth = 5
        pointerWidth = 6
        boundPointerWidth = 4
        layer?.addSublayer(trackLayer)
        //        layer?.addSublayer(valueLayer)
        layer?.addSublayer(lowerboundPointerLayer)
        layer?.addSublayer(upperboundPointerLayer)
        layer?.addSublayer(valuePointerLayer)
        bipolarBounds = false
        
        let popoverVC = NSViewController()
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = popoverVC
        setValue(64)
    }
    
    @objc func bipoloarModeDidChange() {
        self.bipolarBounds = !self.bipolarBounds
    }
    
    @objc func remapModeDidChange() {
        self.valueNeedsRemap = !self.valueNeedsRemap
        delegate?.remapModeChanged(self.valueNeedsRemap)
    }
    
    @objc func gateModeDidChange() {
        self.isGated = !self.isGated
        delegate?.gateModeChanged(self.isGated)
    }
    
    @objc func reverseModeDidChange() {
        self.isReversed = !isReversed
        delegate?.reversedModeChanged(isReversed)
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        popoverMenu = NSMenu()
        popoverMenu.autoenablesItems = false
        let bipolarItem = NSMenuItem(title: "BiploarMode", action: #selector(bipoloarModeDidChange), keyEquivalent: "")
        bipolarItem.state = bipolarBounds ? .on : .off
        let remapItem = NSMenuItem(title: "Remap Output", action: #selector(remapModeDidChange), keyEquivalent: "")
        remapItem.state = valueNeedsRemap ? .on: .off
        let gateItem = NSMenuItem(title: "Gated Ouput Mode", action: #selector(gateModeDidChange), keyEquivalent: "")
        gateItem.state = isGated ? .on: .off
        let reverseItem = NSMenuItem(title: "Reverse Mode", action: #selector(reverseModeDidChange), keyEquivalent: "")
        reverseItem.state = isReversed ? .on : .off
        remapItem.isEnabled = !bipolarBounds
        popoverMenu.addItem(bipolarItem)
        popoverMenu.addItem(remapItem)
        popoverMenu.addItem(gateItem)
        popoverMenu.addItem(reverseItem)
        
        NSMenu.popUpContextMenu(popoverMenu, with: event, for: self)
    }
    
    /// Reset: displayValue= min, lowerBound = min, upperBound = max
    public func reset() {
        setLowerBoundValue(min)
        setUppderBoundValue(max)
        delegate?.knobBoundsUpdated(lower: Int(min), upper: Int(min))
    }
    
    public override func mouseDown(with event: NSEvent) {
        guard isEnabled else {return}
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
        guard isEnabled else {return}
        lowerClicked = false
        upperClicked = false
        delegate?.knobBoundsFinishUpdate()
    }
    
    
    
    public override func mouseDragged(with event: NSEvent) {
        guard isEnabled else {return}
        autoreleasepool {
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
                setValue(displayValue)
                updateValueLayer(valueAngle)
                updateBipolarBoundsLayers()
                delegate?.knobBoundsUpdated(lower: Int(lowerBound), upper: Int(upperBound))
            } else if upperClicked {
                guard value > lowerBound else {return}
                setUppderBoundValue(value)
                setValue(displayValue)
                updateValueLayer(valueAngle)
                updateBipolarBoundsLayers()
                delegate?.knobBoundsUpdated(lower: Int(lowerBound), upper: Int(upperBound))
            }
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

// Delegate methods for SHKnobRing
public protocol SHKnobRingDelegate {
    func knobValueUpdated(value: Int)
    func knobBoundsUpdated(lower: Int, upper: Int)
    func knobBoundsFinishUpdate()
    func gateModeChanged(_ isGated: Bool)
    func reversedModeChanged(_ isReversed: Bool)
    func bipolarBoundsModeChanged(_ isBipolar: Bool)
    func remapModeChanged(_ needsRemap: Bool)
}
