//
//  OverlayView.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import Combine

class OverlayView: NSView {
    private let viewModel = OverlayViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var isExpanded = true
    private var isMouseDown = false
    private var dragOffset = NSPoint.zero

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupBindings()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    private func setupBindings() {
        viewModel.$currentInputMethodID
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.needsDisplay = true
                }
            }
            .store(in: &cancellables)

        viewModel.$configuredMethods
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.needsDisplay = true
                }
            }
            .store(in: &cancellables)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        if isExpanded {
            drawExpandedView(ctx: ctx)
        } else {
            drawCollapsedView(ctx: ctx)
        }
    }

    private func drawCollapsedView(ctx: CGContext) {
        let rect = bounds
        let buttonRect = NSRect(x: (rect.width - 40) / 2, y: (rect.height - 40) / 2, width: 40, height: 40)

        // Draw shadow for HUD effect
        ctx.setShadow(offset: CGSize(width: 0, height: -2), blur: 10, color: NSColor.black.withAlphaComponent(0.4).cgColor)

        // Draw dark HUD background
        ctx.setFillColor(NSColor.black.withAlphaComponent(0.8).cgColor)
        ctx.fillEllipse(in: buttonRect)

        // Reset shadow
        ctx.setShadow(offset: .zero, blur: 0, color: nil)

        // Get current method
        let currentMethod = viewModel.currentMethod

        // Draw flag emoji only (centered and larger)
        let flag = currentMethod?.flag ?? "🌐"
        let flagRect = NSRect(x: buttonRect.midX - 12, y: buttonRect.midY - 10, width: 24, height: 20)
        flag.draw(in: flagRect, withAttributes: [
            .font: NSFont.systemFont(ofSize: 18),
            .foregroundColor: NSColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ])
    }

    private func drawExpandedView(ctx: CGContext) {
        let methods = viewModel.configuredMethods
        let buttonSize: CGFloat = 36 // Smaller buttons since no text
        let spacing: CGFloat = 4
        let padding: CGFloat = 8

        let totalWidth = CGFloat(methods.count) * buttonSize + CGFloat(methods.count - 1) * spacing + 2 * padding
        let totalHeight = buttonSize + 2 * padding

        let backgroundRect = NSRect(
            x: (bounds.width - totalWidth) / 2,
            y: (bounds.height - totalHeight) / 2,
            width: totalWidth,
            height: totalHeight
        )

        // Draw shadow for HUD effect
        ctx.setShadow(offset: CGSize(width: 0, height: -2), blur: 12, color: NSColor.black.withAlphaComponent(0.4).cgColor)

        // Draw dark HUD background
        ctx.setFillColor(NSColor.black.withAlphaComponent(0.8).cgColor)
        ctx.fill(backgroundRect, withRadius: 16)

        // Reset shadow
        ctx.setShadow(offset: .zero, blur: 0, color: nil)

        // Draw method buttons
        var x = backgroundRect.minX + padding
        let y = backgroundRect.minY + padding

        for method in methods {
            let buttonRect = NSRect(x: x, y: y, width: buttonSize, height: buttonSize)
            let isActive = method.id == viewModel.currentInputMethodID

            // Draw button background with HUD styling
            if isActive {
                // Active button: bright accent with glow effect
                ctx.setShadow(offset: .zero, blur: 6, color: NSColor.controlAccentColor.withAlphaComponent(0.6).cgColor)
                ctx.setFillColor(NSColor.controlAccentColor.withAlphaComponent(0.8).cgColor)
                ctx.fill(buttonRect, withRadius: 8)
                ctx.setShadow(offset: .zero, blur: 0, color: nil)

                // Bright border
                ctx.setStrokeColor(NSColor.controlAccentColor.cgColor)
                ctx.setLineWidth(2)
                ctx.stroke(buttonRect.insetBy(dx: 1, dy: 1), withRadius: 8)
            } else {
                // Inactive button: subtle dark background
                ctx.setFillColor(NSColor.white.withAlphaComponent(0.1).cgColor)
                ctx.fill(buttonRect, withRadius: 8)
            }

            // Draw flag icon only (centered and larger)
            let flagRect = NSRect(x: buttonRect.midX - 12, y: buttonRect.midY - 10, width: 24, height: 20)
            method.flag.draw(in: flagRect, withAttributes: [
                .font: NSFont.systemFont(ofSize: 20),
                .foregroundColor: NSColor.white,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ])

            x += buttonSize + spacing
        }
    }

    override func mouseDown(with event: NSEvent) {
        isMouseDown = true
        let location = convert(event.locationInWindow, from: nil)
        dragOffset = location
    }

    override func mouseDragged(with event: NSEvent) {
        guard isMouseDown else { return }

        let currentLocation = convert(event.locationInWindow, from: nil)
        let deltaX = currentLocation.x - dragOffset.x
        let deltaY = currentLocation.y - dragOffset.y

        // If we've moved more than a threshold, start dragging
        if abs(deltaX) > 3 || abs(deltaY) > 3 {
            if let window = window {
                let currentOrigin = window.frame.origin
                let newOrigin = NSPoint(
                    x: currentOrigin.x + deltaX,
                    y: currentOrigin.y + deltaY
                )
                window.setFrameOrigin(newOrigin)

                // Save position continuously during drag for better persistence
                if let windowController = window.windowController as? OverlayWindowController {
                    windowController.saveWindowPosition()
                }
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        defer { isMouseDown = false }

        let location = convert(event.locationInWindow, from: nil)
        let deltaX = location.x - dragOffset.x
        let deltaY = location.y - dragOffset.y

        // If we didn't drag much, treat as a click
        if abs(deltaX) < 3, abs(deltaY) < 3 {
            handleClick(at: location)
        } else {
            // If we dragged, save the new window position
            if let windowController = window?.windowController as? OverlayWindowController {
                windowController.saveWindowPosition()
            }
        }
    }

    private func handleClick(at location: NSPoint) {
        // Check if clicked on a method button
        let methods = viewModel.configuredMethods
        let buttonSize: CGFloat = 36 // Match the drawing size
        let spacing: CGFloat = 4
        let padding: CGFloat = 8

        let totalWidth = CGFloat(methods.count) * buttonSize + CGFloat(methods.count - 1) * spacing + 2 * padding
        let totalHeight = buttonSize + 2 * padding

        let backgroundRect = NSRect(
            x: (bounds.width - totalWidth) / 2,
            y: (bounds.height - totalHeight) / 2,
            width: totalWidth,
            height: totalHeight
        )

        var x = backgroundRect.minX + padding
        let y = backgroundRect.minY + padding

        for method in methods {
            let buttonRect = NSRect(x: x, y: y, width: buttonSize, height: buttonSize)
            if buttonRect.contains(location) {
                viewModel.switchToInputMethod(method)
                return
            }
            x += buttonSize + spacing
        }
    }
}

// Helper extensions
extension CGContext {
    func fill(_ rect: NSRect, withRadius radius: CGFloat) {
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        addPath(path.cgPath)
        fillPath()
    }

    func stroke(_ rect: NSRect, withRadius radius: CGFloat) {
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        addPath(path.cgPath)
        strokePath()
    }
}

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .cubicCurveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .quadraticCurveTo:
                path.addQuadCurve(to: points[1], control: points[0])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }

        return path
    }
}
