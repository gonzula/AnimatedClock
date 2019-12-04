//
//  ClockView.swift
//  ClockView
//
//  Created by Gonzo Fialho on 03/12/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class ClockView: UIView {

    @objc public dynamic var seconds: Int = 0 {
        didSet {
            customLayer.seconds = seconds
        }
    }
    var time: (Int, Int, Int) {
        get {(seconds / 3600, seconds / 60, seconds % 60)}
        set {seconds = newValue.0 * 3600 + newValue.1 * 60 + newValue.2}
    }

    override var intrinsicContentSize: CGSize {CGSize(width: 700, height: 700)}

    fileprivate var customLayer: Layer {
        guard let layer = self.layer as? Layer else {fatalError()}

        return layer
    }

    override public class var layerClass: AnyClass {
        return Layer.self
    }

    var scale: CGFloat {bounds.width/300}
    let middle: CGPoint = CGPoint(x: 150, y: 150)
    let radius: CGFloat = 150
    let borderWidht: CGFloat = 25

    let dashOffset: CGFloat = 4
    let dashWidth: CGFloat = 7.5

    var dashBigRadius: CGFloat {radius - borderWidht - dashOffset}
    var dashSmallRadius: CGFloat {radius - borderWidht - dashOffset - dashWidth}

    var textRadius: CGFloat {dashSmallRadius - 17.5}

    var pivotRadius: CGFloat = 7.5

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentMode = .redraw

        backgroundColor = UIColor.white//red.withAlphaComponent(0.2)
        isOpaque = true

        customLayer.seconds = self.seconds
        layer.setNeedsDisplay()
    }

    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()!.unobtrusive { ctx in
            ctx.scaleBy(x: scale, y: scale)
            ctx.translateBy(x: middle.x, y: middle.y)
            ctx.rotate(by: -.pi / 2)

            drawBorder(ctx: ctx)
            drawDashes(ctx: ctx)
            drawNumbers(ctx: ctx)
            drawPivot(ctx: ctx)
        }
    }

    func drawBorder(ctx: CGContext) {
        let lineWidth: CGFloat = borderWidht
        let path = UIBezierPath(arcCenter: .zero,
                                radius: radius - lineWidth/2,
                                startAngle: 0,
                                endAngle: .pi * 2,
                                clockwise: true)
        path.lineWidth = lineWidth
        UIColor.black.setStroke()
        path.stroke()
    }

    func drawDashes(ctx: CGContext) {
        let dashBigRadius = self.dashBigRadius
        let dashSmallRadius = self.dashSmallRadius
        for i in 0..<60 {
            let minute: CGFloat = CGFloat(i)
            let lineWidth: CGFloat = i.isMultiple(of: 5) ? 5 : 2.5
            ctx.unobtrusive { ctx in
                ctx.rotate(by: minute * (CGFloat.pi * 2 / 60))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: dashBigRadius, y: 0))
                path.addLine(to: CGPoint(x: dashSmallRadius , y: 0))
                path.lineWidth = lineWidth
                path.stroke()
            }
        }
    }

    func drawNumbers(ctx: CGContext) {
        let textRadius = self.textRadius
        for i in 0..<12 {
            ctx.unobtrusive { ctx in
                ctx.rotate(by: .pi / 2)
                let hour = i == 0 ? "12" : String(i)
                let minute: CGFloat = CGFloat(i) * 5
                let angle = minute * (CGFloat.pi * 2 / 60)
                let textCenter = CGPoint(x: sin(angle) * textRadius,
                                         y: -cos(angle) * textRadius)
                let text = NSAttributedString(string: hour,
                                              attributes: [
                                                .font: UIFont.systemFont(ofSize: 30, weight: .regular)
                                                ])
                let textSize = text.size()
                text.draw(at: CGPoint(x: textCenter.x - textSize.width/2, y: textCenter.y - textSize.height/2))
            }
        }
    }

    func drawPivot(ctx: CGContext) {
        UIColor.black.setFill()
        UIBezierPath(arcCenter: .zero,
                     radius: pivotRadius,
                     startAngle: 0,
                     endAngle: .pi * 2,
                     clockwise: true).fill()
    }

    override public func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(seconds),
            let action = action(for: layer, forKey: #keyPath(backgroundColor)) as? CAAnimation {

            let animation = CABasicAnimation()
            animation.keyPath = #keyPath(seconds)
            animation.fromValue = customLayer.seconds
            animation.toValue = seconds
            animation.beginTime = action.beginTime
            animation.duration = action.duration
            animation.speed = action.speed
            animation.timeOffset = action.timeOffset
            animation.repeatCount = action.repeatCount
            animation.repeatDuration = action.repeatDuration
            animation.autoreverses = action.autoreverses
            animation.fillMode = action.fillMode
            animation.timingFunction = action.timingFunction
            animation.delegate = action.delegate
            self.layer.add(animation, forKey: #keyPath(seconds))
        }
        return super.action(for: layer, forKey: event)
    }
}

private class Layer: CALayer {
    @NSManaged var seconds: Int

    var scale: CGFloat {bounds.width/300}
    let middle: CGPoint = CGPoint(x: 150, y: 150)

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(seconds) {
            return true
        }

        return super.needsDisplay(forKey: key)
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        UIGraphicsPushContext(ctx)

        ctx.unobtrusive { ctx in
            ctx.scaleBy(x: scale, y: scale)
            ctx.translateBy(x: middle.x, y: middle.y)
            ctx.rotate(by: -.pi / 2)

            drawMinuteHand(ctx: ctx)
            drawHourHand(ctx: ctx)
//            drawSecondHand(ctx: ctx)
        }

        UIGraphicsPopContext()
    }

    func drawMinuteHand(ctx: CGContext) {
        let minute = CGFloat(seconds) / 60

        let angle = CGFloat(minute) * (CGFloat.pi * 2 / 60)
        ctx.unobtrusive { ctx in
            ctx.rotate(by: angle)
            ctx.setLineWidth(4)
            ctx.move(to: CGPoint(x: -15, y: 0))
            ctx.addLine(to: CGPoint(x: 150 - 35, y: 0))
            ctx.strokePath()
        }
    }

    func drawHourHand(ctx: CGContext) {
        let hour = CGFloat(seconds) / 3600

        let minute: CGFloat = CGFloat(hour) * 5
        let angle = minute * (CGFloat.pi * 2 / 60)
        ctx.unobtrusive { ctx in
            ctx.rotate(by: angle)
            ctx.setLineWidth(6)
            ctx.move(to: CGPoint(x: -15, y: 0))
            ctx.addLine(to: CGPoint(x: 65, y: 0))
            ctx.strokePath()
        }
    }

    func drawSecondHand(ctx: CGContext) {
        let second = seconds % 60

        let angle = CGFloat(second) * (CGFloat.pi * 2 / 60)
        ctx.unobtrusive { ctx in
            ctx.setStrokeColor(UIColor.red.cgColor)
            ctx.rotate(by: angle)
            ctx.setLineWidth(2)
            ctx.move(to: CGPoint(x: -15, y: 0))
            ctx.addLine(to: CGPoint(x: 150 - 35, y: 0))
            ctx.strokePath()
        }
    }
}

extension CGContext {
    func unobtrusive(_ work: (CGContext) -> Void) {
        saveGState()
        work(self)
        restoreGState()
    }
}
