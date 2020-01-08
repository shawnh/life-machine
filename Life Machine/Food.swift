//
//  Food.swift
//  Life Machine
//
//  Created by Shawn Hamman on 27/12/19.
//  Copyright © 2019 Shawn Hamman. All rights reserved.
//

import Cocoa

extension Array where Iterator.Element == Food {
    
    func countHasEnergy() -> Int {
        var count = 0
        for f in self {
            if f.energy > 0 {
                count += 1
            }
        }
        return count
    }
    
}

class Food: NSObject {
    var myID = -1
    
    var WHITE = [255, 255, 255, 255]
    var BLACK = [0, 0, 0, 255]
    var RED = [255, 0, 0, 255]
    var GREEN = [0, 255, 0, 255]
    var BLUE = [0, 0, 255, 255]
    var YELLOW = [255, 255, 0, 255]
    var DYELLOW = [128, 128, 0, 255]
    var ORANGE = [255, 128, 0, 255]
    var DORANGE = [128, 64, 0, 255]
    
    var x = 0.0
    var y = 0.0
    var x1 = 0
    var y1 = 0
    var x2 = 0
    var y2 = 0
    var energy = 0.0
    
    let RAND = LMRandomGenerator()
    var WIDTH = 0.0
    var HEIGHT = 0.0

    public func isFoodAt(_ fx: Int, _ fy: Int) -> Bool {
        return (fx >= x1 && fx <= x2 && fy >= y1 && fy <= y2)
    }
    
    public func render(bitmap: inout NSBitmapImageRep) {
        Graphics.box(x1, y1, x2, y2, color: WHITE, bitmap: &bitmap)
        bitmap.setPixel(&WHITE, atX: Int(x), y: Int(y))
    }
    
    func setBox() {
        x1 = Int(x) - 3
        y1 = Int(y) - 3
        x2 = Int(x) + 3
        y2 = Int(y) + 3
    }
    
    public func eat() -> Double {
        x = -1000
        y = -1000
        setBox()
        energy = 0
        return energy
    }
    
    func getDataForTime(input: Double, c: Int) -> Double {
        let t = input / HEIGHT * 3 * Double.pi
        var vy = 0.0
        var v = 0.0
        for _ in 0...c {
            v = sin(Double(-t))
            if vy == 0 {
                vy = v
            } else {
                vy = vy * v
            }
        }

        vy = vy - 0.25
        return vy
    }
    
    public func create(width: Double, height: Double, homeX: Double, homeY: Double, homeR: Double) {
        WIDTH = width
        HEIGHT = height
        
        let x1 = homeX - homeR
        let x2 = homeX + homeR
        let y1 = homeY - homeR
        let y2 = homeY + homeR

        let distance = (height / 3) + (RAND.getRandRand * 250)
        let direction = 360.0 * RAND.getRandRand
        
        x = homeX + (distance * cos((direction * Double.pi / 180)))
        y = homeY + (distance * sin((direction * Double.pi / 180)))
        
        while ( ((x <= 0 || x >= width) || (y <= 0 || y >= height)) ||
                ((x >= x1 && x <= x2) && (y >= y1 && y <= y2)) ) {
            
            let distance = (height / 5) + (RAND.getRandRand * 150)
            let direction = 360.0 * RAND.getRandRand
            
            x = homeX + (distance * cos((direction * Double.pi / 180)))
            y = homeY + (distance * sin((direction * Double.pi / 180)))
        }
        
        setBox()
        energy = RAND.getRandRand * 1500
    }

}
