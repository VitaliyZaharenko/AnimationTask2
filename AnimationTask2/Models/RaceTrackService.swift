//
//  RaceTrackService.swift
//  AnimationTask2
//
//  Created by vitali on 11/26/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    
    static let defaultHitTestDistance: Double = 50
}


enum RaceTrackServiceError: Error {
    case wrongSegmentIndex(String)
    case wrongSubindex(String)
}

class RaceTrackService {
    
    var track: RaceTrack
    
    init(track: RaceTrack){
        self.track = track
    }
    
    
    func hitTest(point: CGPoint) -> (Int, Int)? {
        var selectedIndexSubindexTuple: (Int, Int)? = nil
        var minDistance: Double = Double.greatestFiniteMagnitude
        for index in 0..<track.segments.count {
            switch track.segments[index]{
            case .line(from: let from, to: let to):
                let fromDistance = from.distance(to: point)
                let toDistance = to.distance(to: point)
                let (min, subindex): (CGFloat, Int) = [(fromDistance, 0), (toDistance, 1)].reduce((fromDistance, 0), { res, currTuple in
                    if res.0 < currTuple.0 {
                        return res
                    } else {
                        return currTuple
                    }
                })
                if Double(min) < Const.defaultHitTestDistance && Double(min) < minDistance {
                    selectedIndexSubindexTuple = (index, subindex)
                    minDistance = Double(min)
                }
            case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
                let cp1Distance = cp1.distance(to: point)
                let cp2Distance = cp2.distance(to: point)
                let endDistance = end.distance(to: point)
                let (min, subindex): (CGFloat, Int) = [(cp1Distance, 0), (cp2Distance, 1), (endDistance, 2)].reduce((cp1Distance, 0), { res, currDistance in
                    if res.0 < currDistance.0 {
                        return res
                    } else {
                        return currDistance
                    }
                })
                if Double(min) < Const.defaultHitTestDistance && Double(min) < minDistance {
                    selectedIndexSubindexTuple = (index, subindex)
                    minDistance = Double(min)
                }
            }
        }
        return selectedIndexSubindexTuple
    }
    
    func changePoint(locationTuple: (Int, Int), to point: CGPoint) throws -> RaceTrack {
        let (index, subindex) = locationTuple
        if (index < 0 || index >= track.segments.count){
            throw RaceTrackServiceError.wrongSegmentIndex("Index = \(index), Subindex = \(subindex)")
        }
        var newTrack = track
        switch track.segments[index]{
        case .line(from: let from, to: let to):
            switch subindex {
            case 0:
                newTrack.segments[index] = .line(from: point, to: to)
            case 1:
                newTrack.segments[index] = .line(from: from, to: point)
            default:
                throw RaceTrackServiceError.wrongSubindex("Index = \(index), Subindex = \(subindex)")
            }
            return newTrack
        case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
            switch subindex {
            case 0:
                newTrack.segments[index] = .qubicCurve(controlPoint1: point, controlPoint2: cp2, end: end)
            case 1:
                newTrack.segments[index] = .qubicCurve(controlPoint1: cp1, controlPoint2: point, end: end)
            case 2:
                newTrack.segments[index] = .qubicCurve(controlPoint1: cp1, controlPoint2: cp2, end: point)
            default:
                throw RaceTrackServiceError.wrongSubindex("Index = \(index), Subindex = \(subindex)")
            }
            return newTrack
        }
    }
    
    func addLineSegment(point: CGPoint) -> RaceTrack {
        
        if let lastPoint = lastPoint() {
            track.segments.append(.line(from: lastPoint, to: point))
        } else {
            track.segments.append(.line(from: point, to: point))
        }
        return track
    }
    
    func addCurveSegment(point: CGPoint) -> RaceTrack {
        if let lastPoint = lastPoint() {
            let controlPoint1 = pointOnLine(start: lastPoint, end: point, parameter: CGFloat(0.33))
            let controlPoint2 = pointOnLine(start: lastPoint, end: point, parameter: CGFloat(0.66))
            track.segments.append(.qubicCurve(controlPoint1: controlPoint1, controlPoint2: controlPoint2, end: point))
        } else {
            track.segments.append(.qubicCurve(controlPoint1: point, controlPoint2: point, end: point))
        }
        return track
    }
    
    func firstPoint() -> CGPoint? {
        if track.segments.isEmpty {
            return nil
        } else {
            switch track.segments.first! {
            case .line(from: let from, to: _):
                return from
            case .qubicCurve(controlPoint1: _, controlPoint2: _, end: let end):
                return nil
            }
        }
    }
    
    func lastPoint() -> CGPoint? {
        if track.segments.isEmpty {
            return nil
        } else {
            switch track.segments.last! {
            case .line(from: _, to: let to):
                return to
            case .qubicCurve(controlPoint1: _, controlPoint2: _, end: let end):
                return end
            }
        }
    }
    
}

//MARK: - Private Helper Methods
private extension RaceTrackService {
    
    func pointOnLine(start: CGPoint, end: CGPoint, parameter t: CGFloat) -> CGPoint {
        if t < 0 || t > 1 {
            fatalError("Parameter not in [0, 1] interval")
        }
        let (x1, y1): (CGFloat, CGFloat) = (start.x, start.y)
        let (x2, y2): (CGFloat, CGFloat) = (end.x, end.y)
        let resX = t * x1 + (1 - t) * x2
        let resY = t * y1 + (1 - t) * y2
        return CGPoint(x: resX, y: resY)
    }
}
