//
//  CAKeyframeAnimation+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 04.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension CAKeyframeAnimation {
    
    public static func animation(with keyPath: String, from fromValue: Double, to toValue: Double, timingFuntion: (Double) -> (Double)) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        
        // Break the time into steps
        let steps = 100
        var time = 0.0
        let timeStep = 1.0 / Double(steps - 1)
        var values = [Double]()
        
        for _ in 0...steps {
            let value = fromValue + (timingFuntion(time) * (toValue - fromValue))
            values.append(value)
            time += timeStep
        }
        
        // Set values to
        animation.calculationMode = .linear
        animation.values = values
        return animation
    }
    
    
    static let elasticOutTimingFuction: (Double) -> (Double) = { (time: Double) in
        if time <= 0.0 {
            return 0.0
        } else if time >= 1.0 {
            return 1.0
        }
        
        let period = 0.5
        let amplitude = 1.0
        let shift = period * 0.25
        
        let result = amplitude * pow(2, -10 * time) * sin((time - shift) * 2 * Double.pi / period) + 1
        
        return result
    }
}

