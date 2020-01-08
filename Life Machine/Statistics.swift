//
//  Statistics.swift
//  Life Machine
//
//  Created by Shawn Hamman on 1/01/20.
//  Copyright © 2020 Shawn Hamman. All rights reserved.
//

import Cocoa

class Statistics: NSObject {
    var HISTORY_LENGTH = 100
    var BAR_WIDTH = 2.0
    var PANEL_WIDTH = 300.0
    var PANEL_HEIGHT = 140.0
    var MAX_LINE_HEIGHT = 110.0
    var WIDTH = 0.0
    var HEIGHT = 0.0
    
    var RED = [255, 0, 0, 255]
    var GREEN = [0, 255, 0, 255]
    var YELLOW = [255, 255, 0, 255]
    
    var organismCount = [Int]()
    var foodCount = [Int]()
    
    var x1 = 0.0
    var y1 = 0.0
    var x2 = 0.0
    var y2 = 0.0
    
    func getMax(arrayToCount: [Int]) -> (Int, Int) {
        var maxV = 0
        var maxI = 0
        for (i, v) in arrayToCount.enumerated() {
            if v > maxV {
                maxV = v
                maxI = i
            }
        }
        return (maxI, maxV)
    }
    
    public func render(worldWidth: Double, worldHeight: Double, panelWidth: Double, panelHeight: Double, bitmap: inout NSBitmapImageRep) {
        WIDTH = worldWidth
        HEIGHT = worldHeight
        PANEL_WIDTH = panelWidth
        PANEL_HEIGHT = panelHeight
        MAX_LINE_HEIGHT = panelHeight - 18.0
        x1 = worldWidth - panelWidth
        y1 = worldHeight - panelHeight
        x2 = worldWidth
        y2 = worldHeight
        
        let barRect = CGRect(x: WIDTH - PANEL_WIDTH, y: 0, width: PANEL_WIDTH, height: PANEL_HEIGHT)

        NSColor.darkGray.set()
        __NSRectFill(barRect)
        
        let font = NSFont(name: "Courier", size: 9)
        let textRect = CGRect(x: WIDTH - PANEL_WIDTH, y: 0, width: PANEL_WIDTH, height: PANEL_HEIGHT)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.white,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        
        var maxV = 0
        var V = 0
        (_, V) = getMax(arrayToCount: organismCount)
        maxV = (V < 19) ? 18 : V
        (_, V) = getMax(arrayToCount: foodCount)
        maxV = (V > maxV) ? V : maxV
        
        let text = String(maxV) + "      Organisms: " + String(organismCount[0]) + "      Food: " + String(foodCount[0])
        text.draw(in: textRect, withAttributes: textFontAttributes as [NSAttributedString.Key : Any])
        
        var ox = x1 + 10
        let fy = y2 - 3
        for v in organismCount {
            let len = Double(v) / Double(maxV) * Double(MAX_LINE_HEIGHT)
            Graphics.line(Int(ox), Int(fy), Int(ox), Int(fy) - Int(len), color: GREEN, bitmap: &bitmap)
            ox += 4
        }
        
        var fx = x1 + 12
        for v in foodCount {
            let len = Double(v) / Double(maxV) * Double(MAX_LINE_HEIGHT)
            Graphics.line(Int(fx), Int(fy), Int(fx), Int(fy) - Int(len), color: YELLOW, bitmap: &bitmap)
            fx += 4
        }
    }
    
    public func logDataOrganismCount(count: Int) {
        organismCount.insert(count, at: 0)
        if organismCount.count > HISTORY_LENGTH {
            organismCount.removeLast()
        }
    }

    public func logDataFoodCount(count: Int) {
        foodCount.insert(count, at: 0)
        if foodCount.count > HISTORY_LENGTH {
            foodCount.removeLast()
        }
    }
    
    public func reset() {
        organismCount = [Int]()
        foodCount = [Int]()
    }
    
}
