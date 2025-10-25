//
//  FaceAuthManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/FaceAuthManager.swift
//
//  🎯 目的:
//      撮影前の本人確認（ユーザー以外の顔は撮影不可）。
//      ・初回基準画像との特徴比較で本人判定（将来 CoreML 化）。
//      ・閾値は厳しめ（誤認防止）。
//      ・本人確認失敗時は撮影中止＋Companion案内。
//
//  🔗 依存:
//      - UIKit
//
//  🔗 関連/連動ファイル:
//      - BeautyCaptureView.swift（撮影フロー内で利用）
//      - BeautyStorageManager.swift（基準画像の取得）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import UIKit

final class FaceAuthManager {
    static let shared = FaceAuthManager()

    // ダミー: 将来は特徴量ベクトル類似度で判定
    func isSamePerson(current: UIImage, reference: UIImage?) -> Bool {
        guard reference != nil else { return true } // 初回は許可
        return Bool.random() // 実運用では類似度 >= threshold
    }
}
