//
//  SHBipolarSlider.swift
//  KnobT
//
//  Created by WangRex on 12/1/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa

open class SHBipolarSlider: SHMultiSlider {
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        object_setClass(self.ring, SHBipolarRing.self)
        self.ring.delegate = self
        self.isGated = false
        self.valueNeedsRemap = false
        self.hardclipValuePointer = false
        self.gatedIndicator.isHidden = true
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        object_setClass(self.ring, SHBipolarRing.self)
        self.gatedIndicator.isHidden = true
        self.isGated = false
        self.valueNeedsRemap = false
        self.hardclipValuePointer = false
    }
}
