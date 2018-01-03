//
//  GaugeView.swift
//  Gauges
//
//  Created by Ilya Puchka on 19/12/2017.
//  Copyright © 2018 Ilya Puchka. All rights reserved.
//

import UIKit

open class GaugeView: UIControl {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
    }

    open var shadow: Shadow = Shadow() {
        didSet {
            _visualEffectView.isHidden = !hasBlur
            if let visualEffectView = visualEffectView {
                visualEffectView.blurRadius = shadow.radius
                gaugeCircles.forEach { circle in
                    circle.backing.alpha = shadow.opacity
                    if circle.backing.superview == nil {
                        insertSubview(circle.backing, belowSubview: visualEffectView)
                    } else {
                        sendSubview(toBack: circle.backing)
                    }
                }
            } else if case .colors(let colors) = shadow.color {
                gaugeCircles.enumerated().forEach { index, circle in
                    if circle.backing.superview == nil {
                        insertSubview(circle.backing, at: 0)
                    } else {
                        sendSubview(toBack: circle.backing)
                    }
                    circle.backing.layer.shadowColor = colors.count == 1 ? colors[0].cgColor : colors[index].cgColor
                    circle.backing.layer.shadowOpacity = Float(shadow.opacity)
                    circle.backing.layer.shadowRadius = shadow.radius
                    circle.backing.layer.shadowOffset = shadow.offset
                }
            }
        }
    }

    open var gauges: [Gauge] = [] {
        didSet {
            if oldValue.count != gauges.count {
                let countDiff = gauges.count - oldValue.count
                if countDiff > 0 {
                    gauges.suffix(countDiff).forEach { _ in
                        let gaugeCircles = createGagueCircles()
                        addSubview(gaugeCircles.background)
                        addSubview(gaugeCircles.value)
                        self.gaugeCircles.append(gaugeCircles)
                    }
                } else {
                    gaugeCircles.suffix(-countDiff).forEach {
                        $0.value.removeFromSuperview()
                        $0.background.removeFromSuperview()
                        $0.backing.removeFromSuperview()
                    }
                    gaugeCircles.removeLast(-countDiff)
                }
            }

            for (gaugeCircles, gauge) in zip(gaugeCircles, gauges) {
                gaugeCircles.value.gauge = gauge
                gaugeCircles.backing.gauge = gauge

                var backgroundGauge = gauge
                backgroundGauge.value = 1
                backgroundGauge.color = gauge.backgroundColor
                gaugeCircles.background.gauge = backgroundGauge
            }

            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    public typealias GaugeCircles = (value: GaugeCircleView, background: GaugeCircleView, backing: GaugeCircleView)
    open private(set) var gaugeCircles: [GaugeCircles] = []

    func createGagueCircles() -> GaugeCircles {
        let value = GaugeCircleView(frame: bounds)
        let background = GaugeCircleView(frame: bounds)
        let backing = GaugeCircleView(frame: bounds)
        return (value, background, backing)
    }

    private var visualEffectView: UIVisualEffectView? {
        guard hasBlur else { return nil }
        return _visualEffectView
    }

    public var hasBlur: Bool {
        if case .blur = shadow.color { return true } else { return false }
    }

    private lazy var _visualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.blurRadius = shadow.radius
        visualEffectView.blurBackgroundColor = .clear
        visualEffectView.backgroundColor = backgroundColor
        visualEffectView.saturationAmount = 1
        visualEffectView.clipsToBounds = false
        visualEffectView.frame = bounds
        insertSubview(visualEffectView, at: 0)
        return visualEffectView
    }()

    open override var backgroundColor: UIColor? {
        didSet {
            visualEffectView?.backgroundColor = backgroundColor
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (gaugeCircles, gauge) in zip(gaugeCircles, gauges) {
            sizeView(gaugeCircles.value, radius: gauge.radius)
            sizeView(gaugeCircles.background, radius: gauge.radius)
            if hasBlur {
                sizeView(gaugeCircles.backing, radius: gauge.radius, offset: shadow.offset)
            } else {
                sizeView(gaugeCircles.backing, radius: gauge.radius)
            }
        }
        visualEffectView?.frame = bounds.insetBy(dx: -shadow.radius * 3, dy: -shadow.radius * 3).offsetBy(dx: shadow.offset.width, dy: shadow.offset.height)
        CATransaction.commit()
    }

    private func sizeView(_ view: UIView, radius: CGFloat, offset: CGSize = .zero) {
        guard let superview = view.superview else { return }
        let center = superview.convert(CGPoint(x: bounds.midX + offset.width, y: bounds.midY + offset.height), from: self)
        let size = CGSize(width: radius * 2, height: radius * 2)
        view.frame = CGRect(origin: CGPoint(x: center.x - radius, y: center.y - radius), size: size)
    }

    open override var intrinsicContentSize: CGSize {
        guard let maxGauge = gauges.max(by: { $0.radius < $1.radius }) else { return frame.size }
        return CGSize(width: max(frame.size.width, maxGauge.radius * 2), height: max(frame.size.height, maxGauge.radius * 2))
    }

    open override func sizeToFit() {
        guard let maxGauge = gauges.max(by: { $0.radius < $1.radius }) else {
            super.sizeToFit()
            return
        }
        frame.size = CGSize(width: maxGauge.radius * 2, height: maxGauge.radius * 2)
    }

}

open class GaugeCircleView: UIView {
    open override class var layerClass: AnyClass { return GaugeCircleLayer.self }

    var gaugeLayer: GaugeCircleLayer {
        return layer as! GaugeCircleLayer
    }

    open var gauge: Gauge {
        get {
            return gaugeLayer.gauge
        }
        set {
            gaugeLayer.gauge = newValue
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = false
    }
}

open class GaugeCircleLayer: CALayer {

    open var gauge: Gauge = Gauge() {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            maskLayer.lineWidth = gauge.lineWidth
            maskLayer.path = circlePath(bounds: bounds, lineWidth: gauge.lineWidth)
            maskLayer.strokeEnd = CGFloat(gauge.value)

            switch gauge.color {
            case .solid(let color):
                gradientLayer.isHidden = true
                solidLayer.isHidden = false
                solidLayer.backgroundColor = color.cgColor
                solidLayer.mask = maskLayer
            case .gradient(let colors):
                gradientLayer.isHidden = false
                solidLayer.isHidden = true
                gradientLayer.colors = colors.map({ $0.color.cgColor })
                gradientLayer.locations = colors.map({ NSNumber(value: Float($0.location)) })
                gradientLayer.mask = maskLayer
            }

            CATransaction.commit()
        }
    }

    open func setValue(_ value: CGFloat, animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim.duration = 0.25
        anim.toValue = value
        maskLayer.add(anim, forKey: "strokeEnd")
        maskLayer.strokeEnd = value
        CATransaction.commit()
    }

    public lazy var solidLayer: CALayer = {
        let layer = CALayer()
        layer.frame = bounds
        addSublayer(layer)
        return layer
    }()

    public lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = bounds
        addSublayer(layer)
        return layer
    }()

    public lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = kCALineCapRound
        return layer
    }()

    public override init() {
        super.init()
        masksToBounds = false
    }

    public override init(layer: Any) {
        self.gauge = (layer as? GaugeCircleLayer)?.gauge ?? Gauge()
        super.init(layer: layer)
        masksToBounds = false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        masksToBounds = false
    }

    open override func layoutSublayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        solidLayer.frame = bounds
        gradientLayer.frame = bounds
        maskLayer.path = circlePath(bounds: bounds, lineWidth: gauge.lineWidth)
        CATransaction.commit()

        super.layoutSublayers()
    }

    func circlePath(bounds: CGRect, lineWidth: CGFloat) -> CGPath {
        let path = UIBezierPath()
        if gauge.direction == .clockwise {
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.width/2 - lineWidth/2, startAngle: -(gauge.startAngle + 2 * .pi), endAngle: -gauge.startAngle, clockwise: true)
        } else {
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.width/2 - lineWidth/2, startAngle: -gauge.startAngle, endAngle: -(gauge.startAngle + 2 * .pi), clockwise: false)
        }
        return path.cgPath
    }

}

public struct Gauge {
    public enum Color {
        case gradient([(color: UIColor, location: CGFloat)])
        case solid(UIColor)
    }

    public enum Direction {
        case clockwise
        case counterClockwise
    }

    public var value: Float
    public var color: Color
    public var radius: CGFloat
    public var lineWidth: CGFloat
    public var backgroundColor: Color
    public var direction: Direction
    public var startAngle: CGFloat

    public init(value: Float = 0, color: Color = .solid(.black), radius: CGFloat = 0, lineWidth: CGFloat = 20, backgroundColor: Color = .solid(.lightGray), direction: Direction = .clockwise, startAngle: CGFloat = .pi/2) {
        self.value = value
        self.color = color
        self.radius = radius
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.direction = direction
        self.startAngle = startAngle
    }
}

public struct Shadow {
    public enum Color {
        case colors([UIColor])
        case blur
    }
    public var color: Color
    public var offset: CGSize
    public var opacity: CGFloat
    public var radius: CGFloat

    public init(color: Color = .colors([.lightGray]), offset: CGSize = CGSize(width: 0, height: 8), opacity: CGFloat = 0.5, radius: CGFloat = 8) {
        self.color = color
        self.offset = offset
        self.opacity = opacity
        self.radius = radius
    }
}

public extension UIVisualEffectView {

    var filterLayer: CALayer? {
        return layer.sublayers?.first
    }

    var blurFilter: NSObject? {
        return filterLayer?
            .filters?.flatMap({ $0 as? NSObject })
            .first(where: { ($0.value(forKey: "name") as? String)?.hasPrefix("gaussianBlur") == true })
    }

    var saturationFilter: NSObject? {
        return filterLayer?
            .filters?.flatMap({ $0 as? NSObject })
            .first(where: { ($0.value(forKey: "name") as? String)?.hasPrefix("colorSaturate") == true })
    }

    var blurRadius: CGFloat {
        get {
            return blurFilter?.value(forKey: "inputRadius") as? CGFloat ?? 0
        }
        set {
            blurFilter?.setValue(newValue, forKey: "inputRadius")
            if newValue == 0 { scale = 1 }
        }
    }

    var saturationAmount: CGFloat {
        get {
            return saturationFilter?.value(forKey: "inputAmount") as? CGFloat ?? 1
        }
        set {
            saturationFilter?.setValue(newValue, forKey: "inputAmount")
        }
    }

    var scale: CGFloat? {
        get {
            return filterLayer?.value(forKey: "scale") as? CGFloat
        }
        set {
            filterLayer?.setValue(newValue, forKey: "scale")
        }
    }

    var blurBackgroundColorLayer: CALayer? {
        return layer.sublayers?.last
    }

    var blurBackgroundColor: UIColor? {
        get {
            return blurBackgroundColorLayer?.backgroundColor.map(UIColor.init)
        }
        set {
            blurBackgroundColorLayer?.backgroundColor = newValue?.cgColor
        }
    }

}
