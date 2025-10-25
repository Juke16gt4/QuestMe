//
//  CompanionSession.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Voice/CompanionSession.swift
//
//  🎯 ファイルの目的:
//      コンパニオンとの対話セッションを管理するユーティリティ。
//      - セッション開始時に声紋照合を行い、本人以外なら応答拒否。
//      - VoiceprintEngine により特徴量抽出と照合。
//      - SecureStorage から登録済み声紋テンプレートを取得。
//
//  🔗 依存:
//      - VoiceprintEngine.swift（照合）
//      - SecureStorage.swift（声紋保存）
//      - AVFoundation（音声）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import Foundation
import AVFoundation
import Combine

final class CompanionSession {
    static let shared = CompanionSession()

    private init() {}

    // MARK: - セッション開始
    func beginSession(with inputAudioURL: URL, completion: @escaping (Bool) -> Void) {
        // 入力音声から特徴量抽出
        guard let inputFeatures = VoiceprintEngine.shared.extractFeatures(from: inputAudioURL) else {
            completion(false)
            return
        }

        // 登録済み声紋テンプレートを取得
        guard let storedFeatures = SecureStorage.shared.loadVoiceprint() else {
            completion(false)
            return
        }

        // 類似度スコアを計算
        let score = VoiceprintEngine.shared.match(inputFeatures, against: storedFeatures)

        // 閾値判定（0.85以上で本人とみなす）
        let isVerified = score >= 0.85
        completion(isVerified)
    }
}
