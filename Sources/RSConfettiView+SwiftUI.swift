//
//  RSConfettiView+SwiftUI
//
//  Created by Radu Ursache.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import SwiftUI

// MARK: - SwiftUI UIViewRepresentable

public struct ConfettiView: UIViewRepresentable {

    @Binding public var isActive: Bool

    public var type: RSConfettiView.ConfettiType
    public var colors: [UIColor]?
    public var configuration: RSConfettiView.Configuration
    public var source: UnitPoint?

    public init(
        isActive: Binding<Bool>,
        type: RSConfettiView.ConfettiType = .confetti,
        colors: [UIColor]? = nil,
        configuration: RSConfettiView.Configuration = .default,
        source: UnitPoint? = nil
    ) {
        self._isActive = isActive
        self.type = type
        self.colors = colors
        self.configuration = configuration
        self.source = source
    }

    public func makeUIView(context: Context) -> RSConfettiView {
        let view = RSConfettiView(frame: .zero)
        view.type = type
        view.configuration = configuration
        if let colors { view.colors = colors }
        return view
    }

    public func updateUIView(_ uiView: RSConfettiView, context: Context) {
        uiView.type = type
        uiView.configuration = configuration
        if let colors { uiView.colors = colors }

        if isActive && !uiView.isActive {
            if let source {
                let point = CGPoint(
                    x: uiView.bounds.width * source.x,
                    y: uiView.bounds.height * source.y
                )
                uiView.startConfetti(from: point)
            } else {
                uiView.startConfetti()
            }
        } else if !isActive && uiView.isActive {
            uiView.stopConfetti()
        }
    }
}

// MARK: - View Modifier

public struct ConfettiModifier: ViewModifier {

    @Binding var isActive: Bool

    let type: RSConfettiView.ConfettiType
    let colors: [UIColor]?
    let configuration: RSConfettiView.Configuration
    let source: UnitPoint?
    let duration: Double?

    public func body(content: Content) -> some View {
        content
            .overlay(
                ConfettiView(
                    isActive: $isActive,
                    type: type,
                    colors: colors,
                    configuration: configuration,
                    source: source
                )
                .allowsHitTesting(false)
                .ignoresSafeArea()
            )
            .task(id: isActive) {
                if isActive, let duration {
                    try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                    if !Task.isCancelled {
                        isActive = false
                    }
                }
            }
    }
}

// MARK: - View Extension

extension View {

    /// Overlays animated confetti on this view.
    ///
    /// - Parameters:
    ///   - isActive: Binding that controls whether confetti is emitting.
    ///   - type: The confetti particle type (`.confetti` or `.image(UIImage)`).
    ///   - colors: Optional custom particle colors. Uses defaults when `nil`.
    ///   - configuration: Particle physics configuration. Uses `.default` when omitted.
    ///   - source: Optional origin point as a `UnitPoint`. When set, confetti shoots from
    ///     that point like a confetti gun. When `nil`, confetti rains from the top.
    ///   - duration: Optional auto-dismiss duration in seconds. When set, `isActive` is
    ///     automatically set back to `false` after the given duration.
    public func confetti(
        isActive: Binding<Bool>,
        type: RSConfettiView.ConfettiType = .confetti,
        colors: [UIColor]? = nil,
        configuration: RSConfettiView.Configuration = .default,
        source: UnitPoint? = nil,
        duration: Double? = nil
    ) -> some View {
        modifier(ConfettiModifier(
            isActive: isActive,
            type: type,
            colors: colors,
            configuration: configuration,
            source: source,
            duration: duration
        ))
    }
}
