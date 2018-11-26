//
//  RaceView.swift
//  AnimationTask2
//
//  Created by vitali on 11/24/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    static let controlPointRadius: CGFloat = 6
    static let curveControlPointColor = UIColor.purple
    static let trackControlPoint = UIColor.cyan
    static let zoomSensivity: CGFloat = 0.1
    
    static let snapToPointDistance: Double = 50
}

@IBDesignable
class RaceView: UIView {
    
    //MARK: - Views
    
    private var carView: UIImageView!
    private var resetZoomButton: UIButton!
    
    
    //MARK: - Prperties
    
    var isEdited = false {
        didSet {
            updateEditState()
        }
    }
    
    private var firstRun = true
    
    private var editedSegmentIndex: Int?
    private var editedSegnetSubindex: Int?
    
    private var helperPath = UIBezierPath()
    private var tapRecognizer: UITapGestureRecognizer!
    private var pinchRecognizer: UIPinchGestureRecognizer!
    private var panRecognizer: UIPanGestureRecognizer!
    private var track: RaceTrack! {
        didSet {
            self.carAnimation = createAnimation(from: track)
        }
    }
    private var trackPath: UIBezierPath!
    
    private var carAnimation: CAKeyframeAnimation?
    
    private var zoomLevel = 1.0 {
        didSet {
            self.layer.transform = CATransform3DScale(self.layer.transform, CGFloat(zoomLevel), CGFloat(zoomLevel), CGFloat(zoomLevel))
        }
    }
    
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
        carView = UIImageView(image: UIImage(named: Consts.carImage))
        carView.center = CGPoint(x: 100, y: 100)
        self.addSubview(carView)
        configureGestureRecognizers()
        createTrack()
        trackPath = createPathFrom(track: track)
        configureZoomButton()
        
    }
    
    private func createTrack(){
        
        let point1 = CGPoint(x: bounds.origin.x + 10, y: bounds.origin.y + 10)
        let point2 = CGPoint(x: bounds.size.width - 10, y: bounds.origin.y + 10)
        let point3 = CGPoint(x: bounds.origin.x + 10, y: bounds.size.height - 10)
        let controlPoint1 = CGPoint(x: 100, y: 100)
        let controlPoint2 = CGPoint(x: 150, y: 250)
        let firstSegment: RaceSegment = .line(from: point1, to: point2)
        let secondSegment: RaceSegment = .qubicCurve(controlPoint1: controlPoint1,
                                                     controlPoint2: controlPoint2,
                                                     end: point3)
        track = RaceTrack(segments: [firstSegment, secondSegment])
    }
    
    private func configureGestureRecognizers(){
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
        self.addGestureRecognizer(tapRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomChanged(sender:)))
        self.addGestureRecognizer(pinchRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(sender:)))
        self.addGestureRecognizer(panRecognizer)
        
    }
    
    private func configureZoomButton(){
        resetZoomButton = UIButton()
        resetZoomButton.backgroundColor = UIColor.blue
        self.addSubview(resetZoomButton)
        resetZoomButton.addTarget(self, action: #selector(resetZoomClicked), for: .touchUpInside)
        resetZoomButton.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: resetZoomButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 50),
            NSLayoutConstraint(item: resetZoomButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50),
            NSLayoutConstraint(item: resetZoomButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20),
            NSLayoutConstraint(item: resetZoomButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20)
            ])
    }
    
    //MARK: - Draw related

    override func draw(_ rect: CGRect) {
        if firstRun {
            createTrack()
            firstRun = false
        }
        
        let path = createPathFrom(track: track)
        UIColor.red.setStroke()
        path.stroke()
        
        if isEdited {
            drawControlPoints(track: track)
        }
        
    }
    
    private func drawControlPoints(track: RaceTrack){
        
        var nodePoints = [CGPoint]()
        var controlPoints = [CGPoint]()
        
        for segment in track.segments {
            switch segment {
            case .line(from: let from, to: let to):
                nodePoints.append(contentsOf: [from, to])
            case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
                nodePoints.append(end)
                controlPoints.append(contentsOf: [cp1, cp2])
            }
        }
        
        let nodeRects = nodePoints.map { (point) -> CGRect in
            return CGRect(x: point.x - Const.controlPointRadius,
                          y: point.y - Const.controlPointRadius,
                          width: Const.controlPointRadius * 2,
                          height: Const.controlPointRadius * 2)
        }
        
        let controlPointsRects = controlPoints.map { (point) -> CGRect in
            return CGRect(x: point.x - Const.controlPointRadius,
                          y: point.y - Const.controlPointRadius,
                          width: Const.controlPointRadius * 2,
                          height: Const.controlPointRadius * 2)
        }
        
        Const.trackControlPoint.setFill()
        for nodeRect in nodeRects {
            let path = UIBezierPath(ovalIn: nodeRect)
            path.fill()
        }
        Const.curveControlPointColor.setFill()
        for controlPointRect in controlPointsRects {
            let path = UIBezierPath(ovalIn: controlPointRect)
            path.fill()
        }
        
    }

}

//MARK: - Private Helper Methods
private extension RaceView{
    
    
    
    func createPathFrom(track: RaceTrack) -> UIBezierPath {
        let path = UIBezierPath()
        for segment in track.segments {
            switch segment {
            case .line(from: let from, to: let to):
                path.move(to: from)
                path.addLine(to: to)
            case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
                path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
            }
        }
        return path
    }
    
    
    func createAnimation(from track: RaceTrack) -> CAKeyframeAnimation {
        let path = createPathFrom(track: track)
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.path = path.cgPath
        animation.duration = 3
        animation.rotationMode = kCAAnimationRotateAuto
        animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        return animation
    }
    
    
    func updateEditState(){
        setNeedsDisplay()
    }
    
    func handleTrackEdit(panRecognizer: UIPanGestureRecognizer){
        
        let touchPoint: CGPoint = panRecognizer.location(in: self)
        
        switch panRecognizer.state{
        case .began:
            var selectedIndex: Int? = nil
            var selectedSubindex: Int? = nil
            var minDistance: Double = Double.greatestFiniteMagnitude
            for index in 0..<track.segments.count {
                switch track.segments[index]{
                case .line(from: let from, to: let to):
                    let fromDistance = from.distance(to: touchPoint)
                    let toDistance = to.distance(to: touchPoint)
                    let min = Double.minimum(Double(fromDistance), Double(toDistance))
                    if min < Const.snapToPointDistance && min < minDistance {
                        selectedIndex = index
                        minDistance = min
                    }
                case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
                    let cp1Distance = cp1.distance(to: touchPoint)
                    let cp2Distance = cp2.distance(to: touchPoint)
                    let endDistance = end.distance(to: touchPoint)
                    let (min, subindex): (CGFloat, Int) = [(cp1Distance, 0), (cp2Distance, 1), (endDistance, 2)].reduce((cp1Distance, 0), { res, currDistance in
                        if res.0 < currDistance.0 {
                            return res
                        } else {
                            return currDistance
                        }
                    })
                    if Double(min) < Const.snapToPointDistance && Double(min) < minDistance {
                        selectedIndex = index
                        selectedSubindex = subindex
                        minDistance = Double(min)
                    }
                }
                self.editedSegmentIndex = selectedIndex
                self.editedSegnetSubindex = selectedSubindex
            }
        case .changed:
            if let index = editedSegmentIndex, let subindex = editedSegnetSubindex {
                switch track.segments[index]{
                case .line(from: let from, to: let to):
                    var newTrack = track!
                    switch subindex {
                    case 0:
                        newTrack.segments[index] = .line(from: touchPoint, to: to)
                    case 1:
                        newTrack.segments[index] = .line(from: from, to: touchPoint)
                    default:
                        fatalError("Wrong index: \(subindex)")
                    }
                    self.track = newTrack
                    setNeedsDisplay()
                case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
                    var newTrack = track!
                    switch subindex {
                    case 0:
                        newTrack.segments[index] = .qubicCurve(controlPoint1: touchPoint, controlPoint2: cp2, end: end)
                    case 1:
                        newTrack.segments[index] = .qubicCurve(controlPoint1: cp1, controlPoint2: touchPoint, end: end)
                    case 2:
                        newTrack.segments[index] = .qubicCurve(controlPoint1: cp1, controlPoint2: cp2, end: touchPoint)
                    default:
                        fatalError("Wrong index: \(subindex)")
                    }
                    self.track = newTrack
                    setNeedsDisplay()
                }
            }
            
        case .ended:
            self.editedSegmentIndex = nil
            self.editedSegnetSubindex = nil
        default:
            return
        }
    }
}

//MARK: - Callbacks

private extension RaceView {
    
    @objc func onPanGesture(sender: UIPanGestureRecognizer){
        if isEdited {
            handleTrackEdit(panRecognizer: sender)
        }
    }
    
    @objc func onTap(sender: UITapGestureRecognizer){
        if !isEdited {
            if let animation = carAnimation {
                carView.layer.add(animation, forKey: "animateCar")
            }
        }
    }
    
    @objc func resetZoomClicked(){
        zoomLevel = 1.0
    }
    
    @objc func zoomChanged(sender: UIPinchGestureRecognizer){
        zoomLevel = Double(sender.scale)
        print("\(sender.scale)")
        //sender.scale = 1.0
    }
}
