//
//  QuestMeApp.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/QuestMeApp.swift
//
//  🎯 ファイルの目的:
//      SwiftUI アプリのエントリポイント。
//      - Google Maps SDK の初期化（APIキー）
//      - SpeechSync や Companion 初期化なども将来的にここで統合可能。
//      - Info.plist から安全に APIキーを取得して初期化。
//      - 今後の拡張（通知登録、ログ初期化、起動時儀式）にも対応可能。
//
//  🔗 関連/連動ファイル:
//      - Info.plist（GoogleMapsAPIKey）
//      - LocationInfoView.swift（Google Maps 使用）
//      - SpeechSync.swift（音声案内）
//      - UserEventHistory.swift（履歴保存）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI
import GoogleMaps

@main
struct QuestMeApp: App {
    init() {
        // ✅ Google Maps APIキーを Info.plist から安全に取得して初期化
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String {
            GMSServices.provideAPIKey(apiKey)
            print("✅ Google Maps APIキー初期化完了")
        } else {
            print("⚠️ Google Maps APIキーが Info.plist に見つかりません")
        }

        // ✅ 将来的に Companion や SpeechSync の初期化もここで統合可能
        // SpeechSync.shared.initialize()
        // CompanionOverlay.shared.prepare()
    }

    var body: some Scene {
        WindowGroup {
            // ✅ 起動時の初期画面（必要に応じて変更）
            LocationInfoView()
        }
    }
}
