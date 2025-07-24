//
//  OverlayWindowController.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import SwiftUI

class OverlayWindowController: NSWindowController {
    private let overlayWindowService = OverlayWindowService.shared
    
    convenience init() {
        // Get actual method count from ViewModel
        let viewModel = OverlayViewModel()
        let methodCount = max(viewModel.configuredMethods.count, 3) // minimum 3 for layout
        
        // Calculate initial size for expanded view (HUD style with smaller buttons)
        let buttonSize: CGFloat = 36
        let spacing: CGFloat = 4
        let padding: CGFloat = 8
        
        let totalWidth = CGFloat(methodCount) * buttonSize + CGFloat(methodCount - 1) * spacing + 2 * padding + 20
        let totalHeight = buttonSize + 2 * padding + 20
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: totalWidth, height: totalHeight),
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
        
        let overlayView = OverlayView(frame: NSRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
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
                print("Restoring window to saved position: \(savedOrigin)")
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
    
    func show() {
        window?.orderFront(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hide() {
        window?.orderOut(nil)
    }
}
