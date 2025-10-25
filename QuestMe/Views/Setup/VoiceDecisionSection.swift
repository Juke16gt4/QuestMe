//
//  VoiceDecisionSection.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Setup/VoiceDecisionSection.swift
//
//  🎯 ファイルの目的:
//      声の決定方法（プリセット or 自由入力）をユーザーに選ばせ、VoiceProfile を確定。
//      - プリセット: 落ち着いた/元気/ハスキーなど
//      - 自由入力: キーワード解析でスタイル・音色へマッピング
//
//  🔗 依存:
//      - VoiceProfile.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import SwiftUI

public enum VoiceDecisionRoute: String, CaseIterable, Identifiable {
    case preset = "プリセットから選ぶ"
    case freeInput = "好みを答える"
    public var id: String { rawValue }
}

public struct VoiceDecisionSection: View {
    @Binding var route: VoiceDecisionRoute
    @Binding var freeInput: String
    @Binding var selectedProfile: VoiceProfile?

    public init(route: Binding<VoiceDecisionRoute>,
                freeInput: Binding<String>,
                selectedProfile: Binding<VoiceProfile?>) {
        _route = route
        _freeInput = freeInput
        _selectedProfile = selectedProfile
    }

    public var body: some View {
        VStack(spacing: 16) {
            Picker("声の決め方", selection: $route) {
                ForEach(VoiceDecisionRoute.allCases) { r in
                    Text(r.rawValue).tag(r)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if route == .preset {
                VStack(spacing: 8) {
                    Button("落ち着いた") { selectedProfile = VoiceProfile(style: .calm, tone: .deep) }
                    Button("元気") { selectedProfile = VoiceProfile(style: .energetic, tone: .bright) }
                    Button("ハスキー") { selectedProfile = VoiceProfile(style: .calm, tone: .husky) }
                }
            } else {
                TextField("どんな声が好みですか？（例：低めで落ち着いた、元気で明るい）", text: $freeInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("解析して生成") {
                    selectedProfile = VoiceProfileMapper.map(from: freeInput)
                }
            }

            if let profile = selectedProfile {
                Text("選択された声: \(profile.style.rawValue) / \(profile.tone.rawValue)")
                    .foregroundColor(.secondary)
            }
        }
    }
}

public enum VoiceProfileMapper {
    public static func map(from input: String) -> VoiceProfile {
        let s = input.lowercased()
        if s.contains("低") || s.contains("落ち着") {
            return VoiceProfile(style: .calm, tone: .deep)
        } else if s.contains("明る") || s.contains("元気") {
            return VoiceProfile(style: .energetic, tone: .bright)
        } else if s.contains("ハスキー") {
            return VoiceProfile(style: .calm, tone: .husky)
        }
        return VoiceProfile(style: .gentle, tone: .neutral)
    }
}
