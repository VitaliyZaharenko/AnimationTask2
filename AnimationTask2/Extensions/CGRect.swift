//
//  CGRect.swift
//  AnimationTask2
//
//  Created by vitali on 11/26/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

extension CGRect {
    
    func randomPointInside(vertPadding: CGFloat = 0, horizPadding: CGFloat = 0) -> CGPoint {
        let x = Int(arc4random_uniform(UInt32(self.size.width - horizPadding * 2))) + Int(horizPadding)
        let y = Int(arc4random_uniform(UInt32(self.size.height - vertPadding * 2))) + Int(vertPadding)
        
        return CGPoint(x: x, y: y)
    }
    
}
