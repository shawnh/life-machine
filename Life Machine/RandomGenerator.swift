//
//  RandomGenerator.swift
//  Life Machine
//
//  Created by Shawn Hamman on 30/12/19.
//  Copyright © 2019 Shawn Hamman. All rights reserved.
//

import Cocoa

class LMRandomGenerator {
    var s = 0.0
    var v2 = 0.0
    var cachedNumberExists = false
    
    func sigmoid(_ v: Double) -> Double {
        return 1.0 / (1.0 + exp(-v))
    }
    
    var gaussRand: Double  {
        var u1, u2, v1, x : Double
        if !cachedNumberExists {
            repeat {
                u1 = Double(arc4random()) / Double(UINT32_MAX)
                u2 = Double(arc4random()) / Double(UINT32_MAX)
                v1 = 2 * u1 - 1
                v2 = 2 * u2 - 1
                s = v1 * v1 + v2 * v2
            } while (s >= 1 || s == 0)
            x = v1 * sqrt(-2 * log(s) / s)
        } else {
            x = v2 * sqrt(-2 * log(s) / s)
        }
        cachedNumberExists = !cachedNumberExists
        return x
    }
    
    var getRand: Double {
        return 1 - (self.gaussRand / 5.5)
    }
    
    var getRandRand: Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }
    
    var getNormalisedGaussRand: Double {
        return sigmoid(self.gaussRand)
    }
    
    public func getRandInt(_ low: Int, _ high: Int) -> Int {
        return Int.random(in: low...high)
    }
    
    public func getPRandom(t: Double) -> Double {
        //
        // TODO: Actually finish this
        //
        var v = t
        while v > 16 {
            v = v / 16
        }
        var y = 0.0
        y =  0.2 * sin(Double(1.5 * v))
        y += 0.2 * cos(Double(2.5 * v))
        y += 0.3 * sin(Double(5.25 * v))
        y += 0.2 * cos(Double(2.12 * v))
        y += 0.1 * sin(Double(3.05 * v))
        y += 0.15 * cos(Double(0.5 * v))
        y = abs(y)
        if y < 0 || y > 1 {
            y = sigmoid(y)
        }
        print(t, y)
        return y
    }
    
}
