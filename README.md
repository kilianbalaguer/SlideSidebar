# SlideSidebar

A swipe-driven slide-out sidebar for SwiftUI (iOS 16+). Drag from the edge, or
toggle a binding, to slide the main content aside and reveal a menu underneath.

Zero dependencies — the small UIKit haptics helper is bundled in.

## Install

### Local (same Mac)
In Xcode: **File → Add Package Dependencies… → Add Local…** and pick the
`SlideSidebar` folder.

### From GitHub
**File → Add Package Dependencies…** and paste the repo URL.

## Usage

```swift
import SwiftUI
import SlideSidebar

struct RootView: View {
    @State private var showSidebar = false

    var body: some View {
        SlideSidebar(show: $showSidebar) {
            // Sidebar / menu
            MyMenuView()
        } content: {
            // Main screen
            MyMainView(onMenuTap: { showSidebar.toggle() })
        }
    }
}
```

## Configuration

```swift
SlideSidebar(
    show: $showSidebar,
    config: SlideSidebarConfig(
        widthRatio: 0.8,        // sidebar width as a fraction of screen width
        animationDuration: 0.25,
        openThreshold: 0.25,    // how far a drag must travel to snap open
        hapticsEnabled: true
    )
) {
    MyMenuView()
} content: {
    MyMainView()
}
```

## License

Apache License 2.0 — © 2026 Kilian Balaguer. See [LICENSE](LICENSE).
