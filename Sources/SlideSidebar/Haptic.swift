//
//  Haptic.swift
//  SlideSidebar
//
//  Created by Kilian Balaguer.
//  Lightweight UIKit haptics wrapper, bundled so the package has no dependencies.
//

import Foundation
#if os(iOS)
import UIKit

/// Wrapper around UIKit haptics.
@MainActor
final class Haptic {
    static let shared = Haptic()
    private init() {}

    /// Play impact haptic feedback.
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred(intensity: intensity)
    }

    /// Provide notification feedback for an action.
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }

    /// Play feedback for a selection change.
    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
#endif
