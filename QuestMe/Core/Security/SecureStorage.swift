//
//  SecureStorage.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Security/SecureStorage.swift
//
//  🎯 ファイルの目的:
//      声紋テンプレート（特徴量ベクトル）を暗号化して保存・取得するユーティリティ。
//      - 保存先は Keychain（Secure Enclave 対応）
//      - ユーザーごとに一意のキーで管理
//      - CompanionSession.swift や VoiceprintEngine.swift から呼び出される
//
//  🔗 依存:
//      - Security.framework（Keychain）
//      - VoiceprintEngine.swift（保存・取得）
//      - CompanionSession.swift（認証）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import Foundation
import Security

final class SecureStorage {
    static let shared = SecureStorage()
    private init() {}

    private let voiceprintKey = "com.questme.voiceprint"

    // MARK: - 保存
    func saveVoiceprint(_ features: [Float]) {
        let data = features.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: voiceprintKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("声紋保存失敗: \(status)")
        }
    }
    // MARK: - 取得
    func loadVoiceprint() -> [Float]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: voiceprintKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            print("声紋取得失敗: \(status)")
            return nil
        }

        let count = data.count / MemoryLayout<Float>.size
        return data.withUnsafeBytes { ptr in
            Array(UnsafeBufferPointer<Float>(start: ptr.baseAddress!.assumingMemoryBound(to: Float.self), count: count))
        }
    }

    // MARK: - 削除
    func deleteVoiceprint() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: voiceprintKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}
