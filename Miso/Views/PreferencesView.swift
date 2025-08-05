//
//  PreferencesView.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                VStack(alignment: .leading) {
                    Text("Miso")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Method Input Switch Overlay")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom)

            Divider()

            // Input Methods Configuration
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Input Methods")
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        viewModel.openSystemPreferences()
                    }) {
                        Label("System Preferences", systemImage: "gear")
                    }

                    Button(action: {
                        viewModel.refreshFromSystem()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }

                if viewModel.configuredMethods.isEmpty {
                    Text("No input methods configured")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                } else {
                    ForEach(viewModel.configuredMethods) { method in
                        HStack {
                            Text(method.flag)
                                .font(.title2)

                            VStack(alignment: .leading) {
                                Text(method.name)
                                    .font(.body)
                                Text(method.id)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if method.id == viewModel.currentInputMethodID {
                                Label("Active", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }

                            Button(action: {
                                viewModel.removeInputMethod(method)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Divider()

            // Permissions
            VStack(alignment: .leading, spacing: 16) {
                Text("Permissions")
                    .font(.headline)

                // Input Monitoring Permission
                HStack {
                    Image(systemName: viewModel.hasInputMonitoringPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(viewModel.hasInputMonitoringPermission ? .green : .red)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Input Monitoring")
                            .font(.body)
                        Text("Required for keyboard shortcuts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if !viewModel.hasInputMonitoringPermission {
                        Button("Open Settings") {
                            viewModel.openInputMonitoringPreferences()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            Divider()

            // Settings
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.headline)

                if #available(macOS 13.0, *) {
                    Toggle("Launch at login", isOn: Binding(
                        get: { viewModel.launchAtLoginEnabled },
                        set: { _ in viewModel.toggleLaunchAtLogin() }
                    ))
                } else {
                    Text("Launch at login requires macOS 13.0 or later")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding(30)
        .frame(width: 500, height: 600)
        .onAppear {
            viewModel.updatePermissionStatus()
        }
    }
}

#Preview {
    PreferencesView()
}
