//
//  PreferencesService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation

@MainActor
protocol PreferencesServiceProtocol {
    func getConfiguredMethods() -> [InputMethod]
    func saveConfiguredMethods(_ methods: [InputMethod])
    func getWindowPosition() -> WindowPosition?
    func saveWindowPosition(_ position: WindowPosition)
    func isFirstLaunch() -> Bool
    func setHasLaunched()
    func getToggleOverlayOnMenuClick() -> Bool
    func setToggleOverlayOnMenuClick(_ enabled: Bool)
}

@MainActor
class PreferencesService: PreferencesServiceProtocol {
    static let shared = PreferencesService()
    
    private let configuredMethodsKey = "ConfiguredInputMethods"
    private let windowPositionKey = "OverlayWindowPosition"
    private let hasLaunchedKey = "HasLaunchedBefore"
    private let toggleOverlayOnMenuClickKey = "ToggleOverlayOnMenuClick"
    
    private init() {}
    
    func getConfiguredMethods() -> [InputMethod] {
        guard let data = UserDefaults.standard.data(forKey: configuredMethodsKey),
              let methods = try? JSONDecoder().decode([InputMethod].self, from: data) else {
            return []
        }
        return methods
    }
    
    func saveConfiguredMethods(_ methods: [InputMethod]) {
        if let data = try? JSONEncoder().encode(methods) {
            UserDefaults.standard.set(data, forKey: configuredMethodsKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .configuredMethodsDidChange, object: nil)
        }
    }
    
    func getWindowPosition() -> WindowPosition? {
        guard let savedPosition = UserDefaults.standard.object(forKey: windowPositionKey) as? [String: Double],
              let x = savedPosition["x"],
              let y = savedPosition["y"] else {
            return nil
        }
        return WindowPosition(x: x, y: y)
    }
    
    func saveWindowPosition(_ position: WindowPosition) {
        let dict = ["x": position.x, "y": position.y]
        UserDefaults.standard.set(dict, forKey: windowPositionKey)
        UserDefaults.standard.synchronize()
    }
    
    func isFirstLaunch() -> Bool {
        return UserDefaults.standard.object(forKey: hasLaunchedKey) == nil
    }
    
    func setHasLaunched() {
        UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        UserDefaults.standard.synchronize()
    }
    
    func getToggleOverlayOnMenuClick() -> Bool {
        return UserDefaults.standard.bool(forKey: toggleOverlayOnMenuClickKey)
    }
    
    func setToggleOverlayOnMenuClick(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: toggleOverlayOnMenuClickKey)
        UserDefaults.standard.synchronize()
    }
}

extension Notification.Name {
    static let configuredMethodsDidChange = Notification.Name("ConfiguredMethodsDidChange")
}
