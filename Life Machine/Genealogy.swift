//
//  Genealogy.swift
//  Life Machine
//
//  Created by Shawn Hamman on 5/01/20.
//  Copyright © 2020 Shawn Hamman. All rights reserved.
//

import Cocoa

class Node {
    var id: Int
    var genes: [Double]
    var children: [Node] = []
    weak var parent: Node?

    func search(value: Int) -> Node? {
        if value == self.id {
            return self
        }

        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        return nil
    }
    
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
    
    init(id: Int, genes: [Double]) {
        self.id = id
        self.genes = genes
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        var text = "\(id)"

        if !children.isEmpty {
            text += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return text
    }
}

class Genealogy: NSObject {
    var PANEL_WIDTH = 300.0
    var PANEL_HEIGHT = 145.0
    var MAX_LINE_HEIGHT = 110
    var WIDTH = 0.0
    var HEIGHT = 0.0
    
    var RED = [255, 0, 0, 255]
    var GREEN = [0, 255, 0, 255]
    var YELLOW = [255, 255, 0, 255]
    
    var x1 = 0.0
    var y1 = 0.0
    var x2 = 0.0
    var y2 = 0.0
    
    var ancestors: [Node] = []
    var treeRepString = ""
    
    public func addOrganism(id: Int, genes: [Double], parent: Int = -1) {
        let n = Node(id: id, genes: genes)
        if parent == -1 {
            ancestors.append(n)
        } else {
            for a in ancestors {
                let p = a.search(value: parent)
                if (p != nil) {
                    p?.add(child: n)
                }
            }
        }
    }
    
    public func reset() {
        ancestors = []
    }
    
    public func print() {
        for a in ancestors {
            Swift.print(a)
        }
    }
    
    func printChildren(node: Node, l: Int) {
        let level = l + 1
        var space = ""
        for _ in 0...level {
            space = space + "  "
        }
        for c in node.children {
            treeRepString = treeRepString + space + String(c.id) + "\n"
            if !c.children.isEmpty {
                printChildren(node: c, l: level)
            }
        }
    }
    
    public func generateTreeStringRep() -> String {
        treeRepString = ""
        for a in ancestors {
            treeRepString = treeRepString + String(a.id) + "\n"
            if !a.children.isEmpty {
                printChildren(node: a, l: 0)
            }
        }
        return treeRepString
    }
    
    public func render(worldWidth: Double, worldHeight: Double, panelWidth: Double, panelHeight: Double, bitmap: inout NSBitmapImageRep) {
        
        WIDTH = worldWidth
        HEIGHT = worldHeight
        PANEL_WIDTH = panelWidth
        PANEL_HEIGHT = worldHeight - panelHeight - 5
        x1 = worldWidth - panelWidth
        y1 = panelHeight + 5
        x2 = worldWidth
        y2 = worldHeight - panelHeight
        
        let barRect = CGRect(x: x1, y: y1, width: PANEL_WIDTH, height: PANEL_HEIGHT)

        NSColor.darkGray.set()
        __NSRectFill(barRect)
        
        let font = NSFont(name: "Courier", size: 9)
        let textRect = CGRect(x: x1, y: y1, width: PANEL_WIDTH, height: PANEL_HEIGHT)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.white,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        let text = generateTreeStringRep()
        text.draw(in: textRect, withAttributes: textFontAttributes as [NSAttributedString.Key : Any])
    }
    
}
