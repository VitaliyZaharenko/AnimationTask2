//
//  ViewController.swift
//  AnimationTask2
//
//  Created by vitali on 11/20/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    
    static let animationDuration = 2.0
    static let paperBirdFrame = CGRect(x: -200, y: -200, width: 40, height: 40)
}

class TrashCanViewController: UIViewController {
    
    //MARK: - Views
    
    @IBOutlet weak var trashCanImageView: UIImageView!
    @IBOutlet weak var moveToTrashButton: UIButton!
    
    private var throwableObjectImageView: UIImageView!
    
    //MARK: - Constraints
    
    @IBOutlet weak var trashCanLeftConstraint: NSLayoutConstraint!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureThrowableObjectImageView()
        configureTrashCan()
    }
    
    //MARK: - Actions
    
    @IBAction func moveToTrash(_ sender: UIButton) {
        let animation = createAnimation()
        throwableObjectImageView.layer.add(animation, forKey: "moveToTrash")
    }
    

}

//MARK: - Private Helper methods

private extension TrashCanViewController {
    
    func configureThrowableObjectImageView() {
        throwableObjectImageView = UIImageView(frame: Const.paperBirdFrame)
        throwableObjectImageView.image = UIImage(named: Consts.Images.paperBird)
        view.addSubview(throwableObjectImageView)
    }
    
    func configureTrashCan() {
        let constUpperLimit = self.view.bounds.size.width - self.trashCanImageView.bounds.size.width
        let randomConstant = CGFloat(arc4random_uniform(UInt32(constUpperLimit)))
        trashCanLeftConstraint.constant = randomConstant
    }
    
    func createAnimation() -> CAKeyframeAnimation {
        let path = UIBezierPath()
        path.move(to: moveToTrashButton.center)
        let cp1 = view.bounds.randomPointInside()
        let cp2 = view.bounds.randomPointInside()
        path.addCurve(to: trashCanImageView.center, controlPoint1: cp1, controlPoint2: cp2)
        
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.path = path.cgPath
        animation.duration = Const.animationDuration
        animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)]
        
        return animation
        
    }
}

