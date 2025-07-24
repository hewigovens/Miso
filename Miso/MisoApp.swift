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
        app.run()
    }
}
