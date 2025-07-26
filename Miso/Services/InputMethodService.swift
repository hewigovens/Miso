//
//  InputMethodService.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import AppKit
import Carbon
import Foundation

protocol InputMethodServiceProtocol {
    func getCurrentInputMethodID() -> String?
    func switchToInputMethod(_ methodID: String)
    func getAllAvailableInputMethods() -> [InputMethod]
    func getUserInputMethodsFromSystem() -> [InputMethod]
}

class InputMethodService: InputMethodServiceProtocol {
    static let shared = InputMethodService()
    
    private init() {}
    
    func getCurrentInputMethodID() -> String? {
        guard let currentSource = TISCopyCurrentKeyboardInputSource() else {
            return nil
        }
        
        return getProperty(currentSource.takeUnretainedValue(), kTISPropertyInputSourceID) as? String
    }
    
    func switchToInputMethod(_ methodID: String) {
        guard let inputSourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] else {
            return
        }
        
        for source in inputSourceList {
            if let sourceID = getProperty(source, kTISPropertyInputSourceID) as? String,
               sourceID == methodID
            {
                TISSelectInputSource(source)
                break
            }
        }
    }
    
    func getAllAvailableInputMethods() -> [InputMethod] {
        guard let inputSourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        
        var methods: [InputMethod] = []
        
        for source in inputSourceList {
            guard let sourceID = getProperty(source, kTISPropertyInputSourceID) as? String else { continue }
            
            let category = getProperty(source, kTISPropertyInputSourceCategory) as? String
            guard category == (kTISCategoryKeyboardInputSource as String) else { continue }
            
            let isSelectCapable = getProperty(source, kTISPropertyInputSourceIsSelectCapable) as? Bool ?? false
            guard isSelectCapable else { continue }
            
            let name = getProperty(source, kTISPropertyLocalizedName) as? String ?? sourceID
            let shortName = deriveShortName(from: name, sourceID: sourceID)
            let flag = deriveFlag(from: sourceID, name: name)
            
            let method = InputMethod(
                id: sourceID,
                name: name,
                shortName: shortName,
                flag: flag
            )
            
            methods.append(method)
        }
        
        return methods.sorted { $0.name < $1.name }
    }
    
    func getUserInputMethodsFromSystem() -> [InputMethod] {
        guard let inputSourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] else {
            return InputMethod.defaultMethods
        }
        
        var userMethods: [InputMethod] = []
        var enabledSourceIDs: Set<String> = []
        
        // First, get all enabled input sources
        for source in inputSourceList {
            guard let sourceID = getProperty(source, kTISPropertyInputSourceID) as? String else { continue }
            
            let category = getProperty(source, kTISPropertyInputSourceCategory) as? String
            guard category == (kTISCategoryKeyboardInputSource as String) else { continue }
            
            let isSelectCapable = getProperty(source, kTISPropertyInputSourceIsSelectCapable) as? Bool ?? false
            guard isSelectCapable else { continue }
            
            let isEnabled = getProperty(source, kTISPropertyInputSourceIsEnabled) as? Bool ?? false
            if isEnabled {
                enabledSourceIDs.insert(sourceID)
            }
        }
        
        // Now create InputMethod objects for enabled sources
        for source in inputSourceList {
            guard let sourceID = getProperty(source, kTISPropertyInputSourceID) as? String else { continue }
            guard enabledSourceIDs.contains(sourceID) else { continue }
            
            let category = getProperty(source, kTISPropertyInputSourceCategory) as? String
            guard category == (kTISCategoryKeyboardInputSource as String) else { continue }
            
            let isSelectCapable = getProperty(source, kTISPropertyInputSourceIsSelectCapable) as? Bool ?? false
            guard isSelectCapable else { continue }
            
            let name = getProperty(source, kTISPropertyLocalizedName) as? String ?? sourceID
            let shortName = deriveShortName(from: name, sourceID: sourceID)
            let flag = deriveFlag(from: sourceID, name: name)
            
            let method = InputMethod(
                id: sourceID,
                name: name,
                shortName: shortName,
                flag: flag
            )
            
            userMethods.append(method)
        }
        
        // Sort methods to put common ones first
        userMethods.sort { m1, m2 in
            let priority1 = getMethodPriority(m1)
            let priority2 = getMethodPriority(m2)
            
            if priority1 != priority2 {
                return priority1 < priority2
            }
            
            return m1.name < m2.name
        }
        
        // If no enabled methods found, fall back to defaults
        return userMethods.isEmpty ? InputMethod.defaultMethods : userMethods
    }
    
    // MARK: - Private Methods
    
    private func getProperty(_ source: TISInputSource, _ key: CFString) -> Any? {
        let ptr = TISGetInputSourceProperty(source, key)
        guard let ptr = ptr else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue()
    }
    
    private func getMethodPriority(_ method: InputMethod) -> Int {
        if method.id.contains("ABC") { return 0 }
        if method.id.contains("Pinyin") { return 1 }
        if method.id.contains("Japanese") { return 2 }
        if method.id.contains("Korean") { return 3 }
        return 99
    }
    
    private func deriveShortName(from name: String, sourceID: String) -> String {
        if sourceID.contains("ABC") { return "EN" }
        if sourceID.contains("Pinyin") { return "拼" }
        if sourceID.contains("Japanese") || sourceID.contains("Hiragana") { return "あ" }
        if sourceID.contains("Katakana") { return "ア" }
        if sourceID.contains("Korean") || sourceID.contains("Hangul") { return "한" }
        return String(name.prefix(2))
    }
    
    private func deriveFlag(from sourceID: String, name: String) -> String {
        if sourceID.contains("ABC") || sourceID.contains("US") { return "🇺🇸" }
        if sourceID.contains("Hans") || sourceID.contains("Pinyin") || sourceID.contains("Chinese") { return "🇨🇳" }
        if sourceID.contains("Hant") { return "🇹🇼" }
        if sourceID.contains("Japanese") || sourceID.contains("Kotoeri") { return "🇯🇵" }
        if sourceID.contains("Korean") || sourceID.contains("Hangul") { return "🇰🇷" }
        if sourceID.contains("Spanish") { return "🇪🇸" }
        if sourceID.contains("French") { return "🇫🇷" }
        if sourceID.contains("German") { return "🇩🇪" }
        if sourceID.contains("Russian") { return "🇷🇺" }
        return "🌐"
    }
}
