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
    static let curveControlPointConnectionColor = UIColor.gray
    static let trackControlPoint = UIColor.cyan
    
    static let roadColor = UIColor.black
    static let roadLineWidth: CGFloat = 8
    static let dashedPathColor = UIColor.white
    static let dashedPathDashPattern: [CGFloat] = [5]
    
    static let snapToPointDistance: Double = 50
    
    static let createNewSegmentAlertDialogTitle = "Select Segment Type"
    static let createNewSegmentAlertDialogLineSegment = "Line"
    static let createNewSegmentAlertDialogQubicCurveSegment = "Qubic Curve"
    static let createNewSegmentAlertDialogCancel = "Cancel"
}

@IBDesignable
class RaceView: UIView {
    
    //MARK: - Views
    
    private var carView: UIImageView!
    
    
    //MARK: - Prperties
    
    weak var delegate: RaceViewDelegate?
    
    var isEdited = false {
        didSet {
            updateEditState()
        }
    }
    
    private var firstRun = true
    
    private var editedPointTuple: (Int, Int)?
    
    private var helperPath = UIBezierPath()
    private var tapRecognizer: UITapGestureRecognizer!
    private var panRecognizer: UIPanGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    
    private var track: RaceTrack! {
        didSet {
            self.carAnimation = createAnimation(from: track)
        }
    }
    private var trackPath: UIBezierPath!
    private var carAnimation: CAKeyframeAnimation?
    
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
        configureGestureRecognizers()
        carView = UIImageView(image: UIImage(named: Consts.carImage))
        self.addSubview(carView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createTrack()
        let serivce = RaceTrackService(track: track)
        if let firstPoint = serivce.firstPoint() {
            carView.center = firstPoint
        } else {
            carView.center = CGPoint(x: 100, y: 100)
        }
        
        trackPath = createPathFrom(track: track)
    }
    
    private func createTrack(){
        
        let sg1point1 = CGPoint(x: bounds.origin.x + 50, y: bounds.origin.y + 50)
        let sg1point2 = CGPoint(x: sg1point1.x + 100, y: bounds.origin.y + 50)
        let sg2Cp1 = CGPoint(x: bounds.origin.x + bounds.size.width / 2 - 40, y: frame.origin.y + 25)
        let sg2Cp2 = CGPoint(x: bounds.origin.x + bounds.size.width / 2, y: frame.origin.y + 10)
        let sg2end = CGPoint(x: frame.size.width * 0.7, y: frame.origin.y + 64)
        let sg3Cp1 = CGPoint(x: frame.size.width * 0.85, y: frame.size.height * 0.7)
        let sg3Cp2 = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.3)
        let sg3end = CGPoint(x: frame.size.width * 0.6, y: frame.size.height * 0.8)
        let sg4Cp1 = CGPoint(x: frame.size.width * 0.75, y: frame.size.height * 0.95)
        let sg4Cp2 = CGPoint(x: frame.size.width * 0.4, y: frame.size.height * 0.98)
        let sg4end = CGPoint(x: frame.size.width * 0.28, y: frame.size.height * 0.88)
        let sg5point1 = CGPoint(x: frame.size.width * 0.28, y: frame.size.height * 0.88)
        let sg5point2 = CGPoint(x: frame.size.width * 0.15, y: frame.size.height * 0.4)
        let sg6point1 = CGPoint(x: frame.size.width * 0.15, y: frame.size.height * 0.4)
        let sg6point2 = sg1point1
        let firstSegment: RaceSegment = .line(from: sg1point1, to: sg1point2)
        let secondSegment: RaceSegment = .qubicCurve(controlPoint1: sg2Cp1,
                                                     controlPoint2: sg2Cp2,
                                                     end: sg2end)
        let thirdSegment: RaceSegment = .qubicCurve(controlPoint1: sg3Cp1,
                                                    controlPoint2: sg3Cp2,
                                                    end: sg3end)
        let fourthSegment: RaceSegment = .qubicCurve(controlPoint1: sg4Cp1,
                                                     controlPoint2: sg4Cp2,
                                                     end: sg4end)
        let fifthSegment: RaceSegment = .line(from: sg5point1, to: sg5point2)
        let sixthSegment: RaceSegment = .line(from: sg6point1, to: sg6point2)
        track = RaceTrack(segments: [firstSegment, secondSegment, thirdSegment, fourthSegment, fifthSegment, sixthSegment])
    }
    
    private func configureGestureRecognizers(){
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
        self.addGestureRecognizer(tapRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(sender:)))
        self.addGestureRecognizer(panRecognizer)
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        self.addGestureRecognizer(longPressRecognizer)
        
    }
    
    
    //MARK: - Draw related

    override func draw(_ rect: CGRect) {
        
        let dashedPath = createPathFrom(track: track)
        let road = createPathFrom(track: track)
        
        Const.roadColor.setStroke()
        road.lineWidth = Const.roadLineWidth
        road.stroke()
        
        Const.dashedPathColor.setStroke()
        dashedPath.setLineDash(Const.dashedPathDashPattern, count: Const.dashedPathDashPattern.count, phase: 0.0)
        dashedPath.stroke()
        
        if isEdited {
            drawControlPoints(track: track)
        }
        
    }
    
    private func drawControlPoints(track: RaceTrack){
        
        var lastPoint: CGPoint = CGPoint(x: 0, y: 0)
        for segment in track.segments {
            switch segment {
            case .line(from: let from, to: let to):
                drawNodePoint(point: from)
                drawNodePoint(point: to)
                lastPoint = to
            case .qubicCurve(controlPoint1: let cp1, controlPoint2: let cp2, end: let end):
                drawConnection(poin1: lastPoint, point2: cp1)
                drawConnection(poin1: cp1, point2: cp2)
                drawConnection(poin1: cp2, point2: end)
                drawControlPoint(point: cp1)
                drawControlPoint(point: cp2)
                drawNodePoint(point: end)
                lastPoint = end
            }
        }
    }
    
    private func drawNodePoint(point: CGPoint) {
        let pointRect = CGRect(x: point.x - Const.controlPointRadius,
                               y: point.y - Const.controlPointRadius,
                               width: Const.controlPointRadius * 2,
                               height: Const.controlPointRadius * 2)
        Const.trackControlPoint.setFill()
        let path = UIBezierPath(ovalIn: pointRect)
        path.fill()
    }
    
    private func drawControlPoint(point: CGPoint) {
        let pointRect = CGRect(x: point.x - Const.controlPointRadius,
                               y: point.y - Const.controlPointRadius,
                               width: Const.controlPointRadius * 2,
                               height: Const.controlPointRadius * 2)
        Const.curveControlPointColor.setFill()
        let path = UIBezierPath(ovalIn: pointRect)
        path.fill()
    }
    
    private func drawConnection(poin1: CGPoint, point2: CGPoint){
        let path = UIBezierPath()
        path.move(to: poin1)
        path.addLine(to: point2)
        let dashes: [CGFloat] = [10.0]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        Const.curveControlPointConnectionColor.setStroke()
        path.stroke()
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
        
        let service = RaceTrackService(track: track)
        
        switch panRecognizer.state{
        case .began:
                self.editedPointTuple = service.hitTest(point: touchPoint)
        case .changed:
            if let editedPointTuple = self.editedPointTuple {
                do {
                    self.track = try service.changePoint(locationTuple: editedPointTuple, to: touchPoint)
                } catch {
                    fatalError(error.localizedDescription)
                }
                setNeedsDisplay()
            }
        case .ended:
            self.editedPointTuple = nil
        default:
            return
        }
    }
    
    func showCreateNewSegmentDialog(point: CGPoint){
        let alertController = UIAlertController(title: Const.createNewSegmentAlertDialogTitle, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: Const.createNewSegmentAlertDialogCancel, style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        let createLine = UIAlertAction(title: Const.createNewSegmentAlertDialogLineSegment, style: .default, handler: { _ in
            self.createLineSegment(to: point)
        })
        let createQubicCurve = UIAlertAction(title: Const.createNewSegmentAlertDialogQubicCurveSegment, style: .default, handler: { _ in
            self.createQubicCurveSegment(to: point)
        })
        
        alertController.addAction(createLine)
        alertController.addAction(createQubicCurve)
        alertController.addAction(cancelAction)
        
        
        delegate?.alertControllerContext.present(alertController, animated: true, completion: nil)
    }
    
    func createLineSegment(to point: CGPoint){
        let service = RaceTrackService(track: track)
        self.track = service.addLineSegment(point: point)
        setNeedsDisplay()
    }
    
    func createQubicCurveSegment(to point: CGPoint){
        let service = RaceTrackService(track: track)
        self.track = service.addCurveSegment(point: point)
        setNeedsDisplay()
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
    
    @objc func onLongPress(sender: UILongPressGestureRecognizer){
        
        if isEdited {
            showCreateNewSegmentDialog(point: sender.location(in: self))
        }
    }
}
