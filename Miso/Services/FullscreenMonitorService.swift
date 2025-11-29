//
//  FullscreenMonitorService.swift
//  Miso
//
//  Created by hewig on 3/2/24.
//

import AppKit
import CoreGraphics
import Foundation

@MainActor
protocol FullscreenMonitorServiceProtocol: AnyObject {
    func startMonitoring(_ handler: @escaping @MainActor (Bool) -> Void)
    func stopMonitoring()
}

@MainActor
final class FullscreenMonitorService: FullscreenMonitorServiceProtocol {
    static let shared = FullscreenMonitorService()
    
    private var activeSpaceObserver: NSObjectProtocol?
    private var activationObserver: NSObjectProtocol?
    private var handler: (@MainActor (Bool) -> Void)?
    
    func startMonitoring(_ handler: @escaping @MainActor (Bool) -> Void) {
        stopMonitoring()
        self.handler = handler
        
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        activeSpaceObserver = workspaceCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.notifyChange()
            }
        }
        
        activationObserver = workspaceCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.notifyChange()
            }
        }
        
        Task { @MainActor in
            self.notifyChange()
        }
    }
    
    func stopMonitoring() {
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        if let activeSpaceObserver {
            workspaceCenter.removeObserver(activeSpaceObserver)
            self.activeSpaceObserver = nil
        }
        if let activationObserver {
            workspaceCenter.removeObserver(activationObserver)
            self.activationObserver = nil
        }
        handler = nil
    }
}

@MainActor
private extension FullscreenMonitorService {
    func notifyChange() {
        let isFullscreen = isFrontmostAppFullscreen()
        Task { @MainActor in
            self.handler?(isFullscreen)
        }
    }
    
    func isFrontmostAppFullscreen() -> Bool {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return false }
        
        let options: CGWindowListOption = [.excludeDesktopElements, .optionOnScreenOnly]
        guard let windowInfoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return false
        }
        
        let screens = NSScreen.screens
        let tolerance: CGFloat = 2
        
        for info in windowInfoList {
            guard
                let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t,
                ownerPID == frontmostApp.processIdentifier,
                let boundsDict = info[kCGWindowBounds as String] as? [String: CGFloat],
                let layer = info[kCGWindowLayer as String] as? Int,
                layer == 0
            else {
                continue
            }
            
            let windowSize = CGSize(
                width: boundsDict["Width"] ?? 0,
                height: boundsDict["Height"] ?? 0
            )
            
            for screen in screens {
                let pointSize = screen.frame.size
                let pixelSize = CGSize(
                    width: pointSize.width * screen.backingScaleFactor,
                    height: pointSize.height * screen.backingScaleFactor
                )
                
                // Fullscreen windows match the display size in either points or pixels (Retina)
                if windowSize.isNearlyEqual(to: pointSize, tolerance: tolerance) ||
                    windowSize.isNearlyEqual(to: pixelSize, tolerance: tolerance) {
                    return true
                }
            }
        }
        
        return false
    }
}

private extension CGSize {
    func isNearlyEqual(to other: CGSize, tolerance: CGFloat) -> Bool {
        abs(width - other.width) <= tolerance && abs(height - other.height) <= tolerance
    }
}
