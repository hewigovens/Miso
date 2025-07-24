//
//  OverlayWindowService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation
import AppKit

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
        print(position)
        preferencesService.saveWindowPosition(position)
    }
    
    func getWindowPosition() -> WindowPosition? {
        return preferencesService.getWindowPosition()
    }
    
    func calculateDefaultPosition(for screen: NSScreen) -> NSPoint {
        let screenFrame = screen.frame // Use full screen frame, not visibleFrame
        let visibleFrame = screen.visibleFrame
        
        let windowWidth: CGFloat = 200 // Approximate window width
        let windowHeight: CGFloat = 60 // Approximate window height
        
        // Calculate dock height (difference between screen and visible frame)
        let dockHeight = screenFrame.maxY - visibleFrame.maxY
        
        // Position at bottom right, aligned with dock
        let margin: CGFloat = 20
        let x = screenFrame.maxX - windowWidth - margin
        let y = screenFrame.minY + dockHeight + margin // Just above the dock
        
        return NSPoint(x: x, y: y)
    }
}
