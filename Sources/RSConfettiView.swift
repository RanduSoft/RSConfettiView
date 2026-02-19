//
//  RSConfettiView
//
//  Created by Radu Ursache.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit
import QuartzCore

public class RSConfettiView: UIView {

    // MARK: - Types

    public enum ConfettiType {
        case confetti
        case image(UIImage)
    }

    public struct Configuration: Sendable {
        public var birthRate: Float
        public var lifetime: Float
        public var velocity: CGFloat
        public var velocityRange: CGFloat
        public var spin: CGFloat
        public var spinRange: CGFloat
        public var scaleRange: CGFloat
        public var scaleSpeed: CGFloat

        public static let `default` = Configuration()

        public init(
            birthRate: Float = 8.5,
            lifetime: Float = 14.0,
            velocity: CGFloat = 350.0,
            velocityRange: CGFloat = 80.0,
            spin: CGFloat = 3.5,
            spinRange: CGFloat = 4.0,
            scaleRange: CGFloat = 1.0,
            scaleSpeed: CGFloat = -0.1
        ) {
            self.birthRate = birthRate
            self.lifetime = lifetime
            self.velocity = velocity
            self.velocityRange = velocityRange
            self.spin = spin
            self.spinRange = spinRange
            self.scaleRange = scaleRange
            self.scaleSpeed = scaleSpeed
        }
    }

    private enum EmitterMode {
        case line
        case point(CGPoint)
    }

    // MARK: - Properties

    private var emitter: CAEmitterLayer?
    private var emitterMode: EmitterMode = .line

    public var colors: [UIColor] = [
        UIColor(red: 0.40, green: 0.64, blue: 0.98, alpha: 1.0), // Blue
        UIColor(red: 0.98, green: 0.42, blue: 0.62, alpha: 1.0), // Pink
        UIColor(red: 1.00, green: 0.78, blue: 0.22, alpha: 1.0), // Yellow
        UIColor(red: 0.96, green: 0.50, blue: 0.38, alpha: 1.0), // Coral
        UIColor(red: 0.30, green: 0.78, blue: 0.60, alpha: 1.0), // Green
        UIColor(red: 0.70, green: 0.52, blue: 0.90, alpha: 1.0), // Purple
        UIColor(red: 0.98, green: 0.56, blue: 0.76, alpha: 1.0)  // Rose
    ]

    public var type: ConfettiType = .confetti

    public var configuration: Configuration = .default

    public private(set) var isActive: Bool = false

    // MARK: - Init

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let emitter else { return }
        switch emitterMode {
        case .line:
            emitter.emitterPosition = CGPoint(x: bounds.midX, y: 0)
            emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        case .point(let point):
            emitter.emitterPosition = point
        }
    }

    // MARK: - Public

    /// Starts confetti raining from the top of the view.
    public func startConfetti() {
        emitterMode = .line
        configureEmitter()
    }

    /// Starts confetti shooting from a specific point (confetti gun effect).
    /// Particles burst upward and arc down with gravity.
    public func startConfetti(from point: CGPoint) {
        emitterMode = .point(point)
        configureEmitter()
    }

    /// Starts confetti shooting from the center of a source view (confetti gun effect).
    /// The source view's center is converted to this view's coordinate space.
    public func startConfetti(from sourceView: UIView) {
        let point = convert(sourceView.center, from: sourceView.superview)
        startConfetti(from: point)
    }

    public func stopConfetti() {
        emitter?.birthRate = 0
        isActive = false
    }

    // MARK: - Private

    private func configureEmitter() {
        emitter?.removeFromSuperlayer()

        let newEmitter = CAEmitterLayer()

        switch emitterMode {
        case .line:
            newEmitter.emitterPosition = CGPoint(x: bounds.midX, y: 0)
            newEmitter.emitterShape = .line
            newEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
        case .point(let point):
            newEmitter.emitterPosition = point
            newEmitter.emitterShape = .point
            newEmitter.emitterSize = .zero
        }

        let images = imagesForType(type)
        let shapeDivisor = Float(max(images.count, 1))
        var cells = [CAEmitterCell]()
        for color in colors {
            for image in images {
                cells.append(confettiCell(for: color, image: image, shapeDivisor: shapeDivisor))
            }
        }

        newEmitter.emitterCells = cells

        layer.addSublayer(newEmitter)
        emitter = newEmitter
        isActive = true

        if case .point = emitterMode {
            Task {
                try? await Task.sleep(nanoseconds: 100_000_000)
                emitter?.birthRate = 0
            }
        }
    }

    private func imagesForType(_ type: ConfettiType) -> [UIImage] {
        switch type {
        case .confetti:
            return Self.confettiShapes()
        case let .image(customImage):
            return [customImage]
        }
    }

    private func confettiCell(for color: UIColor, image: UIImage, shapeDivisor: Float) -> CAEmitterCell {
        let cell = CAEmitterCell()
        let config = configuration

        cell.birthRate = config.birthRate / shapeDivisor
        cell.lifetime = config.lifetime
        cell.lifetimeRange = 0
        let alpha = CGFloat.random(in: 0.7...1.0)
        cell.color = color.withAlphaComponent(alpha).cgColor
        cell.velocity = config.velocity
        cell.velocityRange = config.velocityRange
        cell.spin = config.spin
        cell.spinRange = config.spinRange
        cell.scaleRange = config.scaleRange
        cell.scaleSpeed = config.scaleSpeed
        cell.contents = image.cgImage

        switch emitterMode {
        case .line:
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi
        case .point:
            cell.birthRate *= 3
            cell.velocity *= 1.3
            cell.velocityRange *= 6
            cell.emissionLongitude = -.pi / 2
            cell.emissionRange = .pi / 8
            cell.yAcceleration = 50
        }

        return cell
    }
}

// MARK: - Confetti Shapes

extension RSConfettiView {

    private static func confettiShapes() -> [UIImage] {
        [drawDot(), drawTriangle(), drawStrip(), drawSemiCircle(),
         drawArc(), drawSquiggle(), drawStar(), drawCrown()]
    }

    private static func drawDot() -> UIImage {
        let size = CGSize(width: 8, height: 8)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }

    private static func drawTriangle() -> UIImage {
        let size = CGSize(width: 12, height: 10)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width / 2, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.close()
            UIColor.white.setFill()
            path.fill()
        }
    }

    private static func drawStrip() -> UIImage {
        let size = CGSize(width: 12, height: 5)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.white.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 1).fill()
        }
    }

    private static func drawSemiCircle() -> UIImage {
        let size = CGSize(width: 12, height: 7)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let path = UIBezierPath(
                arcCenter: CGPoint(x: size.width / 2, y: size.height),
                radius: size.width / 2,
                startAngle: .pi,
                endAngle: 0,
                clockwise: true
            )
            path.close()
            UIColor.white.setFill()
            path.fill()
        }
    }

    private static func drawArc() -> UIImage {
        let size = CGSize(width: 12, height: 12)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let path = UIBezierPath(
                arcCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: 4,
                startAngle: .pi * 0.3,
                endAngle: .pi * 1.7,
                clockwise: true
            )
            path.lineWidth = 2.5
            path.lineCapStyle = .round
            UIColor.white.setStroke()
            path.stroke()
        }
    }

    private static func drawSquiggle() -> UIImage {
        let size = CGSize(width: 10, height: 14)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 2, y: 0))
            path.addCurve(
                to: CGPoint(x: 8, y: size.height / 2),
                controlPoint1: CGPoint(x: 12, y: size.height * 0.15),
                controlPoint2: CGPoint(x: -2, y: size.height * 0.35)
            )
            path.addCurve(
                to: CGPoint(x: 2, y: size.height),
                controlPoint1: CGPoint(x: 12, y: size.height * 0.65),
                controlPoint2: CGPoint(x: -2, y: size.height * 0.85)
            )
            path.lineWidth = 2
            path.lineCapStyle = .round
            UIColor.white.setStroke()
            path.stroke()
        }
    }

    private static func drawStar() -> UIImage {
        let size = CGSize(width: 14, height: 14)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 6
            let path = UIBezierPath()
            for i in 0..<4 {
                let angle = CGFloat(i) * .pi / 4
                path.move(to: CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                ))
                path.addLine(to: CGPoint(
                    x: center.x - cos(angle) * radius,
                    y: center.y - sin(angle) * radius
                ))
            }
            path.lineWidth = 1.5
            path.lineCapStyle = .round
            UIColor.white.setStroke()
            path.stroke()
        }
    }

    private static func drawCrown() -> UIImage {
        let size = CGSize(width: 14, height: 9)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height * 0.4))
            path.addLine(to: CGPoint(x: size.width * 0.25, y: 0))
            path.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.4))
            path.addLine(to: CGPoint(x: size.width * 0.75, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height * 0.4))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.close()
            UIColor.white.setFill()
            path.fill()
        }
    }
}

// MARK: - Static Convenience

extension RSConfettiView {

    /// Shows confetti raining from the top, auto-dismissing after `duration` seconds.
    public static func showConfetti(
        inView view: UIView,
        type: ConfettiType = .confetti,
        duration: Double = 3,
        confettiBlocksUI: Bool = true,
        completionHandler: (() -> Void)? = nil
    ) {
        let confettiView = RSConfettiView(frame: view.bounds)
        confettiView.type = type
        confettiView.isUserInteractionEnabled = confettiBlocksUI
        view.addSubview(confettiView)
        confettiView.startConfetti()

        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            UIView.animate(withDuration: 0.6, animations: {
                confettiView.alpha = 0
            }, completion: { _ in
                confettiView.stopConfetti()
                confettiView.removeFromSuperview()
                completionHandler?()
            })
        }
    }

    /// Shows a confetti gun burst from a point, auto-dismissing after `duration` seconds.
    /// Particles shoot upward and arc down with gravity.
    public static func showConfetti(
        inView view: UIView,
        from source: CGPoint,
        type: ConfettiType = .confetti,
        duration: Double = 3,
        confettiBlocksUI: Bool = true,
        completionHandler: (() -> Void)? = nil
    ) {
        let confettiView = RSConfettiView(frame: view.bounds)
        confettiView.type = type
        confettiView.isUserInteractionEnabled = confettiBlocksUI
        view.addSubview(confettiView)
        confettiView.startConfetti(from: source)

        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            UIView.animate(withDuration: 0.6, animations: {
                confettiView.alpha = 0
            }, completion: { _ in
                confettiView.stopConfetti()
                confettiView.removeFromSuperview()
                completionHandler?()
            })
        }
    }

    /// Shows a confetti gun burst from a source view's center, auto-dismissing after `duration` seconds.
    public static func showConfetti(
        inView view: UIView,
        from sourceView: UIView,
        type: ConfettiType = .confetti,
        duration: Double = 3,
        confettiBlocksUI: Bool = true,
        completionHandler: (() -> Void)? = nil
    ) {
        let point = view.convert(sourceView.center, from: sourceView.superview)
        showConfetti(
            inView: view,
            from: point,
            type: type,
            duration: duration,
            confettiBlocksUI: confettiBlocksUI,
            completionHandler: completionHandler
        )
    }
}
