//
//  AppViewModel.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation
import Combine
import AppKit

class AppViewModel: ObservableObject {
    @Published var overlayVisible: Bool = false
    
    private let permissionService: PermissionServiceProtocol
    private let preferencesService: PreferencesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(permissionService: PermissionServiceProtocol = PermissionService.shared,
         preferencesService: PreferencesServiceProtocol = PreferencesService.shared) {
        self.permissionService = permissionService
        self.preferencesService = preferencesService
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