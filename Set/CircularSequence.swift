//
//  CircularSequence.swift
//  Set
//
//  Created by Heiko Goes on 08.10.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct CircularSequence<T>: IteratorProtocol {
    mutating func append(_ newElement: T) {
        buffer.append(newElement)
        position = 0
    }
    
    var count: Int {
        return buffer.count
    }
    
    mutating func next() -> T? {
        if buffer.isEmpty { return nil }
        
        position += 1
        if position == buffer.count {
            position = 0
        }
        
        return buffer[position]
    }
    
    func current() -> T? {
        return position == -1 ? nil : buffer[position]
    }
    
    func getValue(atIndex: Int) -> T? {
        if atIndex < buffer.count { return buffer[atIndex]}
        
        return nil
    }
    
    mutating func setValue(atIndex: Int, to: T) {
        buffer[atIndex] = to
    }
    
    private var buffer = [T]()
    private (set) var position = -1
}
