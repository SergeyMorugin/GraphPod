//
//  ms_test_1Tests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import ms_test_1

class ms_test_1Tests: XCTestCase {

  /*  let image = UIImage(named: "imageForXCT")
    var algorithm: SegmentingImageAlgorithm?
    var disjointset: DisjointSet?

    // MARK: - SetUp
    override func setUpWithError() throws {
        algorithm = SegmentingImageAlgorithm()
        disjointset = DisjointSet()
    }

    // MARK: - TearDown
    override func tearDownWithError() throws {
        algorithm = nil
        disjointset = nil
    }

    // MARK: - ImageToBitmap func test
    func testImageToBitmap() throws {
        let bitmap = image?.toBitmapImage()

        XCTAssert(bitmap as Any is BitmapImage)
        XCTAssertEqual(bitmap?.pixels.count, 6400, "ImageToBitmap func not ok")
    }

    // MARK: - SegmentImage func test
    func testSegmentImage() throws {
        let bitmap = image?.toBitmapImage()

        let result = SegmentingImageAlgorithm().segmentImage(bitmap!, threshold: 10, minSize: 300)

        XCTAssertEqual(result?.0.pixels.count, 6400, "SegmentImage func not ok")
        XCTAssertEqual(result!.1.roots.values.count, 1, "SegmentImage func not ok")
        XCTAssertEqual(result?.2.elements.count, 1600, "SegmentImage func not ok")
    }

    // MARK: - Diff func test
    func testDiff() throws {
        let bitmap = image?.toBitmapImage()

        let x = 20, y = 20

        let diff = algorithm?.diff(image: bitmap!, x1: x, y1: y, x2: x + 1, y2: y)
        XCTAssertEqual(diff, 39.115215, "ok")
    }

    // MARK: - RootForElement func test
    func testRootForElementOn() throws {
        let pixelCount = Int(image!.size.height * image!.size.width)
        let bitmap = image?.toBitmapImage()
        let height = Int(image!.size.height)
        let width = Int(image!.size.width)
        var edges:[Edge] = []

        _ = (0..<height).map { y in
            (0..<width).map { x in
                if (x < width - 1) {
                    let a = y * width + x
                    let b = y * width + (x + 1)
                    let weight = algorithm?.diff(image: bitmap!, x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight!)
                    edges.append(edge)
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = algorithm?.diff(image: bitmap!, x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight!)
                    edges.append(edge)
                }
            }
         }

        disjointset!.elements = [DisjointSetElement](repeating: DisjointSetElement(rank: 0, parent: 0, size: 1), count: pixelCount)
        for i in 0..<pixelCount {
            disjointset![i].rank = 0
            disjointset![i].size = 1
            disjointset![i].parent = i
        }

        let a = disjointset?.rootForElementOn(index: edges[1500].a)
        let b = disjointset?.rootForElementOn(index: edges[1500].b)

        XCTAssertEqual(a, 759, "RootForElementOn func not ok")
        XCTAssertEqual(b, 799, "RootForElementOn func not ok")
    }

    // MARK: - JoinSets func test
    func testJoinSetsBy() throws {
        let pixelCount = Int(image!.size.height * image!.size.width)
        let bitmap = image?.toBitmapImage()
        let height = Int(image!.size.height)
        let width = Int(image!.size.width)
        var edges:[Edge] = []
        var numEdges = 0

        _ = (0..<height).map { y in
            (0..<width).map { x in
                if (x < width - 1) {
                    let a = y * width + x
                    let b = y * width + (x + 1)
                    let weight = algorithm?.diff(image: bitmap!, x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight!)
                    edges.append(edge)
                    numEdges+=1
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = algorithm?.diff(image: bitmap!, x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight!)
                    edges.append(edge)
                    numEdges+=1
                }
            }
         }

        let sortedEdges = edges.sorted { $0.weight < $1.weight  }

        disjointset!.elements = [DisjointSetElement](repeating: DisjointSetElement(rank: 0, parent: 0, size: 1), count: pixelCount)
        for i in 0..<pixelCount {
            disjointset![i].rank = 0
            disjointset![i].size = 1
            disjointset![i].parent = i
        }


        let pedge = sortedEdges[100]  // get rebro

        var a = disjointset!.rootForElementOn(index: pedge.a)
        var b = disjointset!.rootForElementOn(index: pedge.b)

        disjointset!.joinSetsBy(index1: a, index2: b)
        a = disjointset!.rootForElementOn(index: a) //386
        b = disjointset!.rootForElementOn(index: b) // 386

        XCTAssertEqual(a, 90, "joinSetsBy func not ok")
        XCTAssertEqual(b, 90, "joinSetsBy func not ok")
    }

    // MARK: - Edge Detection tests



    // MARK: - PixelValuesFromGrayScaleImage func test
    func testPixelValuesFromGrayScaleImage() throws {
        let pixels = EdgeDetectionAlgorithm.pixelValuesFromGrayScaleImage(imageRef: image?.cgImage)

        XCTAssertEqual(pixels!.count, 1600, "pixelValuesFromGrayScaleImage func not ok")
        XCTAssertEqual(pixels![800], 255, "pixelValuesFromGrayScaleImage func not ok")
    }

    // MARK: - Edge Detection Operate func test
    func testOperate() throws {
        let pixels = EdgeDetectionAlgorithm.pixelValuesFromGrayScaleImage(imageRef: image?.cgImage)

        let operateResult = EdgeDetectionAlgorithm.operate(pixelValues: pixels!, height: Int(image!.size.height), width: Int(image!.size.width))

        XCTAssertEqual(operateResult.count, 1444, "Operate func not ok")
        XCTAssertEqual(operateResult[700], 26, "Operate func not ok")
    }



    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/

}
