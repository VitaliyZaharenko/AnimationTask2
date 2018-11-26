//
//  CGPoint.swift
//  AnimationTask2
//
//  Created by vitali on 11/25/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
}
