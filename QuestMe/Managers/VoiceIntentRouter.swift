//
//  VoiceIntentRouter.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/VoiceIntentRouter.swift
//
//  🎯 ファイルの目的:
//      音声入力から意図を解析し、LabResult などの保存処理にルーティングする
//

import Foundation

final class VoiceIntentRouter {

    /// 音声入力を解析して LabResult を生成・保存する例
    func handleLabResultIntent(testName: String, value: String, detectedEmotion: String?) {
        // LabResult の初期化に emotion を追加
        let result = LabResult(
            testName: testName,
            value: value,
            date: Date(),
            emotion: detectedEmotion ?? ""   // ← ここが修正ポイント
        )

        LabResultStorageManager.shared.save(result)
        print("LabResult 保存完了: \(result)")
    }

    // 他の intent ハンドリング処理もここに追加していく
}
