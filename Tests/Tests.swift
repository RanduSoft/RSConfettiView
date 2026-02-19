import Testing
import UIKit
@testable import RSConfettiView

@MainActor
@Suite("RSConfettiView")
struct RSConfettiViewTests {

    @Test("Default initialization values")
    func defaultInit() {
        let view = RSConfettiView(frame: .zero)
        #expect(!view.isActive)
        #expect(view.colors.count == 7)
    }

    @Test("Start sets isActive to true")
    func startSetsActive() {
        let view = RSConfettiView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.startConfetti()
        #expect(view.isActive)
    }

    @Test("Stop sets isActive to false")
    func stopSetsInactive() {
        let view = RSConfettiView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.startConfetti()
        view.stopConfetti()
        #expect(!view.isActive)
    }

    @Test("Repeated startConfetti does not stack emitter layers")
    func noLayerStacking() {
        let view = RSConfettiView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.startConfetti()
        view.startConfetti()
        view.startConfetti()

        let emitterLayers = view.layer.sublayers?.filter { $0 is CAEmitterLayer } ?? []
        #expect(emitterLayers.count == 1)
    }

    @Test("Custom colors are applied")
    func customColors() {
        let view = RSConfettiView(frame: .zero)
        let customColors: [UIColor] = [.red, .blue]
        view.colors = customColors
        #expect(view.colors.count == 2)
    }

    @Test("Custom type is applied")
    func customType() {
        let view = RSConfettiView(frame: .zero)
        view.type = .confetti

        let image = UIImage()
        view.type = .image(image)

        if case .image = view.type {
            // pass
        } else {
            Issue.record("Expected .image type")
        }
    }

    @Test("Default configuration values")
    func defaultConfiguration() {
        let config = RSConfettiView.Configuration.default
        #expect(config.birthRate == 8.5)
        #expect(config.lifetime == 14.0)
        #expect(config.velocity == 350.0)
        #expect(config.velocityRange == 80.0)
        #expect(config.spin == 3.5)
        #expect(config.spinRange == 4.0)
        #expect(config.scaleRange == 1.0)
        #expect(config.scaleSpeed == -0.1)
    }

    @Test("Custom configuration preserves defaults for unset values")
    func customConfiguration() {
        let config = RSConfettiView.Configuration(birthRate: 10, lifetime: 20)
        #expect(config.birthRate == 10)
        #expect(config.lifetime == 20)
        #expect(config.velocity == 350.0)
    }

    @Test("Stop without start does not crash")
    func stopWithoutStart() {
        let view = RSConfettiView(frame: .zero)
        view.stopConfetti()
        #expect(!view.isActive)
    }

    @Test("layoutSubviews updates emitter position")
    func layoutUpdatesEmitter() {
        let view = RSConfettiView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.startConfetti()

        view.frame = CGRect(x: 0, y: 0, width: 640, height: 960)
        view.layoutSubviews()

        let emitter = view.layer.sublayers?.first(where: { $0 is CAEmitterLayer }) as? CAEmitterLayer
        #expect(emitter?.emitterPosition.x == 320)
        #expect(emitter?.emitterSize.width == 640)
    }

    @Test("Start from point uses point emitter")
    func startFromPoint() {
        let view = RSConfettiView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let source = CGPoint(x: 160, y: 400)
        view.startConfetti(from: source)

        #expect(view.isActive)
        let emitter = view.layer.sublayers?.first(where: { $0 is CAEmitterLayer }) as? CAEmitterLayer
        #expect(emitter?.emitterPosition == source)
        #expect(emitter?.emitterShape == .point)
    }

    @Test("Start from point does not stack with line mode")
    func pointAndLineNoStacking() {
        let view = RSConfettiView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.startConfetti()
        view.startConfetti(from: CGPoint(x: 100, y: 200))

        let emitterLayers = view.layer.sublayers?.filter { $0 is CAEmitterLayer } ?? []
        #expect(emitterLayers.count == 1)
    }
}
