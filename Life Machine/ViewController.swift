//
//  ViewController.swift
//  Life Machine
//
//  Created by Shawn Hamman on 4/03/19.
//  Copyright © 2019 Shawn Hamman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {
    var tick = 0.05
    var timer: Timer?
    
    @IBOutlet var canvas: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.WORLD.tick = tick
        canvas.WORLD.time = 0.0
        
        canvas.WORLD.RUNNING = true
        timer = Timer.scheduledTimer(timeInterval: tick, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    @objc func fireTimer() {
        canvas.needsDisplay = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}
