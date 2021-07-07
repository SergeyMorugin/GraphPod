//
//  RootsDictionary.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

public struct RootElementData {
    public let color: BitmapColor
}

public struct RootsDictionary{
    public var roots: [Int: RootElementData] = [:]

    public mutating func createIfNew(index: Int) {
        if let _ = roots[index] {
            return
        } else {
            roots[index] = RootElementData(color: BitmapColor.random())
        }
    }
}
