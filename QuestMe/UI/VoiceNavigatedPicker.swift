//
//  VoiceNavigatedPicker.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/05.
//

/**
 VoiceNavigatedPicker
 --------------------
 目的:
 - アプリ内のすべての Picker に「手動操作＋音声操作＋Companionナビゲーション」を統合する。
 - 「上」「下」「決定」といった音声コマンドで選択を制御できる。
 - CompanionOverlay が自動的にナビゲート音声を流す。
 
 格納先:
 - Swiftファイル: Views/Common/VoiceNavigatedPicker.swift
*/

import SwiftUI

struct VoiceNavigatedPicker<T: Identifiable & Hashable>: View {
    @Binding var selection: T
    var items: [T]
    var label: String
    var display: (T) -> String

    @State private var selectedIndex: Int = 0

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(items) { item in
                Text(display(item)).tag(item)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(height: 150)
        .onAppear {
            CompanionOverlay.shared.speak("ここでは\(label)を選べます。スクロールするか、『上』『下』『決定』と声で言ってください。選んだら内容が反映されます。")
            SpeechRecognizerManager.shared.start { command in
                handleCommand(command)
            }
        }
        .onTapGesture {
            CompanionOverlay.shared.speak("声でも操作できますよ。『上』『下』『決定』と言ってみてください。")
        }
    }

    private func handleCommand(_ command: String) {
        if let idx = items.firstIndex(of: selection) {
            if command.contains("上") {
                let newIndex = max(0, idx - 1)
                selection = items[newIndex]
            } else if command.contains("下") {
                let newIndex = min(items.count - 1, idx + 1)
                selection = items[newIndex]
            } else if command.contains("決定") || command.contains("これ") {
                CompanionOverlay.shared.speak("「\(display(selection))」を選びました！")
            }
        }
    }
}
