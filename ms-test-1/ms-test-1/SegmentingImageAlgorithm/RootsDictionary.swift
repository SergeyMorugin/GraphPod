//
//  RootsDictionary.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//


struct RootElementData {
    let color: BitmapColor
}


struct RootsDictionary{
    var roots: [Int: RootElementData] = [:]
    var resultPixels: [UInt8] = []
    
    
    mutating func createIfNew(index: Int) {
        if let _ = roots[index] {
            return
        } else {
            roots[index] = RootElementData(color: BitmapColor.random())
        }
    }
}
