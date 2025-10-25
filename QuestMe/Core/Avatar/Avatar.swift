//
//  Avatar.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Avatar/Avatar.swift
//
//  🎯 ファイルの目的:
//      アバターの構造定義（画像・希望・向き・画質）
//      - CompanionProfile に組み込まれる
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation
import UIKit

public enum Avatar: Codable, Hashable {
    case treeOfWisdom
    case custom(data: Data?, prompt: AvatarPrompt, orientation: AvatarOrientation, quality: AvatarQuality)

    public func uiImage() -> UIImage? {
        switch self {
        case .custom(let data, _, _, _):
            return data.flatMap { UIImage(data: $0) }
        case .treeOfWisdom:
            return nil
        }
    }
}
