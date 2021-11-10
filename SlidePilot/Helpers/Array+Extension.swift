//
//  Array+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

extension Array {
    /**
     Moves an element to the end of the array and shifts all elements one position to the front.
     
     - parameter
        - index: The index of the element, that should be moved to the end.
     
     */
    mutating func moveToEnd(from index: Int) {
        self.insert(self.remove(at: index), at: self.count)
    }
    
    
    /**
     Moves an element to the beginning of the array and shifts all elements one position to the back.
     
     - parameter
        - index: The index of the element, that should be moved to the end.
     
     */
    mutating func moveToFront(from index: Int) {
        self.insert(self.remove(at: index), at: 0)
    }
}
