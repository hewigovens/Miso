//
//  OverlayWindowService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import Foundation

protocol OverlayWindowServiceProtocol {
    func saveWindowPosition(_ position: WindowPosition)
    func getWindowPosition() -> WindowPosition?
    func calculateDefaultPosition(for screen: NSScreen) -> NSPoint
}

class OverlayWindowService: OverlayWindowServiceProtocol {
    static let shared = OverlayWindowService()
    
    private let preferencesService: PreferencesServiceProtocol
    
    init(preferencesService: PreferencesServiceProtocol = PreferencesService.shared) {
        self.preferencesService = preferencesService
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
        let methodCount = max(viewModel.configuredMethods.count, 3)
        let buttonSize: CGFloat = 36
        let spacing: CGFloat = 4
        let padding: CGFloat = 8
        
        let windowWidth = CGFloat(methodCount) * buttonSize + CGFloat(methodCount - 1) * spacing + 2 * padding + 20
        let windowHeight = buttonSize + 2 * padding + 20
        
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
