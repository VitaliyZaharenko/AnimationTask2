//
//  Planet.swift
//  AnimationTask2
//
//  Created by vitali on 11/22/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

class Planet {
    
    let radius: Double
    let orbitRadius: Double?
    weak var parentPlanet: Planet?
    
    private var subplanets = [Planet]()
    
    init?(radius: Double, orbitRadius: Double? = nil, parent: Planet? = nil, subplanets: [Planet]? = nil){
        
        
        if radius <= 0 {
            return nil
        }
        if let orbitRadius = orbitRadius {
            if orbitRadius <= 0 {
                return nil
            }
        }
        self.radius = radius
        self.orbitRadius = orbitRadius
        
        if let parent = parent {
            if parent == self || parent.addSubplanet(planet: self) == false {
                return nil
            }
            
        }
        self.parentPlanet = parent
        
        if let subplanets = subplanets {
            for subplanet in subplanets {
                if subplanet == self {
                    return nil
                } else {
                    subplanet.parentPlanet = self
                    self.subplanets.append(subplanet)
                }
            }
        }
    }
    
    @discardableResult
    func addSubplanet(planet: Planet) -> Bool {
        if planet == self || subplanets.reduce(false, { res, subplanet in res || subplanet == planet}){
            return false
        }
        
        if let parent = self.parentPlanet {
            if parent == planet {
                return false
            }
        }
        
        if let _ = self.subplanets.index(of: planet){
            return false
        }
        subplanets.append(planet)
        return true
    }
    
    @discardableResult
    func removeSubplanet(planet: Planet) -> Bool{
        if let index = subplanets.index(of: planet){
            planet.parentPlanet = nil
            subplanets.remove(at: index)
            return true
        }
        return false
    }
}

//MARK: - Equatable

extension Planet: Equatable {
    
    static func ==(lhs: Planet, rhs: Planet) -> Bool {
        
        var equal = false
        if lhs.orbitRadius != nil && rhs.orbitRadius != nil {
            equal = (lhs.orbitRadius!.isEqual(to: rhs.orbitRadius!))
        } else {
            if (lhs.orbitRadius == nil && rhs.orbitRadius != nil) || (lhs.orbitRadius != nil && rhs.orbitRadius == nil){
                equal = false
            }
        }        
        return equal
            && lhs.radius.isEqual(to: rhs.radius)
            && lhs.parentPlanet == rhs.parentPlanet
            && lhs.subplanets.elementsEqual(rhs.subplanets)
    }
}
