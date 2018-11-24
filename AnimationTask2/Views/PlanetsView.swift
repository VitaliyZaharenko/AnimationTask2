//
//  PlanetsView.swift
//  AnimationTask2
//
//  Created by vitali on 11/21/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit


fileprivate struct Const {
    static let defaultRotationSpeed = 1.0
}

class PlanetsView: UIView {

    //MARK: - Properties
    
    private var angle = 0
    
    //MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit(){
        
        backgroundColor = UIColor.black
        
        
        guard let planet1 = Planet(radius: 15, orbitRadius: nil, parent: nil, subplanets: nil) else {
            fatalError("Planet is nil")
        }
        guard let subplanet = Planet(radius: 7, orbitRadius: 50, parent: planet1, subplanets: nil) else {
            fatalError("SubPlanet is nil")
        }
        guard let subsubplanet = Planet(radius: 3, orbitRadius: 25, parent: subplanet, subplanets: nil) else {
            fatalError("SubPlanet is nil")
        }
        
        
        let minDimension =
            (self.layer.bounds.size.width < self.layer.bounds.size.height)
                ? (self.layer.bounds.size.width)
                : (self.layer.bounds.size.height)

        let parentLayer = addPlanet(planet: planet1, parentLayer: self.layer)
        let subplanetLayer = addPlanet(planet: subplanet, parentLayer: parentLayer)
        addPlanet(planet: subsubplanet, parentLayer: subplanetLayer)
        
        rotate(layer: subplanetLayer)
        
    }

}


//MARK: - Private Helper methods

fileprivate extension PlanetsView {
    func addPlanet(planet: Planet, parentLayer: CALayer) -> CALayer {
        
        let translate = planet.orbitRadius ?? 0
        
        let (centerX, centerY) = (parentLayer.position.x, parentLayer.position.y)
        let planetLayer = CAShapeLayer()
        planetLayer.position = parentLayer.position
        planetLayer.bounds = parentLayer.bounds
        let color = generateColor()
        planetLayer.fillColor = color
        let size = CGFloat(planet.radius * 2)
        let halfSize = CGFloat(planet.radius)
        let planetRect = CGRect(x: centerX - halfSize,
                                y: centerY - halfSize,
                                width: size,
                                height: size)
        planetLayer.path = UIBezierPath(rect: planetRect).cgPath
        planetLayer.transform = CATransform3DTranslate(parentLayer.transform, 0, CGFloat(translate), 0)
        parentLayer.addSublayer(planetLayer)
        
        guard let parent = planet.parentPlanet, let orbitRadius = planet.orbitRadius else {
            return planetLayer
        }
        
        let orbitLayer = CAShapeLayer()
        
        orbitLayer.position = parentLayer.position
        orbitLayer.bounds = parentLayer.bounds
        orbitLayer.strokeColor = color
        orbitLayer.fillColor = UIColor.clear.cgColor
        orbitLayer.lineWidth = 3
        orbitLayer.transform = parentLayer.transform
        let orbitSize = CGFloat(orbitRadius * 2)
        let orbitHalfSize = CGFloat(orbitRadius)
        let orbitRect = CGRect(x: centerX - orbitHalfSize,
                                y: centerY - orbitHalfSize,
                                width: orbitSize,
                                height: orbitSize)
        orbitLayer.path = UIBezierPath(ovalIn: orbitRect).cgPath
        parentLayer.addSublayer(orbitLayer)
        
        return planetLayer
    }
    
    func generateColor() -> CGColor {
        let colors = [UIColor.red, UIColor.blue, UIColor.purple, UIColor.orange, UIColor.green,
                      UIColor.cyan, UIColor.magenta]
        
        return colors[Int(arc4random_uniform(UInt32(colors.count)))].cgColor
    }
    
    
    
    func rotate(layer: CALayer) {
        var timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true, block: { timer in
            let translation = CATransform3DTranslate(layer.transform, 0, -CGFloat(25), 0)
            let rotate = CATransform3DRotate(translation, CGFloat(10.0.rad), 0, 0, 1)
            let resultTransform = CATransform3DTranslate(rotate, 0, CGFloat(25), 0)
            layer.transform = resultTransform
        })
        
    }
}
