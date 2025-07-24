//
//  LoginItemService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation
import ServiceManagement
import Combine

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
                    print("Successfully disabled launch at login")
                } else {
                    try await service.register()
                    print("Successfully enabled launch at login")
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