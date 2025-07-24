//
//  ContentViewModel.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation
import Combine
import AppKit
import Carbon

class ContentViewModel: ObservableObject {
    @Published var configuredMethods: [InputMethod] = []
    @Published var currentInputMethodID: String = ""
    @Published var launchAtLoginEnabled: Bool = false
    @Published var hasInputMonitoringPermission: Bool = false
    
    private let inputMethodService: InputMethodServiceProtocol
    private let preferencesService: PreferencesServiceProtocol
    private let permissionService: PermissionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @available(macOS 13.0, *)
    private var loginItemService: LoginItemService {
        LoginItemService.shared
    }
    
    init(inputMethodService: InputMethodServiceProtocol = InputMethodService.shared,
         preferencesService: PreferencesServiceProtocol = PreferencesService.shared,
         permissionService: PermissionServiceProtocol = PermissionService.shared) {
        self.inputMethodService = inputMethodService
        self.preferencesService = preferencesService
        self.permissionService = permissionService
        
        setupBindings()
        loadConfiguredMethods()
        updateCurrentInputMethod()
        updatePermissionStatus()
        startMonitoringInputMethodChanges()
    }
    
    private func setupBindings() {
        if #available(macOS 13.0, *) {
            loginItemService.$launchAtLoginEnabled
                .assign(to: &$launchAtLoginEnabled)
        }
    }
    
    private func loadConfiguredMethods() {
        let savedMethods = preferencesService.getConfiguredMethods()
        if savedMethods.isEmpty {
            // Load user's actual input methods from system on first launch
            configuredMethods = inputMethodService.getUserInputMethodsFromSystem()
            saveConfiguredMethods()
        } else {
            configuredMethods = savedMethods
        }
    }
    
    private func saveConfiguredMethods() {
        preferencesService.saveConfiguredMethods(configuredMethods)
    }
    
    func addInputMethod(_ method: InputMethod) {
        if !configuredMethods.contains(where: { $0.id == method.id }) {
            configuredMethods.append(method)
            saveConfiguredMethods()
        }
    }
    
    func removeInputMethod(_ method: InputMethod) {
        configuredMethods.removeAll { $0.id == method.id }
        saveConfiguredMethods()
    }
    
    func refreshFromSystem() {
        configuredMethods = inputMethodService.getUserInputMethodsFromSystem()
        saveConfiguredMethods()
    }
    
    func openSystemPreferences() {
        let urls = [
            // Try to open directly to Input Sources
            "x-apple.systempreferences:com.apple.preference.keyboard?InputSources",
            "x-apple.systempreferences:com.apple.Localization-Preferences?InputSources",
            "x-apple.systempreferences:com.apple.Localization-Preferences",
            // Fallback to general keyboard preferences
            "x-apple.systempreferences:com.apple.preference.keyboard?Text",
            "x-apple.systempreferences:com.apple.preference.keyboard",
            // Last resort - general settings
            "x-apple.systempreferences:com.apple.Settings.General"
        ]
        
        for urlString in urls {
            if let url = URL(string: urlString) {
                if NSWorkspace.shared.open(url) {
                    return
                }
            }
        }
    }
    
    func toggleLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            loginItemService.toggleLaunchAtLogin()
        }
    }
    
    func updatePermissionStatus() {
        hasInputMonitoringPermission = permissionService.checkInputMonitoringPermission()
    }
    
    func openInputMonitoringPreferences() {
        permissionService.openInputMonitoringPreferences()
        // Update status after a delay to give user time to grant permission
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updatePermissionStatus()
        }
    }
    
    private func updateCurrentInputMethod() {
        if let id = inputMethodService.getCurrentInputMethodID() {
            DispatchQueue.main.async {
                self.currentInputMethodID = id
            }
        }
    }
    
    private func startMonitoringInputMethodChanges() {
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil,
            queue: .main
        ) { _ in
            self.updateCurrentInputMethod()
        }
    }
    
    deinit {
        DistributedNotificationCenter.default.removeObserver(self)
    }
}
