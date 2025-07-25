//
//  LoginItemService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Combine
import Foundation
import ServiceManagement

@available(macOS 13.0, *)
class LoginItemService: ObservableObject {
    static let shared = LoginItemService()
    
    private let service = SMAppService.mainApp
    
    @Published var launchAtLoginEnabled: Bool = false
    
    private init() {
        updateStatus()
    }
    
    func updateStatus() {
        launchAtLoginEnabled = service.status == .enabled
    }
    
    func toggleLaunchAtLogin() {
        Task {
            do {
                if service.status == .enabled {
                    try await service.unregister()
                } else {
                    try service.register()
                }
                
                await MainActor.run {
                    updateStatus()
                }
            } catch {
                print("Failed to update login item: \(error.localizedDescription)")
                await MainActor.run {
                    updateStatus()
                }
            }
        }
    }
}
