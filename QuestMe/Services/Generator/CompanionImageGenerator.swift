//
//  CompanionImageGenerator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Generator/CompanionImageGenerator.swift
//
//  🎯 ファイルの目的:
//      画像生成のルールを適用して正面顔画像を生成。
//      - デフォルト: 写真に近いリアル質感の正面顔
//      - 例外: ユーザー入力に「アニメ/漫画」キーワードが含まれる場合のみアニメ調
//
//  🔗 依存:
//      - CompanionProfile.swift（avatar）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月11日
//

import UIKit

public enum ImageStyle {
    case realistic
    case anime
}

public enum CompanionImageGenerator {
    public static func generate(for avatar: CompanionAvatar, userInput: String) -> UIImage {
        let lowered = userInput.lowercased()
        let isAnime = lowered.contains("アニメ") || lowered.contains("漫画") || lowered.contains("マンガ")

        let style: ImageStyle = isAnime ? .anime : .realistic
        switch style {
        case .realistic:
            return generateRealisticFrontFace(avatar: avatar)
        case .anime:
            return generateAnimeStyle(avatar: avatar)
        }
    }

    // TODO: 実際の画像生成差し替えポイント（今はダミー）
    private static func generateRealisticFrontFace(avatar: CompanionAvatar) -> UIImage {
        // 正面顔・写真風に近いプレースホルダ
        return UIImage(systemName: "person.crop.square")!
    }

    private static func generateAnimeStyle(avatar: CompanionAvatar) -> UIImage {
        // アニメ/漫画調プレースホルダ
        return UIImage(systemName: "person.crop.square.fill")!
    }
}
