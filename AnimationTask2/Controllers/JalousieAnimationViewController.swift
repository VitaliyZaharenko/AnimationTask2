//
//  ViewController.swift
//  AnimationTask2
//
//  Created by vitali on 11/20/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    
    static let rotateDuraion = 3.0
    static let defaultDelay = 0.1
}

class JalousieAnimationViewController: UIViewController {
    
    //MARK: - Views
    
    @IBOutlet weak var animationView: UIView!
    
    
    //MARK: - Properties
    
    private var tapRecognizer: UITapGestureRecognizer!
    
    var image: UIImage?
    var secondImage: UIImage?
    
    var rows: Int = 6
    var columns: Int = 4
    
    private var layers = [CALayer]()
    
    private var frameRects = [CGRect]()
    private var contentRects = [CGRect]()
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        image = UIImage(named: "road")
        secondImage = UIImage(named: "tram")
        //imageView.image = image
        //imageView.contentMode = .scaleToFill
        //imageView.contentMode = .scaleAspectFill
        setupRecognizer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        createFrameAndContentRects()
        layers = createLayers(withImage: image!)
        layers.forEach({ layer in animationView.layer.addSublayer(layer) })
        
    }
    
    //MARK: - Actions
    
    

}

//MARK: - Private Helper Methods

private extension JalousieAnimationViewController {
    
    func setupRecognizer(){
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        animationView.addGestureRecognizer(tapRecognizer)
    }
    
    func randomColor() -> UIColor {
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let g = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let b = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func createRotateAnimation(from: CATransform3D, to: CATransform3D) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.fromValue = from
        animation.toValue = to
        animation.duration = Const.rotateDuraion
        return animation
    }
    
    func indexFrom(row: Int, column: Int) -> Int {
        return row * columns + column
    }
    
    func animateTiles(){
        
        class CompletionAnimationDelegate: NSObject, CAAnimationDelegate {
            
            private let row: Int
            private let column: Int
            private weak var delegate: TileAnimationDelegate?
            
            init(row: Int, column: Int, delegate: TileAnimationDelegate){
                self.row = row
                self.column = column
                self.delegate = delegate
            }
            
            func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
                delegate?.animationCompleted(row: row, column: column)
            }
            
        }
        
        for row in 0..<rows {
            for column in 0..<columns {
                let index = indexFrom(row: row, column: column)
                let toTransform = CATransform3DRotate(layers[index].transform, 3.14 / 2, 1.0, 0, 0)
                let animation: CAAnimation = createRotateAnimation(from: layers[index].transform, to: toTransform)
                animation.beginTime = CACurrentMediaTime() + Double(index) * Const.defaultDelay
                animation.delegate = CompletionAnimationDelegate(row: row, column: column, delegate: self)
                layers[index].add(animation, forKey: "rotateLayer\(index)")
            }
        }
    }
    
    func createFrameAndContentRects()  {
        let rowsCG = CGFloat(rows)
        let columnsCG = CGFloat(columns)
        
        let tileWidth = CGFloat(animationView.bounds.size.width) / columnsCG
        let tileHeight = CGFloat(animationView.bounds.size.height) / rowsCG
        let tileWidthUnit = CGFloat(1.0) / columnsCG
        let tileHeightUnit = CGFloat(1.0) / rowsCG
        
        var frameRects = [CGRect?](repeating: nil, count: rows * columns)
        var contentRects = [CGRect?](repeating: nil, count: rows * columns)
        for row in 0..<rows {
            for column in 0..<columns {
                let index = row * columns + column
                contentRects[index] = CGRect(x: CGFloat(column) * tileWidthUnit,
                                            y: CGFloat(row) * tileHeightUnit,
                                            width: tileWidthUnit,
                                            height: tileHeightUnit)
                frameRects[index] = CGRect(x: CGFloat(column) * tileWidth,
                                     y: CGFloat(row) * tileHeight,
                                     width: tileWidth,
                                     height: tileHeight)
            }
        }
        
        self.frameRects = frameRects.map({$0!})
        self.contentRects = contentRects.map({$0!})
    }
    
    func createLayers(withImage image: UIImage?, transform: CATransform3D = CATransform3DIdentity) -> [CALayer] {
        var layers = [CALayer?](repeating: nil, count: rows * columns)
        for row in 0..<rows {
            for column in 0..<columns {
                let index = indexFrom(row: row, column: column)
                layers[index] = createLayer(withImage: image, transform: transform, row: row, column: column)
            }
        }
        
        return layers.map({$0!})

    }
    
    func createLayer(withImage image: UIImage?, transform: CATransform3D, row: Int, column: Int) -> CALayer {
        let layer = CALayer()
        let index = indexFrom(row: row, column: column)
        layer.contents = image?.cgImage
        layer.transform = transform
        layer.contentsRect = contentRects[index]
        layer.frame = frameRects[index]
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 3
        return layer
    }
}

//MARK: - Callbacks

private extension JalousieAnimationViewController {
    
    @objc func onTap(){
        animateTiles()
    }
    
}

//MARK: - TileAnimationDelegate

extension JalousieAnimationViewController: TileAnimationDelegate {
    func animationCompleted(row: Int, column: Int) {
        
        class CompletionAnimationDelegate: NSObject, CAAnimationDelegate {
            
            private weak var layer: CALayer?
            private var transform: CATransform3D
            
            init(layer: CALayer, resultTransform: CATransform3D){
                self.layer = layer
                self.transform = resultTransform
            }
            
            func animationDidStart(_ anim: CAAnimation) {
                //layer?.transform = transform
            }
            
            func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
                layer?.actions = ["transform": NSNull()]
                layer?.transform = transform
                layer = nil
            }
        }
        
        let index = indexFrom(row: row, column: column)
        layers[index].removeFromSuperlayer()
        
        
        let resultTransform = CATransform3DIdentity
        let transform = CATransform3DRotate(resultTransform, -(3.14 / 2), 1, 0, 0)
        let newLayer = createLayer(withImage: secondImage, transform: transform, row: row, column: column)
        layers[index] = newLayer
        animationView.layer.addSublayer(newLayer)
        let animation = createRotateAnimation(from: transform, to: resultTransform)
        animation.delegate = CompletionAnimationDelegate(layer: newLayer, resultTransform: resultTransform)
        newLayer.add(animation, forKey: "completeRotation\(index)")
    }
}



