//
//  PreferencesWindowController.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import SwiftUI

@MainActor
class PreferencesWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Miso Preferences"
        window.center()
        window.isReleasedWhenClosed = false
        
        self.init(window: window)
        window.delegate = self
        
        let preferencesView = PreferencesView()
        let hostingView = NSHostingView(rootView: preferencesView)
        window.contentView = hostingView
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Ensure delegate is set
        window?.delegate = self
    }
}

extension PreferencesWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}
