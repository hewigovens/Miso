//
//  OverlayViewModel.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation
import Combine
import Carbon

@MainActor
class OverlayViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var configuredMethods: [InputMethod] = []
    @Published var currentInputMethodID: String = ""
    
    private let inputMethodService: InputMethodServiceProtocol
    private let preferencesService: PreferencesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var currentMethod: InputMethod? {
        configuredMethods.first { $0.id == currentInputMethodID }
    }
    
    // Designated initializer without defaulted @MainActor singletons
    init(inputMethodService: InputMethodServiceProtocol,
         preferencesService: PreferencesServiceProtocol) {
        self.inputMethodService = inputMethodService
        self.preferencesService = preferencesService
        
        loadConfiguredMethods()
        updateCurrentInputMethod()
        startMonitoringInputMethodChanges()
    }
    
    // Convenience initializer that injects shared services
    convenience init() {
        self.init(
            inputMethodService: InputMethodService.shared,
            preferencesService: PreferencesService.shared
        )
    }
    
    private func loadConfiguredMethods() {
        let savedMethods = preferencesService.getConfiguredMethods()
        if savedMethods.isEmpty {
            configuredMethods = inputMethodService.getUserInputMethodsFromSystem()
        } else {
            configuredMethods = savedMethods
        }
    }
    
    func toggleExpanded() {
        isExpanded.toggle()
    }
    
    func switchToInputMethod(_ method: InputMethod) {
        inputMethodService.switchToInputMethod(method.id)
        updateCurrentInputMethod()
        isExpanded = false
    }
    
    private func updateCurrentInputMethod() {
        if let id = inputMethodService.getCurrentInputMethodID() {
            // We're already on the MainActor; assign directly.
            self.currentInputMethodID = id
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
