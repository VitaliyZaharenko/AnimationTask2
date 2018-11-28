//
//  ViewController.swift
//  AnimationTask2
//
//  Created by vitali on 11/20/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    
    static let speed = 3.0
    
    static let startAnimationTitle = "Start Animation"
    static let stopAnimationTitle = "Stop Animation"
    
    static let onscreenAnimationKey = "onscreenAnimation"
    static let offscreenAnimationKey = "offscreenAnimation"
}

enum Direction {
    case left
    case right
}

class CreepingLineViewController: UIViewController {
    
    //MARK: - Views
    
    @IBOutlet weak var creepingLineLabel: UILabel!
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var toggleAnimationButton: UIButton!
    
    //MARK: - Properties
    
    var moveDirection: Direction = .right
    
    private var isPlaying = false {
        didSet {
            updateButton()
        }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton()
        moveDirection = direction(from: directionSegmentedControl)
    }
    
    //MARK: - Actions
    
    
    @IBAction func directionChanged(_ sender: UISegmentedControl) {
        moveDirection = direction(from: directionSegmentedControl)
    }
    
    @IBAction func toggleAnimation(_ sender: UIButton) {
        
        if !isPlaying {
            let animation = createOffscreenAnimation(label: creepingLineLabel)
            if let animation = animation {
                isPlaying = true
                animation.isRemovedOnCompletion = false
                creepingLineLabel.layer.add(animation, forKey: Const.offscreenAnimationKey)
            }
        } else {
            isPlaying = false
        }
    }
}

//MARK: - Private Helper Methods

private extension CreepingLineViewController {
    
    func direction(from segmentedControl: UISegmentedControl) -> Direction {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return .left
        case 1:
            return .right
        default:
            fatalError("Wrong number of items in segmented control")
        }
    }
    
    func createOnscreenAnimation(label: UILabel) -> CABasicAnimation? {
        let onscreenAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        guard let superviewWidth = label.superview?.frame.size.width else {
            return nil
        }
        
        let translateX: CGFloat = {
            switch moveDirection {
            case .right:
                return -(label.frame.origin.x + label.frame.size.width)
            case .left:
                return superviewWidth - label.frame.origin.x
            }
        }()
        
        onscreenAnimation.fromValue = CATransform3DTranslate(label.layer.transform,
                                                             translateX,
                                                             0,
                                                             0)
        onscreenAnimation.toValue = label.layer.transform
        onscreenAnimation.duration = Const.speed
        onscreenAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        onscreenAnimation.delegate = self
        
        return onscreenAnimation
    }
    
    func createOffscreenAnimation(label: UILabel) -> CABasicAnimation? {
        
        let offscreenAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        guard let superviewWidth = label.superview?.frame.size.width else {
            return nil
        }
        
        let translateX: CGFloat = {
            switch moveDirection {
            case .left:
                return -(label.frame.origin.x + label.frame.size.width)
            case .right:
                return superviewWidth - label.frame.origin.x
            }
        }()
        
        offscreenAnimation.toValue = CATransform3DTranslate(label.layer.transform,
                                                   translateX,
                                                   0,
                                                   0)
        offscreenAnimation.duration = Const.speed
        offscreenAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        offscreenAnimation.delegate = self
        
        return offscreenAnimation
    }
    
    func updateButton(){
        let title = isPlaying ? Const.stopAnimationTitle : Const.startAnimationTitle
        toggleAnimationButton.setTitle(title, for: .normal)
    }
}

//MARK: - CAAnimationDelegate

extension CreepingLineViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let layer = creepingLineLabel.layer
        if let offscreenAnimation = layer.animation(forKey: Const.offscreenAnimationKey) {
            if anim == offscreenAnimation {
                offScreenStopped(anim, finished: flag)
                return
            }
        }
        if let onscreenAnimation = layer.animation(forKey: Const.onscreenAnimationKey) {
            
            if anim == onscreenAnimation {
                onScreenStopped(anim, finished: flag)
                return
            }
        }
    }
    
    private func onScreenStopped(_ anim: CAAnimation, finished flag: Bool){
        if !isPlaying {
            return
        }
        let animation = createOffscreenAnimation(label: creepingLineLabel)
        if let animation = animation {
            animation.isRemovedOnCompletion = false
            creepingLineLabel.layer.add(animation, forKey: Const.offscreenAnimationKey)
        }
        
    }
    
    private func offScreenStopped(_ anim: CAAnimation, finished flag: Bool){
        if let animation = createOnscreenAnimation(label: creepingLineLabel), flag {
            animation.isRemovedOnCompletion = false
            creepingLineLabel.layer.add(animation, forKey: Const.onscreenAnimationKey)
        }
    }
}

