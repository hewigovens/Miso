//
//  AppDelegate.swift
//  Miso
//
//  Created by hewig on 7/24/25.
//

import AppKit
import IOKit.hid
import ServiceManagement

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var appViewModel: AppViewModel!
    private var overlayWindowController: OverlayWindowController?
    private var preferencesWindowController: PreferencesWindowController?
    private var statusItem: NSStatusItem?
    private lazy var preferencesService = PreferencesService.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force UIElement mode (background app) even when running from Xcode
        NSApp.setActivationPolicy(.accessory)

        appViewModel = AppViewModel()
        appViewModel.requestPermissions()

        setupStatusBarItem()
        setupOverlayWindow()
        
        // Listen for preference changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleToggleOverlayPreferenceChanged),
            name: NSNotification.Name("ToggleOverlayPreferenceChanged"),
            object: nil
        )
    }
    
    @objc private func handleToggleOverlayPreferenceChanged() {
        // Update status bar behavior when preference changes
        setupStatusBarItem()
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(named: "menubar-icon")
            button.image?.isTemplate = true
            button.target = self
            
            // Check if we should toggle overlay on click
            if preferencesService.getToggleOverlayOnMenuClick() {
                // Set action for left click to toggle overlay
                button.action = #selector(statusBarButtonClicked(_:))
                button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            } else {
                // Standard menu behavior - menu shows on left click
                button.action = #selector(toggleOverlay)
                statusItem?.menu = createStatusMenu()
            }
        }
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton?) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Show menu on right click
            showStatusMenu()
        } else if event.type == .leftMouseUp {
            // Toggle overlay on left click
            toggleOverlay()
        }
    }
    
    private func showStatusMenu() {
        guard let button = statusItem?.button else { return }
        
        let menu = createStatusMenu()
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 5), in: button)
    }
    
    private func createStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show/Hide Overlay", action: #selector(toggleOverlay), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Miso", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }
    

    private func setupOverlayWindow() {
        overlayWindowController = OverlayWindowController()
        overlayWindowController?.show()
    }

    @objc func toggleOverlay() {
        guard let overlayWindowController else { return }
        
        overlayWindowController.toggleVisibility()
        appViewModel.toggleOverlay()
    }

    @objc func showPreferences() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Create or show preferences window
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }

        preferencesWindowController?.showWindow(nil)
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlayWindowController?.saveWindowPosition()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showPreferences()
        }
        return true
    }
}
