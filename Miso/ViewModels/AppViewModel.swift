//
//  AppViewModel.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation
import Combine
import AppKit

@MainActor
class AppViewModel: ObservableObject {
    @Published var overlayVisible: Bool = false
    
    private let permissionService: PermissionServiceProtocol
    private let preferencesService: PreferencesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Designated initializer: no defaulted parameters that reference @MainActor singletons
    init(permissionService: PermissionServiceProtocol,
         preferencesService: PreferencesServiceProtocol) {
        self.permissionService = permissionService
        self.preferencesService = preferencesService
    }
    
    // Convenience initializer that supplies the shared singletons on the main actor
    convenience init() {
        self.init(
            permissionService: PermissionService.shared,
            preferencesService: PreferencesService.shared
        )
    }
    
    func requestPermissions() {
        let isFirstLaunch = preferencesService.isFirstLaunch()
        if isFirstLaunch {
            preferencesService.setHasLaunched()
        }
        
    }
    
    func toggleOverlay() {
        overlayVisible.toggle()
    }
}
