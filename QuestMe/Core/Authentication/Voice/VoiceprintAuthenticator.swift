//
//  VoiceprintAuthenticator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Authentication/Voice/VoiceprintAuthenticator.swift
//

import Foundation
import CryptoKit

struct VoiceprintAuthenticator {
    static func registerVoice(_ audioData: Data) -> String {
        return hashVoice(audioData)
    }

    static func verify(_ inputAudio: Data, against storedHash: String) -> Bool {
        let inputHash = hashVoice(inputAudio)
        return inputHash == storedHash
    }

    private static func hashVoice(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
