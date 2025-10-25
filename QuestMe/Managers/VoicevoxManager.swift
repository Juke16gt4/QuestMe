//
//  VoicevoxManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/VoicevoxManager.swift
//
//  🎯 ファイルの目的:
//      VOICEVOX連携処理を管理する構造体。
//      - 接続確認・音声生成・保存・再生までをアプリ内で完結。
//      - 故人の声を儀式的に再現し、ユーザーの心に語りかける存在を宿す。
//      - CompanionSetupView や VoicePlaybackView から呼び出される。
//
//  🔗 依存:
//      - VOICEVOX API（audio_query / synthesis）
//      - AVFoundation（音声再生）
//      - SwiftUI（Bindingによる再生状態管理）
//      - URLSession（通信処理）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import Foundation
import AVFoundation
import SwiftUI

/// VOICEVOX連携処理を管理する構造体。接続確認・音声生成・保存・再生までをアプリ内で完結させる。
struct VoicevoxManager {
    let baseURL = "http://127.0.0.1:50021"

    /// VOICEVOXが起動しているか確認する。成功時は true を返す。
    func checkConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/speakers") else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            let isConnected = (data != nil && error == nil)
            completion(isConnected)
        }.resume()
    }

    /// 指定テキストと話者IDから音声を生成し、一時保存URLを返す。
    func generateVoice(text: String, speakerId: Int, completion: @escaping (URL?) -> Void) {
        guard let queryURL = URL(string: "\(baseURL)/audio_query?speaker=\(speakerId)&text=\(text)"),
              let synthesisURL = URL(string: "\(baseURL)/synthesis?speaker=\(speakerId)") else {
            completion(nil)
            return
        }

        var queryRequest = URLRequest(url: queryURL)
        queryRequest.httpMethod = "POST"

        URLSession.shared.dataTask(with: queryRequest) { queryData, _, _ in
            guard let queryData = queryData else {
                completion(nil)
                return
            }

            var synthesisRequest = URLRequest(url: synthesisURL)
            synthesisRequest.httpMethod = "POST"
            synthesisRequest.httpBody = queryData
            synthesisRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: synthesisRequest) { audioData, _, _ in
                guard let audioData = audioData else {
                    completion(nil)
                    return
                }

                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("companion_voice.wav")
                do {
                    try audioData.write(to: tempURL)
                    completion(tempURL)
                } catch {
                    completion(nil)
                }
            }.resume()
        }.resume()
    }

    /// 保存された音声を再生する。再生中は isSpeaking を true にする。
    func playVoice(from url: URL, isSpeaking: Binding<Bool>) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            isSpeaking.wrappedValue = true
            player.play()

            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
                isSpeaking.wrappedValue = false
            }
        } catch {
            isSpeaking.wrappedValue = false
        }
    }
}

