//
//  PermissionService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import Foundation
import IOKit.hid

@MainActor
protocol PermissionServiceProtocol {
    func requestInputMonitoringPermission()
    func checkInputMonitoringPermission() -> Bool
    func openInputMonitoringPreferences()
    func addToInputMonitoringPreferences()
}

@MainActor
class PermissionService: PermissionServiceProtocol {
    static let shared = PermissionService()

    private init() {}

    func addToInputMonitoringPreferences() {
        // This will add the app to the Input Monitoring list (initially disabled)
        if #available(macOS 10.15, *) {
            // Create a temporary HID manager to trigger the permission request
            let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
            IOHIDManagerSetDeviceMatching(manager, nil)
            IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
            
            if result == kIOReturnSuccess {
                // Clean up
                IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
                IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            }
        }
    }

    func requestInputMonitoringPermission() {
        if #available(macOS 10.15, *) {
            let trust = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)

            if trust != kIOHIDAccessTypeGranted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showInputMonitoringPermissionAlert()
                }
            }
        }
    }

    func checkInputMonitoringPermission() -> Bool {
        if #available(macOS 10.15, *) {
            return IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
        }
        return true
    }

    private func showInputMonitoringPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Input Monitoring Permission Required"
        alert.informativeText = "Miso needs input monitoring permissions to detect keyboard shortcuts globally.\n\nClick \"Grant Permission\" to add Miso to the input monitoring list and open System Preferences where you can enable it."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Grant Permission")
        alert.addButton(withTitle: "Skip")

        if alert.runModal() == .alertFirstButtonReturn {
            self.addToInputMonitoringPreferences()
            self.openInputMonitoringPreferences()
        }
    }

    func openInputMonitoringPreferences() {
        let inputMonitoringURLs = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent",
            "x-apple.systempreferences:com.apple.Settings.PrivacySecurity.Privacy.InputMonitoring",
            "x-apple.systempreferences:com.apple.preference.security"
        ]
        
        for urlString in inputMonitoringURLs {
            if let url = URL(string: urlString), NSWorkspace.shared.open(url) {
                return
            }
        }
    }
}
