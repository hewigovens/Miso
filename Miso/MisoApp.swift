//
//  MisoApp.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit

@main
class MisoApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        
        // Set up the main menu
        setupMainMenu()
        
        app.run()
    }
    
    static func setupMainMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu
        
        // App Menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(NSMenuItem(title: "About MISO", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.showPreferences), keyEquivalent: ","))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "Quit MISO", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // Help Menu
        let helpMenuItem = NSMenuItem()
        helpMenuItem.title = "Help"
        mainMenu.addItem(helpMenuItem)
        
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu
        NSApp.helpMenu = helpMenu
        
        helpMenu.addItem(NSMenuItem(title: "MISO Help", action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "?"))
    }
}
