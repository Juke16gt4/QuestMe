//
//  FloatingCompanionExpandedView.swift
//  QuestMe
//
//  📂 格納先:
//      QuestMe/Views/Companion/FloatingCompanionExpandedView.swift
//
//  🎯 目的:
//      - 故人の画像・音声挿入（最大3体制限）
//      - 音声形成（VoiceGenerator + VoiceMixer + 成長係数 0.05刻み = 1歳）
//      - 年齢ごとの声質プリセット（ageMappings）の保存・復元
//      - コンパニオン切り替え（保存済み一覧から即時切替）
//      - 年齢別プリセット一覧（AgeMappingListView）への遷移
//
//  🔗 連携・関連先:
//      - Models/CompanionProfile.swift （ageMappings プロパティ保持）
//      - Storage/CompanionStorageManager.swift （保存・読み込み・アクティブ切替）
//      - Storage/DeceasedAssetStore.swift （画像・音声アセット保存）
//      - Views/Companion/AgeMappingListView.swift （プリセット一覧・編集）
//      - VoiceProfile / VoiceStyle / VoiceTone / VoiceSpeed（声質モデル群）
//
//  👤 製作者: 津村 淳一
//  📅 製作日時: 2025-10-11 JST
//

import SwiftUI
import AVFoundation

struct FloatingCompanionExpandedView: View {
    @State private var step: Int = 0
    @State private var droppedImage: UIImage?
    @State private var droppedAudioURL: URL?
    @State private var saveMessage: String?

    @State private var voiceProfile: VoiceProfile = VoiceProfile(style: .calm, tone: .neutral, speed: .normal)
    @State private var ageMappings: [Int: VoiceProfile] = [:]

    @State private var profiles: [CompanionProfile] = []
    @State private var activeProfile: CompanionProfile?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🤖 Companion 拡大画面")
                    .font(.title3)
                    .bold()

                Button("③ 故人の画像・音声挿入") { step = 1 }
                    .buttonStyle(.borderedProminent)

                // 画像ドロップ枠
                DropImageView(droppedImage: $droppedImage, step: $step)

                // 音声音源ドロップ枠
                DropAudioView(droppedAudioURL: $droppedAudioURL, step: $step)

                // 音声形成
                if step >= 3 {
                    VoiceFormationView(voice: $voiceProfile, ageMappings: $ageMappings)
                }

                if let msg = saveMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(msg.hasPrefix("✅") ? .green : .red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider().padding(.vertical, 8)

                Text("④ コンパニオン切り替え")
                    .font(.headline)

                List {
                    ForEach(profiles, id: \.id) { profile in
                        HStack {
                            Text(profile.name)
                            Spacer()
                            if profile.id == activeProfile?.id {
                                Text("使用中")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            CompanionStorageManager.shared.setActive(profile)
                            activeProfile = profile
                            if let mappings = profile.ageMappings {
                                ageMappings = mappings
                            }
                        }
                    }
                }
                .onAppear { reloadProfiles() }

                // 一覧編集画面への遷移
                NavigationLink("年齢別プリセット一覧と編集", destination: AgeMappingListView(ageMappings: $ageMappings))

                Spacer()

                if step >= 3 {
                    Button("故人コンパニオンを保存") {
                        finalizeMemoryCompanion(image: droppedImage, audioURL: droppedAudioURL, voice: voiceProfile, mappings: ageMappings)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("記憶挿入と切替")
        }
    }

    private func finalizeMemoryCompanion(image: UIImage?, audioURL: URL?, voice: VoiceProfile, mappings: [Int: VoiceProfile]) {
        var profile = CompanionProfile(
            name: "故人のコンパニオン",
            avatar: .mentor,
            voice: voice,
            aiEngine: .copilot,
            voiceprintHash: nil,
            faceprintData: nil,
            isDeceased: true
        )
        profile.ageMappings = mappings

        let success = CompanionStorageManager.shared.saveDeceased(profile)
        if success {
            if let image = image { DeceasedAssetStore.shared.saveImage(image, for: profile.id) }
            if let audioURL = audioURL { DeceasedAssetStore.shared.saveAudio(from: audioURL, for: profile.id) }

            CompanionStorageManager.shared.setActive(profile)
            activeProfile = profile
            saveMessage = "✅ 故人コンパニオンを保存しました（最大3体ルール適用）"
            reloadProfiles()
            step = 4
        } else {
            saveMessage = "❌ 故人コンパニオンは既に3体登録されています"
        }
    }

    private func reloadProfiles() {
        profiles = CompanionStorageManager.shared.loadAll()
        activeProfile = CompanionStorageManager.shared.loadActive()
        if let mappings = activeProfile?.ageMappings {
            ageMappings = mappings
        }
    }
}
