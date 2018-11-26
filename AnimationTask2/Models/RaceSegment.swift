//
//  RaceSegment.swift
//  AnimationTask2
//
//  Created by vitali on 11/24/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

enum RaceSegment {
    
    case line(from: CGPoint, to: CGPoint)
    case qubicCurve(controlPoint1: CGPoint, controlPoint2: CGPoint, end: CGPoint)
}
