//
//  Genome.swift
//  Life Machine
//
//  Created by Shawn Hamman on 6/01/20.
//  Copyright © 2020 Shawn Hamman. All rights reserved.
//

import Cocoa

class Gene {
    var nucleotides: [Int]
    var size = 12
    var RAND = LMRandomGenerator()
    
    public func getNucleotidesString() -> String {
        var v = ""
        for n in nucleotides {
            v += String(n)
        }
        return v
    }
    
    public func getValue() -> Double {
        var value = 0
        var index = 1
        for i in stride(from: nucleotides.count - 1, through: 0, by: -1) {
            value = value + (nucleotides[i] * index)
            index = index * 4
        }
        return Double(value) / 16777215.0
    }
    
    init(copyFromGene: Gene? = nil) {
        nucleotides = []
        if copyFromGene != nil {
            for n in copyFromGene!.nucleotides {
                var childNucleotide = n
                if (RAND.getRandRand >= 0.85) {
                    childNucleotide = RAND.getRandInt(0,3)
                }
                nucleotides.append(childNucleotide)
            }
        } else {
            for _ in 0...size - 1 {
                nucleotides.append(RAND.getRandInt(0,3))
            }
        }
    }
    
}

class GeneGroup {
    //
    // TODO: Implement:
    //  Trade off between value adjustments
    //  Resistance in links to calculate changes
    //
    var link: [Gene]
    var resistance: [Double]
    var RAND = LMRandomGenerator()
    
    public func getValue() -> Double {
        return (link[0].getValue() + link[1].getValue() + link[2].getValue()) / 3
    }
    
    init(_ g1: Gene, _ g2: Gene, _ g3: Gene) {
        link = []
        link.append(g1)
        link.append(g2)
        link.append(g3)
        resistance = []
        resistance.append(RAND.getRandRand)
        resistance.append(RAND.getRandRand)
        resistance.append(RAND.getRandRand)
    }
}

class Genome {
    var genes: [Gene]
    var genotype: [GeneGroup]
    
    public func printGenome() {
        for (i, g) in genes.enumerated() {
            print("  " + String(i) + " " + g.getNucleotidesString() + " :: " + String(g.getValue()))
        }
    }
    
    public func printGenotype() {
        for (i, g) in genotype.enumerated() {
            print("  " + String(i) + " " + String(g.getValue()))
        }
    }
    
    init(copyFromGenome: Genome? = nil) {
        genes = []
        genotype = []
        if copyFromGenome != nil {
            for g in copyFromGenome!.genes {
                genes.append(Gene(copyFromGene: g))
            }
            
            genotype = []
            for i in 0...27 {
                genotype.append(GeneGroup(genes[i], genes[i + 1], genes[i + 2]))
            }
        } else {
            genes = []
            for _ in 0...30 {
                genes.append(Gene())
            }
            genotype = []
            for i in 0...27 {
                genotype.append(GeneGroup(genes[i], genes[i + 1], genes[i + 2]))
            }
        }
    }
    
}
