//
//  OverlayWindowController.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import SwiftUI

@MainActor
class OverlayWindowController: NSWindowController {
    private let overlayWindowService = OverlayWindowService.shared
    
    convenience init() {
        // Get actual method count from ViewModel
        let viewModel = OverlayViewModel()
        let methodCount = viewModel.overlayMethods.count
        let initialSize = OverlayLayoutMetrics.windowSize(forMethodCount: methodCount)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: initialSize.width, height: initialSize.height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.isMovableByWindowBackground = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        
        let overlayView = OverlayView(frame: NSRect(x: 0, y: 0, width: initialSize.width, height: initialSize.height))
        window.contentView = overlayView
        
        self.init(window: window)
        
        positionWindow()
    }
    
    func positionWindow() {
        guard let window = window,
              let screen = NSScreen.main else { return }
        
        // Try to restore saved position
        if let savedPosition = overlayWindowService.getWindowPosition() {
            let savedOrigin = NSPoint(x: savedPosition.x, y: savedPosition.y)
            
            // Validate that the position is still visible on screen
            let screenFrame = screen.visibleFrame
            let windowFrame = window.frame
            let testFrame = NSRect(origin: savedOrigin, size: windowFrame.size)
            
            if screenFrame.intersects(testFrame) {
                window.setFrameOrigin(savedOrigin)
                return
            } else {
                print("Saved position is off screen, using default")
            }
        } else {
            print("No saved position found, using default")
        }
        
        // Default position: right side of screen
        let defaultPosition = overlayWindowService.calculateDefaultPosition(for: screen)
        window.setFrameOrigin(defaultPosition)
    }
    
    func saveWindowPosition() {
        guard let window = window else { return }
        let origin = window.frame.origin
        let position = WindowPosition(x: Double(origin.x), y: Double(origin.y))
        overlayWindowService.saveWindowPosition(position)
    }
    
    func updateSize(for methodCount: Int) {
        guard let window = window else { return }
        
        let newSize = OverlayLayoutMetrics.windowSize(forMethodCount: methodCount)
        var newOrigin = window.frame.origin
        if let screen = window.screen ?? NSScreen.main {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            let rightMargin: CGFloat = 10
            let x = screenFrame.maxX - newSize.width - rightMargin
            
            let dockHeight = visibleFrame.minY - screenFrame.minY
            let dockCenterY = screenFrame.minY + (dockHeight / 2)
            let desiredY = dockCenterY - (newSize.height / 2)
            let minY = screenFrame.minY + 5
            let maxY = screenFrame.maxY - newSize.height - 5
            let clampedY = min(max(desiredY, minY), maxY)
            newOrigin = NSPoint(x: x, y: clampedY)
        }
        
        window.setFrame(NSRect(origin: newOrigin, size: newSize), display: false)
        window.contentView?.setFrameSize(newSize)
        saveWindowPosition()
    }
    
    func show() {
        window?.orderFront(nil)
    }
    
    func hide() {
        window?.orderOut(nil)
    }
}
