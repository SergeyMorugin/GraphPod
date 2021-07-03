//
//  SegmentingImageAlgorithmPerformanceTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 30.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import GraphPod

class SegmentingImageAlgorithmPerformanceTests: XCTestCase {
    
    // test performance for 100x100px image
    func testPerformanceImage1() throws {
        let image =  UIImage(named: "test1")
        let bitmap = image!.toBitmapImage()!
        self.measure {
            let _ = SegmentingImageAlgorithm.execute(image: bitmap, threshold: 10, minSize: 10)
        }
    }
    
    // test performance for 1000x1000px image
    func testPerformanceImage2() throws {
        let image =  UIImage(named: "test2")
        let bitmap = image!.toBitmapImage()!
        self.measure {
            let _ = SegmentingImageAlgorithm.execute(image: bitmap, threshold: 10, minSize: 10)
        }
    }

}
