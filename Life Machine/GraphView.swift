//
//  GraphView.swift
//  Life Machine
//
//  Created by Shawn Hamman on 4/03/19.
//  Copyright © 2019 Shawn Hamman. All rights reserved.
//

import Cocoa

class GraphView: NSView {
    let WORLD = World()
    
    var WIDTH = 1280.0
    var HEIGHT = 800.0
    
    func clearPreviousViews() {
        for view in self.subviews {
            if view.className == "NSImageView" {
                view.removeFromSuperview()
            }
        }
    }
    
    func render() {
        if !WORLD.RUNNING {
            return
        }
        clearPreviousViews()
        
        var bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(WIDTH), pixelsHigh: Int(HEIGHT), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
        
        WORLD.initialise(height: Double(bounds.height), width: Double(bounds.width), reset: false)
        WORLD.main(bitmap: &bitmap!)
        
        let p = NSImageView(frame: NSRect(x: 0, y: 0, width: Int(WIDTH), height: Int(HEIGHT)))
        //let bgRect = CGRect(x: 1, y: 1, width: Int(WIDTH), height: Int(HEIGHT))
        //NSColor.white.set()
        //__NSRectFill(bgRect)
        p.image = NSImage(data:bitmap!.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!)
        self.addSubview(p)
    }
    
    func toggleWaveVisuals() {
        WORLD.showWaves = (WORLD.showWaves) ? false : true
    }
    
    func toggleRunning() {
        WORLD.RUNNING = (WORLD.RUNNING == true) ? false : true
    }
    
    override func mouseDown(with event: NSEvent) {
        let p = event.locationInWindow
        let px = Double(p.x)
        let py = HEIGHT - Double(p.y)
        for org in WORLD.o {
            if Graphics.distance(px, py, org.x, org.y) <= 9 {
                WORLD.watchID = org.myID
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)
        if event.keyCode == 1 {
            WORLD.forceProcreate()
        }
        if event.keyCode == 15 {
            WORLD.initialise(height: Double(bounds.height), width: Double(bounds.width), reset: true)
            WORLD.time = 0.0
            render()
        }
        if event.keyCode == 7 {
            toggleRunning()
        }
        if event.keyCode == 8 {
            WORLD.o.removeAll(where: {$0.isAlive == false})
        }
        if event.keyCode == 12 {
            NSApplication.shared.terminate(self)
        }
        if event.keyCode == 32 || event.keyCode == 17 {
            toggleWaveVisuals()
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        HEIGHT = Double(bounds.height)
        WIDTH = Double(bounds.width)
        
        render()
    }
        
}
