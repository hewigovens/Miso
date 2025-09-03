//
//  ContentViewModel.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import Carbon
import Combine
import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var configuredMethods: [InputMethod] = []
    @Published var currentInputMethodID: String = ""
    @Published var launchAtLoginEnabled: Bool = false
    @Published var hasInputMonitoringPermission: Bool = false
    @Published var toggleOverlayOnMenuClick: Bool = false
    
    private let inputMethodService: InputMethodServiceProtocol
    private let preferencesService: PreferencesServiceProtocol
    private let permissionService: PermissionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @available(macOS 13.0, *)
    private var loginItemService: LoginItemService {
        LoginItemService.shared
    }
    
    // Designated initializer: no defaulted parameters that reference @MainActor singletons
    init(inputMethodService: InputMethodServiceProtocol,
         preferencesService: PreferencesServiceProtocol,
         permissionService: PermissionServiceProtocol)
    {
        self.inputMethodService = inputMethodService
        self.preferencesService = preferencesService
        self.permissionService = permissionService
        
        setupBindings()
        loadConfiguredMethods()
        loadToggleOverlaySetting()
        updateCurrentInputMethod()
        updatePermissionStatus()
        startMonitoringInputMethodChanges()
    }
    
    // Convenience initializer that supplies the shared singletons on the main actor
    convenience init() {
        self.init(
            inputMethodService: InputMethodService.shared,
            preferencesService: PreferencesService.shared,
            permissionService: PermissionService.shared
        )
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
    
    private func loadToggleOverlaySetting() {
        toggleOverlayOnMenuClick = preferencesService.getToggleOverlayOnMenuClick()
    }
    
    func updateToggleOverlaySetting(_ enabled: Bool) {
        toggleOverlayOnMenuClick = enabled
        preferencesService.setToggleOverlayOnMenuClick(enabled)
        
        // Notify AppDelegate to update status bar behavior
        NotificationCenter.default.post(name: NSNotification.Name("ToggleOverlayPreferenceChanged"), object: nil)
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
    
    func requestAndOpenInputMonitoringPermission() {
        // Request permission first
        permissionService.requestInputMonitoringPermission()
        
        // Then open system settings after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.permissionService.openInputMonitoringPreferences()
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
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateCurrentInputMethod()
            }
        }
    }
    
    deinit {
        DistributedNotificationCenter.default.removeObserver(self)
    }
}
