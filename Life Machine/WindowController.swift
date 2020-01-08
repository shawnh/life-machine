//
//  WindowController.swift
//  Life Machine
//
//  Created by Shawn Hamman on 25/03/19.
//  Copyright © 2019 Shawn Hamman. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()

        if let window = window, let screen = window.screen {
            window.setFrame(screen.visibleFrame, display: true, animate: true)
        }
    }
    
}
