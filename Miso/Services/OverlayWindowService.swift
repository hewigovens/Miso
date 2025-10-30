//
//  OverlayWindowService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import Foundation

@MainActor
protocol OverlayWindowServiceProtocol {
    func saveWindowPosition(_ position: WindowPosition)
    func getWindowPosition() -> WindowPosition?
    func calculateDefaultPosition(for screen: NSScreen) -> NSPoint
}

@MainActor
class OverlayWindowService: OverlayWindowServiceProtocol {
    static let shared = OverlayWindowService()
    
    private let preferencesService: PreferencesServiceProtocol
    
    init(preferencesService: PreferencesServiceProtocol? = nil) {
        self.preferencesService = preferencesService ?? PreferencesService.shared
    }
    
    func saveWindowPosition(_ position: WindowPosition) {
        preferencesService.saveWindowPosition(position)
    }
    
    func getWindowPosition() -> WindowPosition? {
        return preferencesService.getWindowPosition()
    }
    
    func calculateDefaultPosition(for screen: NSScreen) -> NSPoint {
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        
        // Calculate actual window size based on number of input methods
        let viewModel = OverlayViewModel()
        let methodCount = viewModel.overlayMethods.count
        let windowSize = OverlayLayoutMetrics.windowSize(forMethodCount: methodCount)
        
        let windowWidth = windowSize.width
        let windowHeight = windowSize.height
        
        // Calculate dock height (dock is at the bottom in macOS coordinates)
        let dockHeight = visibleFrame.minY - screenFrame.minY
        
        // Position at bottom right
        let rightMargin: CGFloat = 10
        let x = screenFrame.maxX - windowWidth - rightMargin
        
        // Position window to be centered with the dock vertically
        // The dock occupies the space from screenFrame.minY to visibleFrame.minY
        let dockCenterY = screenFrame.minY + (dockHeight / 2)
        let y = dockCenterY - (windowHeight / 2)
        
        // Ensure the window is fully visible (not below screen bottom)
        let finalY = max(y, screenFrame.minY + 5)
        
        return NSPoint(x: x, y: finalY)
    }
}
