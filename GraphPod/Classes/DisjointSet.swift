//
//  DisjointSet.swift
//  ms-test-1
//
//  Created by Matthew on 18.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

//import UIKit


public struct DisjointSetElement {
    public var rank: Int
    public var parent: Int
    public var size: Int
}

public final class DisjointSet {
    public var elements:[DisjointSetElement] = []
    
    public init(count: Int) {
        elements = [DisjointSetElement](repeating: DisjointSetElement(rank: 0, parent: 0, size: 1), count: count)
        for i in 0..<count {
            elements[i].rank = 0
            elements[i].size = 1
            elements[i].parent = i
        }
    }
    
    // MARK:  Find element
    public func rootForElementOn(index: Int) -> Int {
        var y = index
        while y != elements[y].parent {
            y = elements[y].parent
            elements[index].parent = y
        }
        return y
    }
    
    // MARK: Join elements
    public func joinSetsBy(index1: Int, index2: Int) {
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
    
    public subscript(index: Int) -> DisjointSetElement {
        get {
            return elements[index]
        }
        set(newValue) {
            elements[index] = newValue
        }
    }
}

public extension DisjointSet {
    func colorizeBitmap(withWidth width: Int, andHeight height: Int) -> (BitmapImage, RootsDictionary) {
        var rootsDictionary = RootsDictionary()
        var resultPixels: [UInt8] = []
        for i in 0..<elements.count {
            let rootIndex =  rootForElementOn(index: i)
            
            rootsDictionary.createIfNew(index: rootIndex)
            let root = rootsDictionary.roots[rootIndex]!
            resultPixels.append(root.color.r)
            resultPixels.append(root.color.g)
            resultPixels.append(root.color.b)
            resultPixels.append(root.color.a)
        }
        return (BitmapImage(width: width, height: height, pixels: resultPixels), rootsDictionary)
    }
}

