//
//  Graphics.swift
//  Life Machine
//
//  Created by Shawn Hamman on 5/01/20.
//  Copyright © 2020 Shawn Hamman. All rights reserved.
//

import Cocoa

class Graphics: NSObject {

    public static func toRad(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
    
    public static func isPointInTriangle(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x3: Double, _ y3: Double, tx: Double, ty: Double) -> Bool {
        let denominator = ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3))
        let a = ((y2 - y3) * (tx - x3) + (x3 - x2) * (ty - y3)) / denominator
        let b = ((y3 - y1) * (tx - x3) + (x1 - x3) * (ty - y3)) / denominator
        let c = 1 - a - b
     
        return (0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1)
    }
    
    public static func distance(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
        return (sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)))
    }
    
    public static func line(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, color: [Int], bitmap: inout NSBitmapImageRep) {
        var px = x1
        var py = y1
        let dx = abs(x2 - x1)
        let sx = (x1 < x2) ? 1 : -1
        let dy = -abs(y2 - y1);
        let sy = (y1 < y2) ? 1 : -1
        var err = dx + dy
        var c = color
        while true {
            bitmap.setPixel(&c, atX: px, y: py)
            
            if (px == Int(x2) && py == Int(y2)) {
                break
            }
            let e2 = 2*err
            if (e2 >= dy) {
                err += dy
                px += sx
            }
            if (e2 <= dx) {
                err += dx
                py += sy
            }
        }
    }
    
    public static func boxAroundPoint(_ x: Double, _ y: Double, radius: Int, color: [Int], bitmap: inout NSBitmapImageRep) {
        var c = color
        
        let x1 = Int(x) - radius
        let y1 = Int(y) - radius
        let x2 = Int(x) + radius
        let y2 = Int(y) + radius

        for x in x1...x2 {
            bitmap.setPixel(&c, atX: x, y: y1)
            bitmap.setPixel(&c, atX: x, y: y2)
        }
        for y in y1...y2 {
            bitmap.setPixel(&c, atX: x1, y: y)
            bitmap.setPixel(&c, atX: x2, y: y)
        }
    }
    
    public static func box(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, color: [Int], bitmap: inout NSBitmapImageRep) {
        var c = color

        for x in x1...x2 {
            bitmap.setPixel(&c, atX: x, y: y1)
            bitmap.setPixel(&c, atX: x, y: y2)
        }
        for y in y1...y2 {
            bitmap.setPixel(&c, atX: x1, y: y)
            bitmap.setPixel(&c, atX: x2, y: y)
        }
    }
    
    public static func circle(_ x: Double, _ y: Double, radius: Int, color: [Int], bitmap: inout NSBitmapImageRep) {
        var rx = radius - 1
        var ry = 0
        var dx = 1
        var dy = 1
        var err = dx - (radius << 1);
        
        var c = color
        
        while (rx >= ry) {
            bitmap.setPixel(&c, atX: Int(x) + rx, y: Int(y) + ry)
            bitmap.setPixel(&c, atX: Int(x) + ry, y: Int(y) + rx)
            bitmap.setPixel(&c, atX: Int(x) - ry, y: Int(y) + rx)
            bitmap.setPixel(&c, atX: Int(x) - rx, y: Int(y) + ry)
            bitmap.setPixel(&c, atX: Int(x) - rx, y: Int(y) - ry)
            bitmap.setPixel(&c, atX: Int(x) - ry, y: Int(y) - rx)
            bitmap.setPixel(&c, atX: Int(x) + ry, y: Int(y) - rx)
            bitmap.setPixel(&c, atX: Int(x) + rx, y: Int(y) - ry)
            
            if (err <= 0) {
                ry += 1;
                err += dy;
                dy += 2;
            }
            
            if (err > 0) {
                rx -= 1;
                dx += 2;
                err += dx - (radius << 1);
            }
        }
    }
    
}
