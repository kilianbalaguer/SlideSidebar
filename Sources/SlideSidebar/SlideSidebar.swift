//
//  SlideSidebar.swift
//  SlideSidebar
//
//  A swipe-driven slide-out sidebar for SwiftUI.
//  Created by Kilian Balaguer.
//

import SwiftUI

#if canImport(UIKit)

/// Configuration for ``SlideSidebar``.
public struct SlideSidebarConfig: Sendable {
    /// How wide the sidebar is, as a fraction of the total width. Default `0.8` (i.e. width / 1.25).
    public var widthRatio: CGFloat
    /// Duration of the open/close animation, in seconds.
    public var animationDuration: Double
    /// Fraction of travel past which a released drag snaps open. Default `0.25`.
    public var openThreshold: CGFloat
    /// Whether to play a haptic tap when the sidebar toggles. Default `true`.
    public var hapticsEnabled: Bool
    /// Whether a horizontal drag can *open* the sidebar from the closed state. Default `true`.
    /// Set `false` in apps with their own horizontal scrolling so the sidebar only opens via the
    /// `show` binding (e.g. a button); it can still be dragged closed once open.
    public var dragToOpen: Bool
    /// Whether to dim the content and let a tap on it close the sidebar while open. Default `true`.
    public var dimsContent: Bool

    public init(
        widthRatio: CGFloat = 0.8,
        animationDuration: Double = 0.25,
        openThreshold: CGFloat = 0.25,
        hapticsEnabled: Bool = true,
        dragToOpen: Bool = true,
        dimsContent: Bool = true
    ) {
        self.widthRatio = widthRatio
        self.animationDuration = animationDuration
        self.openThreshold = openThreshold
        self.hapticsEnabled = hapticsEnabled
        self.dragToOpen = dragToOpen
        self.dimsContent = dimsContent
    }

    public static let `default` = SlideSidebarConfig()
}

/// A container that slides `content` to the side to reveal a `sidebar` underneath,
/// driven by a horizontal drag gesture or by the bound `show` flag.
///
/// ```swift
/// @State private var showSidebar = false
///
/// SlideSidebar(show: $showSidebar) {
///     MyMenuView()            // the sidebar
/// } content: {
///     MyChatView()            // the main screen
/// }
/// ```
public struct SlideSidebar<SidebarContent: View, Content: View>: View {
    @Binding private var show: Bool
    private let config: SlideSidebarConfig
    private let sidebarView: SidebarContent
    private let detailView: Content

    @State private var offset: CGFloat = 0
    @State private var dragging = false
    @State private var startOffset: CGFloat = 0

    public init(
        show: Binding<Bool>,
        config: SlideSidebarConfig = .default,
        @ViewBuilder sidebar: () -> SidebarContent,
        @ViewBuilder content: () -> Content
    ) {
        self._show = show
        self.config = config
        self.sidebarView = sidebar()
        self.detailView = content()
    }

    /// Travel of the detail (content) panel to the right.
    private func detailOffset(_ width: CGFloat) -> CGFloat {
        let full = width * config.widthRatio
        return max(min(full, offset * full), 0)
    }

    /// Travel of the sidebar panel (eases in from the left).
    private func sidebarOffset(_ width: CGFloat) -> CGFloat {
        let full = width * config.widthRatio
        return min(-full * (1 - offset), 0)
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                sidebarView
                    .frame(width: geo.size.width * config.widthRatio)
                    .offset(x: sidebarOffset(geo.size.width))
                detailView
                    .frame(width: geo.size.width)
                    .overlay {
                        // Dim scrim over the content while open; a tap on it closes the sidebar.
                        if config.dimsContent && offset > 0.001 {
                            Color.black.opacity(0.28 * offset)
                                .ignoresSafeArea()
                                .contentShape(Rectangle())
                                .onTapGesture { show = false }
                                .allowsHitTesting(offset > 0.5)
                        }
                    }
                    .offset(x: detailOffset(geo.size.width))
            }
            .onChange(of: show) { _ in
                if config.hapticsEnabled {
                    #if os(iOS)
                    Haptic.shared.play(.rigid)
                    #endif
                }
                withAnimation(.easeOut(duration: config.animationDuration)) {
                    offset = show ? 1 : 0
                }
            }
            // The drag is fully disabled (mask `.subviews`) when closed and drag-to-open is off, so a
            // host app's own horizontal scrolling is never intercepted. Once open it is always active,
            // so the sidebar can be dragged closed.
            .gesture(dragGesture(width: geo.size.width),
                     including: (config.dragToOpen || offset > 0.001) ? .all : .subviews)
        }
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let translationX = value.translation.width
                if !dragging && abs(translationX) > 15 {
                    dragging = true
                    startOffset = offset
                }
                if dragging {
                    let newOffset = startOffset + (translationX / (width / 2.5))
                    offset = max(0, min(1, newOffset))
                }
            }
            .onEnded { _ in
                guard dragging else { return }
                dragging = false
                let shouldOpen = offset > config.openThreshold
                withAnimation(.easeOut(duration: config.animationDuration * 0.4)) {
                    offset = shouldOpen ? 1 : 0
                }
                show = shouldOpen
            }
    }
}
#endif
