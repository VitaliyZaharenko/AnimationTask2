//
//  TileAnimationDelegate.swift
//  AnimationTask2
//
//  Created by vitali on 11/29/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

protocol TileAnimationDelegate: class {
    
    func animationCompleted(row: Int, column: Int)
}
