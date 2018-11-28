//
//  Slider.swift
//  SHSlider
//
//  Created by WangRex on 11/25/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa


/// A multislider panel, contains a ring, 2 labels and an output value display
@IBDesignable open class SHMultiSlider: NSControl {
    private let nibName = "SHMultiSlider"
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var sourceLabel: NSTextField!
    @IBOutlet weak var targetLabel: NSTextField!
    @IBOutlet weak var outputValue: NSTextField!
    @IBOutlet weak var gatedIndicator: TextButton!
    @IBOutlet weak var reverseIndicator: TextButton!
    @IBOutlet weak var ring: SHKnobRing!
    
    private let bundle = Bundle(for: SHMultiSlider.self)
    
    
    
    /// delegate
    open var delegate: SHMultiSliderDelegate?
    
    
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    
    /// Text for the label at the top
    public var sourceName: String = "Source" {
        didSet {
            sourceLabel.stringValue = sourceName
        }
    }
    
    
    /// Text for the label at the bottom
    public var targetName: String = "Target" {
        didSet {
            targetLabel.stringValue = targetName
        }
    }
    
    private var value: Float = 0 {
        didSet {
            ring.setValue(value)
        }
    }
    
    /// Value pointer will jump within upper/lower bounds when it's true, else it will jump between min/map. Default is true
    @IBInspectable public var hardclipValuePointer: Bool = true {
        didSet {
            ring.hardclipValuePointer = hardclipValuePointer
        }
    }
    
    /// Min of input value
    @IBInspectable public var min: Float = 0 {
        didSet {
            ring.min = min
        }
    }
    
    /// Max of input value
    @IBInspectable public var max: Float = 127 {
        didSet {
            ring.max = max
        }
    }
    
    @IBInspectable open override var isEnabled: Bool {
        didSet {
            ring.isEnabled = isEnabled
            self.gatedIndicator.textColor = isEnabled ? NSColor.labelColor : NSColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
            self.reverseIndicator.textColor = isEnabled ? NSColor.labelColor : NSColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        }
    }
    
    /// Created for my own use, when set to true, "G" label at the bottom will light up
    @IBInspectable public var isGated: Bool = false {
        didSet {
            gatedIndicator.textColor = isGated ? NSColor.red: NSColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        }
    }
    
    /// Created for my own use, when set to true, "R" label at the bottom will light up
    @IBInspectable public var isReversed: Bool = false {
        didSet {
            reverseIndicator.textColor = isReversed ? NSColor.orange: NSColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        }
    }
    
    
    open override func layoutSubtreeIfNeeded() {
        ring.updateBounds(self.contentView.bounds)
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        bundle.loadNibNamed(.init(nibName), owner: self, topLevelObjects: nil)
        self.addSubview(contentView)
        setupUI()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        bundle.loadNibNamed(.init(nibName), owner: self, topLevelObjects: nil)
        self.addSubview(contentView)
        setupUI()
    }
    
    
    
    private func setupUI() {
        self.wantsLayer = true
        min = 0
        max = 127
        ring.delegate = self
        let length = Swift.min(self.bounds.width, self.bounds.height)
        self.contentView.frame = NSRect(x: 0, y: 0, width: length, height: length)
        self.isEnabled = true
        ring.reset()
        sourceName = "Source"
        targetName = "Target"
        ring.updateBounds(self.contentView.frame)
        hardclipValuePointer = true
    }
    
    open override var intrinsicContentSize: NSSize {
        return NSSize(width: 100, height: 100)
    }
    
    /// Set upper bound's value
    ///
    /// - Parameter newValue: new upper bound value, output value will be remapped from min-max to lowerBound-upperBound
    public func setUpperBoundValue(_ newValue: Int) {
        ring.setUppderBoundValue(Float(newValue))
    }
    
    /// Set lower bound's value
    ///
    /// - Parameter newValue: new lower bound value, output value will be remapped from min-max to lowerBound-upperBound
    public func setLowerBoundValue(_ newValue: Int) {
        ring.setLowerBoundValue(Float(newValue))
    }
    
    
    /// Set value for the ring's value pointer
    ///
    /// - Parameter newValue: input value to be displayed
    public func setValue(_ newValue: Int) {
        value = Float(newValue)
    }
    
    
    /// Update view bounds, call this on superview's viewDidLayout()
    ///
    /// - Parameter bounds: new bounds rect
    public func updateBounds(_ bounds: CGRect) {
        ring.updateBounds(bounds)
    }
    
    @IBAction func gateIndicatorClicked(_ sender: TextButton) {
        guard isEnabled else {return}
        self.isGated = !self.isGated
        delegate?.gateModeChanged(self, isGated)
    }
    
    @IBAction func reverseIndicatorClicked(_ sender: TextButton) {
        guard isEnabled else {return}
        self.isReversed = !self.isReversed
        delegate?.reversedModeChanged(self, isReversed)
    }
    
}


// MARK: - Implementations for SHKnobRing's delegate
extension SHMultiSlider: SHKnobRingDelegate {
    public func knobValueUpdated(value: Int) {
        outputValue.stringValue = String(value)
        delegate?.valueChanged(self, value)
    }
    public func knobBoundsUpdated(lower: Int, upper: Int) {
        sourceLabel.stringValue = "Min: \(lower)"
        targetLabel.stringValue = "Max: \(upper)"
        delegate?.boundsUpdated(self, lower: lower, upper: upper)
    }
    public func knobBoundsFinishUpdate() {
        sourceLabel.stringValue = sourceName
        targetLabel.stringValue = targetName
    }
    
    public func gateModeChanged(_ isGated: Bool) {
        self.isGated = isGated
        delegate?.gateModeChanged(self, isGated)
    }
    
    public func reversedModeChanged(_ isReversed: Bool) {
        self.isReversed = isReversed
        delegate?.reversedModeChanged(self, isReversed)
    }
}


/// Delegate of SHMultiSlider
public protocol SHMultiSliderDelegate {
    func valueChanged(_ sender: SHMultiSlider?, _ newValue: Int)
    func boundsUpdated(_ sender: SHMultiSlider?, lower: Int, upper: Int)
    func gateModeChanged(_ sender: SHMultiSlider?, _ isGated: Bool)
    func reversedModeChanged(_ sender: SHMultiSlider?, _ isReversed: Bool)
}

public extension SHMultiSliderDelegate {
    func valueChanged(_ sender: SHMultiSlider?, _ newValue: Int) {
        
    }
    
    func boundsUpdated(_ sender: SHMultiSlider?, lower: Int, upper: Int) {
        
    }
    
    func gateModeChanged(_ sender: SHMultiSlider?, _ isGated: Bool) {
        
    }
    
    func reversedModeChanged(_ sender: SHMultiSlider?, _ isReversed: Bool) {
        
    }
}

internal class TextButton: NSTextField {
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.sendAction(self.action, to: self.target)
    }
}
