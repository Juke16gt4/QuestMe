//
//  SlackManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Meeting/SlackManager.swift
//
//  🎯 ファイルの目的:
//      Slack API を利用して議事録を指定チャンネルに投稿する管理器。
//      - Bot Token とチャンネルIDを利用。
//      - Markdown形式の議事録を chat.postMessage に送信。
//      - CompanionOverlay による音声フィードバックと連携。
//
//  🔗 依存:
//      - MeetingManager.swift（投稿元）
//      - CompanionOverlay.swift（音声）
//      - URLSession（通信）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation

final class SlackManager {
    static let shared = SlackManager()

    private let token = "<YOUR_SLACK_BOT_TOKEN>" // Slack Appで発行
    private let channel = "<YOUR_CHANNEL_ID>"    // 投稿先チャンネルID

    func postMinutes(markdown: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://slack.com/api/chat.postMessage") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "channel": channel,
            "text": markdown
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Slack投稿エラー: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
}
