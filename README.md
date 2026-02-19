# RSConfettiView

A Swift UIView with animated confetti to present success states. Supports both UIKit and SwiftUI.

<img src="https://i.imgur.com/BgFMEvz.png" width="250">

## Requirements

- iOS 15.0+
- Swift 6.1+

## Installation

- Swift Package Manager (SPM) - `https://github.com/RanduSoft/RSConfettiView`
- Copy the files from `Sources/` into your project

## Usage

### UIKit - One time use

```swift
import RSConfettiView

func showConfetti() {
    RSConfettiView.showConfetti(inView: self.view, type: .confetti, duration: 5) {
        // completion handler
    }
}
```

### UIKit - Storyboard / Programmatic

```swift
import RSConfettiView

@IBOutlet private weak var confettiView: RSConfettiView!

func showConfetti() {
    confettiView.type = .confetti
    confettiView.startConfetti()
}

func hideConfetti() {
    confettiView.stopConfetti()
}

var confettiIsRunning: Bool {
    return confettiView.isActive
}
```

### SwiftUI - ConfettiView

```swift
import RSConfettiView

struct ContentView: View {
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            Button("Celebrate") {
                showConfetti = true
            }

            ConfettiView(isActive: $showConfetti)
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
    }
}
```

### SwiftUI - View Modifier

```swift
import RSConfettiView

struct ContentView: View {
    @State private var showConfetti = false

    var body: some View {
        VStack {
            Button("Celebrate") {
                showConfetti = true
            }
        }
        .confetti(isActive: $showConfetti, duration: 5)
    }
}
```

When a `duration` is provided, confetti automatically stops after the given number of seconds.

### Confetti Gun (from a point)

Spawn confetti from a specific point or view, like a confetti cannon. Particles burst upward and arc down with gravity.

**UIKit:**

```swift
// From a specific point
RSConfettiView.showConfetti(inView: self.view, from: CGPoint(x: 200, y: 600))

// From a button or any view
RSConfettiView.showConfetti(inView: self.view, from: celebrateButton)

// Programmatic mode
confettiView.startConfetti(from: CGPoint(x: 160, y: 400))
```

**SwiftUI:**

```swift
// source uses UnitPoint (0...1 relative coordinates)
.confetti(isActive: $showConfetti, source: UnitPoint(x: 0.5, y: 0.9), duration: 3)

// Bottom-center shorthand
.confetti(isActive: $showConfetti, source: .bottom, duration: 3)
```

## Customization

### Particle Type

Use `.confetti` for the default particle or `.image(UIImage)` for a custom image:

```swift
// Default confetti particle
confettiView.type = .confetti

// Custom image
confettiView.type = .image(UIImage(named: "star")!)
```

### Colors

Override the default particle colors:

```swift
confettiView.colors = [.red, .blue, .green]
```

### Configuration

Fine-tune individual particle physics parameters using `RSConfettiView.Configuration`:

```swift
let config = RSConfettiView.Configuration(
    birthRate: 10,
    lifetime: 10,
    velocity: 400,
    spin: 5
)
confettiView.configuration = config
confettiView.startConfetti()
```

All `Configuration` parameters and their defaults:

| Parameter       | Default | Description                    |
|-----------------|---------|--------------------------------|
| `birthRate`     | `8.5`   | Particles emitted per second   |
| `lifetime`      | `14.0`  | Particle lifetime in seconds   |
| `velocity`      | `350.0` | Initial particle velocity      |
| `velocityRange` | `80.0`  | Velocity variation             |
| `spin`          | `3.5`   | Particle rotation speed        |
| `spinRange`     | `4.0`   | Rotation speed variation       |
| `scaleRange`    | `1.0`   | Particle size variation        |
| `scaleSpeed`    | `-0.1`  | Scale change over time         |

## Migration from v1.x

- `isActive()` is now a property: replace `confettiView.isActive()` with `confettiView.isActive`
- `completitionHandler` parameter has been renamed to `completionHandler` (typo fix)
- `intensity` property has been removed (hardcoded to maximum)
- `colors` and `type` are now `public`
- Minimum deployment target raised from iOS 9 to iOS 15

## License

RSConfettiView is available under the **MPL-2.0 license**. See the [LICENSE](https://github.com/rursache/RSConfettiView/blob/master/LICENSE) file for more info.
