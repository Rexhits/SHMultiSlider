//
//  SHBiploarRing.swift
//  KnobT
//
//  Created by WangRex on 12/1/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa

public class SHBipolarRing: SHKnobRing {
    
    internal var valueLayer2: CAShapeLayer!
    
    public override var tintColor: NSColor {
        didSet {
            valueLayer.strokeColor = tintColor.cgColor
            valueLayer2.strokeColor = tintColor.cgColor
        }
    }
    
    public override var ringWidth: CGFloat {
        didSet {
            trackLayer.lineWidth = ringWidth
            valueLayer.lineWidth = ringWidth + 2
            valueLayer2.lineWidth = ringWidth + 2
            updateTrackLayerPath()
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    public override func setValue(_ newValue: Float, animated: Bool) {
        let cal = calculateValue(newValue)
        setPointerAngle(cal.angle, valuePointerLayer)
        valueAngle = cal.angle
        displayValue = cal.value
        if (displayValue < lowerBound) {
            valueLayer.strokeColor = NSColor(red: 1, green: 0, blue: 0.3, alpha: 1).cgColor
        }  else if (displayValue > upperBound) {
            valueLayer2.strokeColor = NSColor(red: 1, green: 0, blue: 0.3, alpha: 1).cgColor
        }
        else {
            valueLayer.strokeColor = tintColor.cgColor
            valueLayer2.strokeColor = tintColor.cgColor
        }
        delegate?.knobValueUpdated(value: Int(displayValue))
        updateValueLayer(cal.value)
    }
    
    override func updateValueLayer(_ newValue: Float) {
        CATransaction.setDisableActions(true)
        valueLayer.strokeEnd = CGFloat(lowerBound / max)
        valueLayer2.strokeStart = CGFloat(upperBound / max)
        delegate?.knobValueUpdated(value: Int(displayValue))
    }
    
    override func updateValueLayer() {
        CATransaction.setDisableActions(true)
        valueLayer.strokeEnd = CGFloat(lowerBound / max)
        valueLayer2.strokeStart = CGFloat(upperBound / max)
    }
    
    override internal func drawValueLayerPath() {
        super.drawValueLayerPath()
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = Swift.max(boundPointerWidth, ringWidth / 2)
        let radius = Swift.min(bounds.width, bounds.height) / 2 - offset
        let path = NSBezierPath()
        path.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        valueLayer2.path = path.cgPath
    }
    
    override func setupUI() {
        valueLayer2 = CAShapeLayer()
        wantsLayer = true
        valueLayer.fillColor = NSColor.clear.cgColor
        valueLayer2.fillColor = NSColor.clear.cgColor
        trackLayer.fillColor = NSColor.black.withAlphaComponent(0.2).cgColor
        lowerboundPointerLayer.fillColor = NSColor.clear.cgColor
        upperboundPointerLayer.fillColor = NSColor.clear.cgColor
        updateBounds(bounds)
        ringColor = NSColor.darkGray
        boundPointerColor = NSColor.white
        tintColor = NSColor.orange
        valuePointerColor = NSColor.red
        setLowerBoundValue(min)
        setUppderBoundValue(max)
        setValue(max/2, animated: true)
        ringWidth = 5
        pointerWidth = 6
        boundPointerWidth = 4
        trackLayer.shouldRasterize = true
        valueLayer.drawsAsynchronously = true
        valueLayer2.drawsAsynchronously = true
        lowerboundPointerLayer.shouldRasterize = true
        upperboundPointerLayer.shouldRasterize = true
        valuePointerLayer.shouldRasterize = true
        drawValueLayerPath()
        layer?.addSublayer(trackLayer)
        layer?.addSublayer(valueLayer)
        layer?.addSublayer(lowerboundPointerLayer)
        layer?.addSublayer(upperboundPointerLayer)
        layer?.addSublayer(valuePointerLayer)
        
        valueLayer2.shouldRasterize = true
        
        valueLayer2.strokeColor = tintColor.cgColor
        valueLayer2.lineWidth = ringWidth + 2
        layer?.addSublayer(valueLayer2)
    }
}
