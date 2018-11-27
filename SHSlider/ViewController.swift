//
//  ViewController.swift
//  SHSlider
//
//  Created by WangRex on 11/25/18.
//  Copyright © 2018 WangRex. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var slider: SHMultiSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        slider.ring.setLowerBoundValue(30)
//        slider.ring.setUppderBoundValue(80)
//        slider.ring.setValue(100)
//        slider.ring.ringWidth = 5
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

