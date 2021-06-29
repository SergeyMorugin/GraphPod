//
//  DisjointSet.swift
//  ms-test-1
//
//  Created by Matthew on 18.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import UIKit


struct DisjointSetElement {
    var rank: Int
    var parent: Int
    var size: Int
}

final class DisjointSet {
    var elements:[DisjointSetElement] = []
    
    // MARK:  Find element
    func rootForElementOn(index: Int) -> Int {
        var y = index
        while y != elements[y].parent {
            y = elements[y].parent
            elements[index].parent = y
        }
        return y
    }

    // MARK: Join elements
     func joinSetsBy(index1: Int, index2: Int) {
        if elements[index1].rank > elements[index2].rank {
            elements[index2].parent = index1
            elements[index1].size += elements[index2].size
        } else {
            elements[index1].parent = index2
            elements[index2].size += elements[index1].size
            if elements[index1].rank == elements[index2].rank {
                elements[index2].rank += 1
            }
        }
     }
    
    subscript(index: Int) -> DisjointSetElement {
        get {
            return elements[index]
        }
        set(newValue) {
            elements[index] = newValue
        }
    }
}


struct RootElementData {
    let color: BitmapColor
}


struct RootsDictionary{
    var roots:[Int: RootElementData] = [:]
    
    mutating func createIfNew(index: Int) {
        if let _ = roots[index] {
            return
        } else {
            roots[index] = RootElementData(color: BitmapColor.random())
        }
        
    }
}
