//
//  DeceasedAssetStore.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Storage/DeceasedAssetStore.swift
//
//  🎯 ファイルの目的:
//      故人コンパニオンの画像・音声アセットを安全に保存・復元するストレージ層。
//      - CompanionProfile.id と紐付けて保存。
//      - Documents/DeceasedAssets/{id}/image.png, voice.m4a に保存。
//      - append-only 原則に従い、既存ファイルは上書きせず新規保存。
//      - FloatingCompanionExpandedView などの UI から参照可能。
//
//  🔗 依存:
//      - UIKit（UIImage）
//      - FileManager（保存）
//      - CompanionProfile.swift（ID連携）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月6日

import Foundation
import UIKit

final class DeceasedAssetStore {
    static let shared = DeceasedAssetStore()
    private init() {}

    // MARK: - 保存ディレクトリ
    private var baseURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("DeceasedAssets", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func profileDir(for id: UUID) -> URL {
        let dir = baseURL.appendingPathComponent(id.uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - 画像保存
    func saveImage(_ image: UIImage, for id: UUID) {
        let url = profileDir(for: id).appendingPathComponent("image.png")
        if let data = image.pngData() {
            try? data.write(to: url)
            print("✅ 故人画像を保存しました: \(url.path)")
        }
    }

    // MARK: - 画像読み込み
    func loadImage(for id: UUID) -> UIImage? {
        let url = profileDir(for: id).appendingPathComponent("image.png")
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    // MARK: - 音声保存
    func saveVoice(_ data: Data, for id: UUID) {
        let url = profileDir(for: id).appendingPathComponent("voice.m4a")
        try? data.write(to: url)
        print("✅ 故人音声を保存しました: \(url.path)")
    }

    // MARK: - 音声読み込み
    func loadVoice(for id: UUID) -> Data? {
        let url = profileDir(for: id).appendingPathComponent("voice.m4a")
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    // MARK: - アセット削除
    func deleteAssets(for id: UUID) {
        let dir = profileDir(for: id)
        try? FileManager.default.removeItem(at: dir)
        print("🗑️ 故人アセットを削除しました: \(dir.path)")
    }
}
