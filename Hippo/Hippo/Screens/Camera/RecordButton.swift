//
//  RecordButton.swift
//  Hippo
//
//  Created by Huy Le on 20/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit

final class RecordButton: UIButton {
    
    lazy private var circleLayer: CAShapeLayer = self.lazy_circleLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private var isAnimated: Bool = false
    
    private func setupView() {
        setBackgroundImage(Style.MyAsset.record_button_outer.image, for: .normal)
        adjustsImageWhenHighlighted = false
        tintColor = .clear
        setTitle(nil, for: .normal)
        
        addObserver(self, forKeyPath: #keyPath(isTracking), options: .new, context: nil)
        addObserver(self, forKeyPath: #keyPath(isSelected), options: .new, context: nil)
        
        layer.addSublayer(circleLayer)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case #keyPath(isTracking):
            isTrackingOnChanged()
        case #keyPath(isSelected):
            isSelectedOnChanged()
        default:
            break
        }
    }
    
    private func isTrackingOnChanged() {
        if self.isHighlighted == false && self.isSelected == false {
            self.circleLayer.add(Animation().path(to: self.highlightedCirclePath()), forKey: nil)
        }
        if self.isHighlighted == false && self.isSelected == true {
            self.circleLayer.add(Animation().path(to: self.highlightedSquarePath()), forKey: nil)
        }
    }
    
    private func isSelectedOnChanged() {
        if self.isSelected {
            self.circleLayer.add(Animation().path(to: self.selectedSquarePath()), forKey: nil)
            self.circleLayer.fillColor = Style.RecordButton.selectedColor.cgColor
        } else {
            self.circleLayer.add(Animation().path(to: self.normalCirclePath()), forKey: nil)
            self.circleLayer.fillColor = Style.RecordButton.normalColor.cgColor
        }
    }
    
    private func lazy_circleLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = Style.RecordButton.normalColor.cgColor
        layer.path = normalCirclePath()
        return layer
    }
    
    private func normalCirclePath() -> CGPath {
        let bezier = CirclePath(center: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
                                radius: (self.bounds.width / 2) - 7).bezierPath()
        return bezier.cgPath
    }
    
    private func highlightedCirclePath() -> CGPath {
        let bezier = CirclePath(center: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
                                radius: (self.bounds.width / 2) - 10).bezierPath()
        return bezier.cgPath
    }
    
    private func selectedSquarePath() -> CGPath {
        let bezier = SquarePath(center: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2), side: 28).bezierPath()
        return bezier.cgPath
    }
    
    private func highlightedSquarePath() -> CGPath {
        let bezier = SquarePath(center: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2), side: 24).bezierPath()
        return bezier.cgPath
    }
}

struct CirclePath {
    let center: CGPoint
    let radius: CGFloat
    
    func bezierPath() -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -.pi, endAngle: -.pi/2, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
        circlePath.close()
        return circlePath
    }
}

struct SquarePath {
    let center: CGPoint
    let side: CGFloat
    let radius: CGFloat = 4
    
    private var halfSide: CGFloat {
        return side / 2
    }
    
    func bezierPath() -> UIBezierPath {
        let squarePath = UIBezierPath()
        
        let beforeUpperLeftArc: CGPoint = CGPoint(x: center.x - halfSide, y: center.y - halfSide + radius)
        let beforeUpperRightArc: CGPoint = CGPoint(x: center.x + halfSide - radius, y: center.y - halfSide)
        let beforeLowerRightArc: CGPoint = CGPoint(x: center.x + halfSide, y: center.y + halfSide - radius)
        let beforeLowerLeftArc: CGPoint = CGPoint(x: center.x - halfSide + radius, y: center.y + halfSide)

        var upperLeftArcCenter: CGPoint = beforeUpperLeftArc
        var upperRightArcCenter: CGPoint = beforeUpperRightArc
        var lowerLeftArcCenter: CGPoint = beforeLowerLeftArc
        var lowerRightArcCenter: CGPoint = beforeLowerRightArc

        upperLeftArcCenter.x += radius
        upperRightArcCenter.y += radius
        lowerRightArcCenter.x -= radius
        lowerLeftArcCenter.y -= radius
        
        squarePath.addArc(withCenter: upperLeftArcCenter, radius: radius, startAngle: -.pi, endAngle: -1/2 * .pi, clockwise: true)
        squarePath.addArc(withCenter: upperRightArcCenter, radius: radius, startAngle: -1/2 * .pi, endAngle: 0, clockwise: true)
        squarePath.addArc(withCenter: lowerRightArcCenter, radius: radius, startAngle: 0, endAngle: 1/2 * .pi, clockwise: true)
        squarePath.addArc(withCenter: lowerLeftArcCenter, radius: radius, startAngle: 1/2 * .pi, endAngle: .pi, clockwise: true)
        squarePath.close()
        return squarePath
    }
}

struct Animation {
    
    func path(to value: CGPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.3
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        return animation
    }
}
