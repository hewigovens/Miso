//
//  AppDelegate.swift
//  Miso
//
//  Created by hewig on 7/24/25.
//

import AppKit
import IOKit.hid
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var appViewModel: AppViewModel!
    private var overlayWindowController: OverlayWindowController?
    private var preferencesWindowController: PreferencesWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force UIElement mode (background app) even when running from Xcode
        NSApp.setActivationPolicy(.accessory)

        appViewModel = AppViewModel()
        appViewModel.requestPermissions()

        setupStatusBarItem()
        setupOverlayWindow()
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "m.square.fill", accessibilityDescription: "Miso")
            button.action = #selector(toggleOverlay)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show/Hide Overlay", action: #selector(toggleOverlay), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit MISO", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    private func setupOverlayWindow() {
        overlayWindowController = OverlayWindowController()
        overlayWindowController?.show()
    }

    @objc func toggleOverlay() {
        if let window = overlayWindowController?.window {
            if window.isVisible {
                overlayWindowController?.hide()
            } else {
                overlayWindowController?.show()
            }
            appViewModel.toggleOverlay()
        }
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
