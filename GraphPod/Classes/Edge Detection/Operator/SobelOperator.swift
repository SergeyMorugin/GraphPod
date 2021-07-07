//
//  SobelOperator.swift
//  FBSnapshotTestCase
//
//  Created by Ilya Doroshkevitch on 07.07.2021.
//

import Foundation

public struct Sobel {

    public let kernelX = [[-1, 0, 1],
                          [-2, 0, 2],
                          [-1, 0, 1]]

    public let kernelY = [[-1,  -2,  -1],
                          [0,  0,  0],
                          [1, 2, 1]]

}
