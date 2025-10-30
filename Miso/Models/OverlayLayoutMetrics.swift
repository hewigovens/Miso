//
//  OverlayLayoutMetrics.swift
//  Miso
//
//  Created by hewig on 7/25/25.
//

import AppKit

enum OverlayLayoutMetrics {
    static let minMethodCount = 2
    static let maxMethodCount = 5

    static let buttonSize: CGFloat = 36
    static let spacing: CGFloat = 4
    static let padding: CGFloat = 8
    static let windowExtraWidth: CGFloat = 20
    static let windowExtraHeight: CGFloat = 20

    static func clampedMethodCount(_ count: Int) -> Int {
        let upperBound = min(count, maxMethodCount)
        return max(upperBound, minMethodCount)
    }

    static func windowSize(forMethodCount count: Int) -> NSSize {
        let methodCount = clampedMethodCount(max(count, 1))
        let contentWidth = contentWidth(forMethodCount: methodCount)
        let width = contentWidth + windowExtraWidth
        let height = buttonSize + (padding * 2) + windowExtraHeight
        return NSSize(width: width, height: height)
    }

    static func contentWidth(forMethodCount count: Int) -> CGFloat {
        let methodCount = max(min(count, maxMethodCount), 1)
        let totalButtonWidth = CGFloat(methodCount) * buttonSize
        let totalSpacing = CGFloat(max(methodCount - 1, 0)) * spacing
        return totalButtonWidth + totalSpacing + (padding * 2)
    }
}
