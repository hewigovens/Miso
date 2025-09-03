//
//  InputMethod.swift
//  Miso
//
//  Created by hewig on 7/23/25.
//

import Foundation

struct InputMethod: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let shortName: String
    let flag: String

    static let defaultMethods = [
        InputMethod(
            id: "com.apple.keylayout.ABC",
            name: "ABC",
            shortName: "EN",
            flag: "🇺🇸"
        ),
        InputMethod(
            id: "com.apple.inputmethod.SCIM.ITABC",
            name: "Pinyin - Simplified",
            shortName: "拼",
            flag: "🇨🇳"
        ),
        InputMethod(
            id: "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
            name: "Japanese",
            shortName: "あ",
            flag: "🇯🇵"
        )
    ]
}
