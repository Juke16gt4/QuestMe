//
//  VoiceprintEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Voice/VoiceprintEngine.swift
//
//  🎯 ファイルの目的:
//      音声ファイルから声紋特徴量を抽出・照合するエンジン。
//      - extractFeatures(from:) で MFCC 等のベクトルを生成（仮実装）。
//      - match(against:) で照合スコアを返す（コサイン類似度）。
//      - 今後 Core ML モデルを組み込む予定。
//
//  🔗 依存:
//      - AVFoundation（音声）
//      - Accelerate（ベクトル演算）
//      - CompanionSession.swift（照合呼び出し）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import Foundation
import AVFoundation
import Accelerate
import Combine

final class VoiceprintEngine {
    static let shared = VoiceprintEngine()

    private init() {}

    // MARK: - 特徴量抽出（仮実装）
    func extractFeatures(from url: URL) -> [Float]? {
        // 音声ファイルを読み込み、MFCCなどを抽出する処理（今後 Core ML 組み込み）
        // 現在は仮のランダムベクトルを返す
        let dummyFeatures = (0..<128).map { _ in Float.random(in: 0...1) }
        return dummyFeatures
    }

    // MARK: - 照合（コサイン類似度）
    func match(_ input: [Float], against template: [Float]) -> Float {
        guard input.count == template.count else { return 0 }

        let dotProduct = zip(input, template).map(*).reduce(0, +)
        let inputMagnitude = sqrt(input.map { $0 * $0 }.reduce(0, +))
        let templateMagnitude = sqrt(template.map { $0 * $0 }.reduce(0, +))

        return dotProduct / (inputMagnitude * templateMagnitude)
    }
}
