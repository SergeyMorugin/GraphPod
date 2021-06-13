//
//  File.swift
//  
//
//  Created by Зинде Иван on 6/13/21.
//

import Foundation

protocol Edge {
    
    var vertex : Vertex {get set}
    var destination : Vertex {get set}

    var weight : Int {get set}
    
    var directed : Bool {get set}
}
