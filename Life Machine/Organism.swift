//
//  Organism.swift
//  Life Machine
//
//  Created by Shawn Hamman on 9/03/19.
//  Copyright © 2019 Shawn Hamman. All rights reserved.
//

import Cocoa

extension Array where Iterator.Element == Organism {
    
    func countAlive() -> Int {
        var count = 0
        for o in self {
            if o.isAlive {
                count += 1
            }
        }
        return count
    }
    
}

class Organism: NSObject {
    var myID = -1
    let GENE_COUNT = 30
    
    var GRAY = [128, 128, 128, 255]
    var WHITE = [255, 255, 255, 255]
    var BLACK = [0, 0, 0, 255]
    var RED = [255, 0, 0, 255]
    var GREEN = [0, 255, 0, 255]
    var BLUE = [0, 0, 255, 255]
    var LBLUE = [135, 206, 250, 255]
    var YELLOW = [255, 255, 0, 255]
    var DYELLOW = [128, 128, 0, 255]
    var ORANGE = [255, 128, 0, 255]
    var DORANGE = [128, 64, 0, 255]
    
    var COLORS = [[Int]]()
    
    let RAND = LMRandomGenerator()
    var complexity = 0
    var speedFactor = 4.0
    
    var GENOME = Genome()
    
    var x = 0.0
    var y = 0.0
    var x1 = 0.0
    var x2 = 0.0
    var y1 = 0.0
    var y2 = 0.0
    var hr = 0.0
    var direction = 0.0
    var lookDirection = 0.0
    var lookPanSpeed = 0.0
    var lookDistance = 0.0
    var lookArc = 0.0
    var memoryCurrent = 0.0
    var memoryBase = 0.0
    var memoryDegrade = 0.0
    var health = 100.0
    var regenRate = 1.1
    var regenAvail = 0.0
    var regenBase = 100.0
    var lastEnergyUse = 0.0
    var moveEngergy = 0.1
    var energyEfficiency = 2.0
    var imperative = 0.0
    var focussed = true
    var clanColor = [0, 0, 0, 0]
    var familyColor = [0, 0, 0, 0]
    
    var eatCount = 0
    var isAlive = false
    
    func updateHealth(vector: Double) {
        if vector == 0 && lastEnergyUse == 0 {
            if regenAvail > 0 {
                health += regenRate
                regenAvail -= regenRate
            } else if eatCount > 0 {
                eatCount -= 1
                regenAvail += regenBase
            }
        } else {
            health -= (vector / energyEfficiency)
        }
        lastEnergyUse = vector
        isAlive = (health <= 0 || health >= 4000) ? false : true
    }
    
    func wrap(n: Double, max: Double) -> Double {
        let ret = (n < 0) ? (n + max) : n
        return (ret > max) ? (ret - max) : ret
    }
    
    func updateLookDirection(t: Double) {
        let c = Int(complexity / 2)
        lookDirection += (getDataForTime(t: t, c: c) * (GENOME.genotype[18].getValue() + GENOME.genotype[21].getValue() + GENOME.genotype[23].getValue() + GENOME.genotype[25].getValue()))
        lookDirection = (lookDirection > 360) ? lookDirection - 360 : lookDirection
        lookDirection = (lookDirection < 0) ? lookDirection + 360 : lookDirection
    }
    
    func getNextLocation(t: Double, width: Double, height: Double) -> (Double, Double) {
        if memoryCurrent <= 0 {
            memoryCurrent = 0
            let c = Int((GENOME.genotype[18].getValue() + GENOME.genotype[19].getValue()) * 1.5)
            direction += (getDataForTime(t:t, c: c) / (GENOME.genotype[18].getValue() * 4.0))
            direction = (direction > 360) ? direction - 360 : direction
            direction = (direction < 0) ? direction + 360 : direction
        } else {
            memoryCurrent -= memoryDegrade
        } 
        
        let energy = getDataForTime(t: t, c: complexity) + (GENOME.genotype[20].getValue() * 2)
        var speed = 0.0
        if  energy > 0 {
            speed = abs(energy) * speedFactor
        } else if memoryCurrent > 0 {
            speed = 1
        }
        
        x = wrap(n: (x + (speed * cos(Graphics.toRad(direction)))), max: width)
        y = wrap(n: (y + (speed * sin(Graphics.toRad(direction)))), max: height)
        
        updateHealth(vector: speed)
        updateLookDirection(t: t)
        
        return (x, y)
    }
    
    func getDataForTime(t: Double, c: Int) -> Double {
        var vy = 0.0
        var v = 0.0
        let m = (c > 5) ? 5 : c
        for i in 20...20 + m {
            let f = GENOME.genotype.count - (i + 1)
            if GENOME.genotype[f].getValue() > GENOME.genotype[f - 1].getValue() {
                v = (GENOME.genotype[i].getValue() * 2.8) * sin(Double(-t * (GENOME.genotype[i].getValue() * 3.5)))
            } else {
                v = (GENOME.genotype[i].getValue() * 2.8) * cos(Double(-t * (GENOME.genotype[i].getValue() * 3.5)))
            }
            if vy == 0 {
                vy = v
            } else {
                vy = vy * v
            }
        }

        vy = vy - 0.25
        return vy
    }
    
    func generateLookArc(t: Double, food: inout [Food], bitmap: inout NSBitmapImageRep) {
        let arc = lookArc
        let halfArc = (arc / 2)
        var sweepFrom = 0.0
        var sweepTo = 0.0
        var seeFood = false

        if (lookDirection + halfArc > 360) {
            sweepFrom = lookDirection - halfArc
            sweepTo = lookDirection + halfArc - 360
        } else if (lookDirection - halfArc < 0) {
            sweepFrom = lookDirection - halfArc + 360
            sweepTo = lookDirection + halfArc
        } else {
            sweepFrom = lookDirection - halfArc
            sweepTo = lookDirection + halfArc
        }
        
        let dx1 = x + (lookDistance * cos(Graphics.toRad(sweepFrom)))
        let dy1 = y + (lookDistance * sin(Graphics.toRad(sweepFrom)))
        let dx2 = x + (lookDistance * cos(Graphics.toRad(sweepTo)))
        let dy2 = y + (lookDistance * sin(Graphics.toRad(sweepTo)))
        //
        // TODO: Implement food vs. procreation imperative
        //
        /*
        let imperative = Double(eatCount) / genes[14] * sin(Double(-t))
        if myID == 1 {
            print(imperative, eatCount, genes[14], sin(Double(-t)))
        }
        */
        if (true) {
            for f in food {
                if ((memoryCurrent == 0 || focussed == false) && Graphics.isPointInTriangle(dx1, dy1, dx2, dy2, x, y, tx: f.x, ty: f.y)) {
                    seeFood = true
                    let radiansDir = atan2((f.y - y),(f.x - x))
                    let degreesDir = radiansDir * (180 / Double.pi)
                    direction = (degreesDir < 0) ? degreesDir + 360 : degreesDir
                    //
                    // Flash a sight line in direction food was spotted?
                    // TODO: maybe remove?
                    //
                    let tx = x + (100 * cos(Graphics.toRad(direction)))
                    let ty = y + (100 * sin(Graphics.toRad(direction)))
                    Graphics.line(Int(x), Int(y), Int(tx), Int(ty), color: RED, bitmap: &bitmap)
                    
                    memoryCurrent = memoryBase
                }
            }
        } else {
            //
            // food vs. procreate imperative?
            //
        }
        let c = (seeFood) ? RED : LBLUE
        Graphics.line(Int(x), Int(y), Int(dx1), Int(dy1), color: c, bitmap: &bitmap)
        Graphics.line(Int(x), Int(y), Int(dx2), Int(dy2), color: c, bitmap: &bitmap)
        Graphics.line(Int(dx1), Int(dy1), Int(dx2), Int(dy2), color: c, bitmap: &bitmap)
    }
    
    func drawMoveDirectionLine(bitmap: inout NSBitmapImageRep) {
        let dx = x + (25 * cos(Graphics.toRad(direction)))
        let dy = y + (25 * sin(Graphics.toRad(direction)))
        let c = (eatCount > 1) ? GREEN : ORANGE
        Graphics.line(Int(x), Int(y), Int(dx), Int(dy), color: c, bitmap: &bitmap)
    }
    
    func eatCloseFood(food: inout [Food]) {
        for f in food {
            if Graphics.distance(x, y, f.x, f.y) <= 10 {
                health += f.eat()
                eatCount += 1
                memoryCurrent = 0
                return
            }
        }
    }
    
    func isHome() -> Bool {
        return (x >= x1 && x <= x2 && y >= y1 && y <= y2)
    }
    
    public func render(t: Double, boxW: Double, boxH: Double, highlight: Bool, food: inout [Food], bitmap: inout NSBitmapImageRep) -> Bool {
        if isAlive {
            if eatCount > 1 && isHome() {
                return true
            }
            eatCloseFood(food: &food)
            (_, _) = getNextLocation(t: t, width: boxW, height: boxH)
            
            Graphics.circle(x, y, radius: 5, color: familyColor, bitmap: &bitmap)
            Graphics.circle(x, y, radius: 9, color: clanColor, bitmap: &bitmap)
            
            if highlight {
                bitmap.setPixel(&RED, atX: Int(x), y: Int(y))
                Graphics.circle(x, y, radius: 2, color: RED, bitmap: &bitmap)
                Graphics.circle(x, y, radius: 3, color: RED, bitmap: &bitmap)
            } else {
                bitmap.setPixel(&familyColor, atX: Int(x), y: Int(y))
            }
            drawMoveDirectionLine(bitmap: &bitmap)
            generateLookArc(t: t, food: &food, bitmap: &bitmap)
        } else {
            Graphics.circle(x, y, radius: 5, color: GRAY, bitmap: &bitmap)
            Graphics.circle(x, y, radius: 9, color: GRAY, bitmap: &bitmap)
            var c = COLORS[0]
            bitmap.setPixel(&c, atX: Int(x), y: Int(y))
        }
        return false
    }
    
    public func create(width: Double, height: Double, homeX: Double, homeY: Double, homeR: Double, fromParentGenome: Genome? = nil) {
        COLORS.append(GRAY)
        COLORS.append(BLACK)
        COLORS.append(WHITE)
        COLORS.append(RED)
        COLORS.append(GREEN)
        COLORS.append(DYELLOW)
        COLORS.append(YELLOW)
        COLORS.append(ORANGE)
        COLORS.append(DORANGE)
        
        if fromParentGenome != nil {
            GENOME = Genome(copyFromGenome: fromParentGenome)
        } else {
            GENOME = Genome()
        }
        
        complexity = Int(GENOME.genotype[0].getValue() * 7.0)
        direction = GENOME.genotype[1].getValue() * 360
        speedFactor = GENOME.genotype[2].getValue() * 3.5
        
        lookDirection = GENOME.genotype[3].getValue() * 360
        lookDistance = 150 * (GENOME.genotype[4].getValue())
        lookArc = 20 - (GENOME.genotype[5].getValue() * 4)
        
        energyEfficiency = GENOME.genotype[7].getValue() * 14
        regenRate = GENOME.genotype[8].getValue() * 3.9
        regenBase = (GENOME.genotype[9].getValue()) * 300
        regenAvail = regenBase
        health = GENOME.genotype[10].getValue() * 2000
        
        memoryBase = 250 * GENOME.genotype[11].getValue()
        memoryDegrade = GENOME.genotype[12].getValue()
        focussed = (GENOME.genotype[13].getValue() > 0.5)
        
        clanColor[0] = Int(128 * abs(GENOME.genotype[14].getValue() + 55))
        clanColor[1] = Int(128 * abs(GENOME.genotype[15].getValue() + 55))
        clanColor[2] = Int(128 * abs(GENOME.genotype[16].getValue() + 55))
        clanColor[3] = 255
        
        familyColor[0] = Int(128 * abs(GENOME.genotype[17].getValue() * 2))
        familyColor[1] = Int(128 * abs(GENOME.genotype[18].getValue() * 2))
        familyColor[2] = Int(128 * abs(GENOME.genotype[19].getValue() * 2))
        familyColor[3] = 255
        
        x = (RAND.getRandRand * homeR) + homeX
        y = (RAND.getRandRand * homeR) + homeY
        x1 = homeX - homeR
        x2 = homeX + homeR
        y1 = homeY - homeR
        y2 = homeY + homeR
        hr = homeR
        
        isAlive = true
    }
    
}
