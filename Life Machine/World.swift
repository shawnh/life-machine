//
//  World.swift
//  Life Machine
//
//  Created by Shawn Hamman on 5/01/20.
//  Copyright © 2020 Shawn Hamman. All rights reserved.
//

import Cocoa

class World: NSObject {
    var RUNNING = false
    let ORGANISMS = 10
    let FOOD_COUNT = 50
    let FOOD_REGEN = 5
    
    var WIDTH = 1280.0
    var HEIGHT = 800.0
    
    var BOTTOM_PANEL_HEIGHT = 145.0
    var BOTTOM_PANEL_WIDTH = 300.0
    
    var MX = 400.0
    var MY = 640.0
    var HOME_RADIUS = 100.0
    
    let FACTOR = 100.0
    let DAYS = 10
    let DRAW_HOUR_LINES = false
    let DRAW_DAY_MARKER_LINES = false
    
    var WHITE = [255, 255, 255, 255]
    var BLACK = [0, 0, 0, 255]
    var RED = [255, 0, 0, 255]
    var GREEN = [0, 255, 0, 255]
    var BLUE = [0, 0, 255, 255]
    var YELLOW = [255, 255, 0, 255]
    var DYELLOW = [128, 128, 0, 255]
    var ORANGE = [255, 128, 0, 255]
    var DORANGE = [128, 64, 0, 255]
    var LGRAY = [200, 200, 200, 255]
    var DGRAY = [100, 100, 100, 255]
    var COLORS = [[Int]]()
    
    let RAND = LMRandomGenerator()
    let STATS = Statistics()
    let G = Genealogy()
    
    var o: [Organism] = []
    var f: [Food] = []
    var tick = 0.0
    var time = 0.0
    var dawn = false
    var frameCount = 0
    var showWaves = false
    var watchID = -1
    var foodRegen = 0
    var genePool = [Double]()
    var orgCount = 0
    
    func drawAxis(bitmap: inout NSBitmapImageRep) {
        for x in 0...Int(WIDTH) {
            //Top Line
            bitmap.setPixel(&LGRAY, atX: x, y: 0)
            //Bottom Line
            bitmap.setPixel(&LGRAY, atX: x, y: Int(HEIGHT) - 1)
            //X Axis
            bitmap.setPixel(&LGRAY, atX: x, y: Int(MY))
        }
        
        for y in 0...Int(HEIGHT) {
            //Left Line
            bitmap.setPixel(&LGRAY, atX: 0, y: y)
            //Right Line
            bitmap.setPixel(&LGRAY, atX: Int(WIDTH) - 1, y: y)
        }
        
        if (DRAW_HOUR_LINES) {
            for day in 0...DAYS {
                for hour in 0...24 {
                    let hour_part = (1.0 / 24.0) * Double(hour)
                    let x = (Double(day) + hour_part) * Double.pi * FACTOR
                    for y in 0...Int(HEIGHT) {
                        bitmap.setPixel(&DGRAY, atX: Int(x), y: y)
                    }
                }
            }
        }
        
        if DRAW_DAY_MARKER_LINES {
            //Dawn Lines
            for day in stride(from: 0, through: DAYS, by: 2) {
                let x1 = Double(day) * Double.pi * FACTOR
                let x2 = (Double(day) + 0.5) * Double.pi * FACTOR
                let x3 = (Double(day) + 1.0) * Double.pi * FACTOR
                let x4 = (Double(day) + 1.5) * Double.pi * FACTOR
                for y in 0...Int(HEIGHT) {
                    bitmap.setPixel(&DYELLOW, atX: Int(x1), y: y)
                    bitmap.setPixel(&WHITE, atX: Int(x2), y: y)
                    bitmap.setPixel(&DORANGE, atX: Int(x3), y: y)
                    bitmap.setPixel(&BLACK, atX: Int(x4), y: y)
                }
            }
        }
    }
    
    func generateDayWave(bitmap: inout NSBitmapImageRep) {
        for vx in stride(from: 0.0, through: (Double(WIDTH) / FACTOR), by: (1.0 / FACTOR)) {
            let x = Int(vx * FACTOR)
            let y = Int((sin(Double(-vx)) * MY) + MY)
            bitmap.setPixel(&YELLOW, atX: x, y: y)
        }
    }
    
    func generateOrganismWave(organism: Organism, bitmap: inout NSBitmapImageRep) {
        for vx in stride(from: 0.0, through: (Double(WIDTH) / FACTOR), by: (1.0 / FACTOR)) {
            let x = Int(vx * FACTOR)
            let y = Int((organism.getDataForTime(t: vx, c: organism.complexity) * MY) + MY)
            bitmap.setPixel(&GREEN, atX: x, y: y)
        }
    }
    
    func drawDayIndicator(t: Double, bitmap: inout NSBitmapImageRep) {
        let x = t * FACTOR
        let y = (sin(Double(-t)) * MY) + MY
        Graphics.boxAroundPoint(x, y, radius: 3, color: COLORS[5], bitmap: &bitmap)
    }
    
    func drawOrgCycleIndicator(organism: Organism, t: Double, bitmap: inout NSBitmapImageRep) {
        let x = t * FACTOR
        let y = (organism.getDataForTime(t: t, c: organism.complexity) * MY) + MY
        Graphics.boxAroundPoint((x + 0), (y + 0), radius: 3, color: COLORS[3], bitmap: &bitmap)
    }
    
    func renderHUDBox(text: String) {
        let font = NSFont(name: "Courier", size: 9)
        let textRect = CGRect(x: 1, y: 1, width: BOTTOM_PANEL_WIDTH, height: BOTTOM_PANEL_HEIGHT)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.white,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]

        NSColor.darkGray.set()
        __NSRectFill(textRect)
        
        text.draw(in: textRect, withAttributes: textFontAttributes as [NSAttributedString.Key : Any])
    }
    
    public func forceProcreate() {
        for organism in o {
            let newO = Organism()
            newO.create(homeX: MX, homeY: MY, homeR: HOME_RADIUS, fromParentGenome: organism.GENOME)
            newO.myID = orgCount
            o.append(newO)
            G.addOrganism(id: orgCount, genes: genePool, parent: organism.myID)
            orgCount += 1
        }
    }
    
    public func main(bitmap: inout NSBitmapImageRep) {
        if !RUNNING {
            return
        }
        //
        // Timing starts
        //
        var info = mach_timebase_info()
        guard mach_timebase_info(&info) == KERN_SUCCESS else { return }
        let start = mach_absolute_time()
        //
        // Main
        //
        time += (tick / 5)
        if time > (5 * Double.pi) {
            time = 0.0
        }
        
        let sunEngergy = sin(Double(-time))
        if sunEngergy > 0 && !dawn {
            //
            // Dawn of a new day
            //
            dawn = true
            foodRegen = FOOD_REGEN
        } else if sunEngergy < 0 {
            dawn = false
        }
        frameCount += 1

        var watchIndex = 0
            
        Graphics.boxAroundPoint(MX, MY, radius: Int(HOME_RADIUS), color: COLORS[1], bitmap: &bitmap)
        
        if showWaves {
            drawAxis(bitmap: &bitmap)
            generateDayWave(bitmap: &bitmap)
            drawDayIndicator(t: time, bitmap: &bitmap)
        }
        
        var didProcreate = false
        for (i, organism) in o.enumerated() {
            if organism.render(t: time, worldWidth: WIDTH, worldHeight: HEIGHT, homeX: MX, homeY: MY, homeR: HOME_RADIUS, highlight: (organism.myID == watchID), food: &f, bitmap: &bitmap) {
                print("ID: " + String(organism.myID) + " spawning " + String(organism.eatCount) + " children")
                
                for _ in 1...organism.eatCount {
                    let newO = Organism()
                    newO.create(homeX: MX, homeY: MY, homeR: HOME_RADIUS, fromParentGenome: organism.GENOME)
                    newO.myID = orgCount
                    o.append(newO)
                    G.addOrganism(id: orgCount, genes: genePool, parent: organism.myID)
                    orgCount += 1
                    
                    didProcreate = true
                    
                    if organism.GENOME.genotype[27].getValue() > 0.95 {
                        print("TWINS!")
                        let newO = Organism()
                        newO.create(homeX: MX, homeY: MY, homeR: HOME_RADIUS, fromParentGenome: organism.GENOME)
                        newO.myID = orgCount
                        o.append(newO)
                        G.addOrganism(id: orgCount, genes: genePool, parent: organism.myID)
                        orgCount += 1
                    }
                }
                
                organism.health = 0
                organism.isAlive = false
            }
            
            if showWaves {
                generateOrganismWave(organism: organism, bitmap: &bitmap)
                drawOrgCycleIndicator(organism: organism, t: time, bitmap: &bitmap)
            }
            
            if organism.myID == watchID {
                watchIndex = i
            }
        }
        if didProcreate {
            o.removeAll(where: {$0.isAlive == false})
            STATS.logDataOrganismCount(count: o.countAlive())
        }
        
        for (i, foodItem) in f.enumerated() {
            foodItem.myID = i
            foodItem.render(bitmap: &bitmap)
        }
        f.removeAll(where: {$0.energy == 0})
        
        if sunEngergy > 0.5 && f.count < FOOD_COUNT + 1 && foodRegen > 0 {
            for _ in f.count...FOOD_COUNT + 1 {
                let newF = Food()
                newF.create(width: WIDTH, height: HEIGHT, homeX: MX, homeY: MY, homeR: HOME_RADIUS)
                f.append(newF)
                foodRegen -= 1
                if foodRegen <= 0 {
                    break
                }
            }
            STATS.logDataFoodCount(count: f.countHasEnergy())
        }
        
        if (frameCount % 10 == 0) {
            STATS.logDataOrganismCount(count: o.countAlive())
            STATS.logDataFoodCount(count: f.countHasEnergy())
        }
        STATS.render(worldWidth: WIDTH, worldHeight: HEIGHT, panelWidth: BOTTOM_PANEL_WIDTH, panelHeight: BOTTOM_PANEL_HEIGHT,  bitmap: &bitmap)
        G.render(worldWidth: WIDTH, worldHeight: HEIGHT, panelWidth: BOTTOM_PANEL_WIDTH, panelHeight: BOTTOM_PANEL_HEIGHT,  bitmap: &bitmap)
        
        watchIndex = (watchIndex > o.count) ? 0 : watchIndex
        
        var hudText = "Time: " + String(time) + " Frame: " + String(frameCount) + "\n"
        hudText = hudText + "Organism: " + String(watchID) + "\n"
        hudText = hudText + "Eat Count: " + String(o[watchIndex].eatCount) + "\n"
        hudText = hudText + "Health: " + String(o[watchIndex].health) + "\n"
        hudText = hudText + "Regen: " + String(o[watchIndex].regenRate) + "\n"
        hudText = hudText + "Regen Base: " + String(o[watchIndex].regenBase) + "\n"
        hudText = hudText + "Regen Avail: " + String(o[watchIndex].regenAvail) + "\n"
        hudText = hudText + "Energy: " + String(o[watchIndex].lastEnergyUse) + "\n"
        hudText = hudText + "Speed: " + String(o[watchIndex].speedFactor) + "\n"
        hudText = hudText + "Efficiency: " + String(o[watchIndex].energyEfficiency) + "\n"
        hudText = hudText + "Memory: " + String(o[watchIndex].memoryCurrent) + "\n"
        hudText = hudText + "Focussed: " + String(o[watchIndex].focussed) + "\n"
        
        //generateOrganismWave(organism: o[watchIndex], bitmap: &bitmap)
        
        //
        // Timing ends
        //
        let end = mach_absolute_time()
        let elapsed = end - start
        let nanos = elapsed * UInt64(info.numer) / UInt64(info.denom)
        let seconds = TimeInterval(nanos) / TimeInterval(NSEC_PER_SEC)
        let FPS = 1.0 / seconds
        let targetFPS = 1.0 / 0.05
        hudText = hudText + "FPS: " + String(FPS) + " : Target FPS:" + String(targetFPS) + "\n"

        renderHUDBox(text: hudText)
    }
    
    func initialise(height: Double, width: Double, reset: Bool = false) {
        //
        // Set up display data
        //
        HEIGHT = Double(height)
        WIDTH = Double(width)
        MX = WIDTH / 2
        MY = HEIGHT / 2
        HOME_RADIUS = MX / 8
        //
        // Reset completely
        //
        if (reset || o.count == 0) {
            o = []
            f = []
            G.reset()
            STATS.reset()
            orgCount = 0
            for _ in 0...ORGANISMS {
                let newO = Organism()
                newO.create(homeX: MX, homeY: MY, homeR: HOME_RADIUS)
                newO.myID = orgCount
                o.append(newO)
                
                G.addOrganism(id: orgCount, genes:genePool)
                
                orgCount += 1
            }
            if f.count == 0 {
                for _ in 0...FOOD_COUNT {
                    let newF = Food()
                    newF.create(width: WIDTH, height: HEIGHT, homeX: MX, homeY: MY, homeR: HOME_RADIUS)
                    f.append(newF)
                }
            }
            STATS.logDataOrganismCount(count: o.count)
            STATS.logDataFoodCount(count: f.count)
        }
    }
        
    override init() {
        if COLORS.count == 0 {
            COLORS.append(BLACK)
            COLORS.append(WHITE)
            COLORS.append(RED)
            COLORS.append(GREEN)
            COLORS.append(BLUE)
            COLORS.append(YELLOW)
        }
    }
}
