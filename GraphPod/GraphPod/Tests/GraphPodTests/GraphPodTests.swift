import XCTest
@testable import GraphPod

final class GraphPodTests: XCTestCase {
    
//    class ExampleVertex : Vertex {
//        var body: Int
//        
//        init(body : Int) {
//            self.body = body
//        }
//    }
//    
//    class ExampleEdge : Edge {
//        
//        var vertex: Vertex
//        
//        var destination: Vertex
//        
//        var weight: Int
//        
//        var directed: Bool
//        
//        init (vertex : Vertex, destination: Vertex, weight : Int, directed: Bool ){
//            self.vertex = vertex
//            self.destination = destination
//            self.weight = weight
//            self.directed = directed
//        }
//        
//        
//    }
//    
//    class ExampleGraph : Graph {
//        var edges: [Edge] = []
//        
//        init(edges: [Edge]) {
//            for edge in edges {
//                self.edges.append(edge)
//            }
//        }
//    }
//    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GraphPod().text, "Hello, World!")
        

//        let vert1_1 : ExampleVertex = ExampleVertex.init(body: 10)
//        let dest1_2 : ExampleVertex = ExampleVertex.init(body: 20)
//        let vert2_1 : ExampleVertex = ExampleVertex.init(body: 30)
//        let dest2_2 : ExampleVertex = ExampleVertex.init(body: 40)
//        let edge1 : ExampleEdge = ExampleEdge.init(vertex: vert1_1,
//                                                   destination: dest1_2,
//                                                   weight: 10,
//                                                   directed: false)
//        let edge2 : ExampleEdge = ExampleEdge.init(vertex: vert2_1,
//                                                   destination: dest2_2,
//                                                   weight: 15,
//                                                   directed: false)
//        let graph : ExampleGraph = ExampleGraph.init(edges: [edge1, edge2])
//        
//        XCTAssertEqual(graph.edges[0].weight, 10)
//        XCTAssertEqual(graph.edges[1].weight, 15)
//        XCTAssertEqual(graph.edges[0].vertex.body, 10)
//        XCTAssertEqual(graph.edges[0].destination.body, 20)
//        XCTAssertEqual(graph.edges[1].vertex.body, 30)
//        XCTAssertEqual(graph.edges[1].destination.body, 40)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
