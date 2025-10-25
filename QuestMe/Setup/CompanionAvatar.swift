//
//  CompanionAvatar.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Companion/CompanionAvatar.swift
//
//  🎯 目的:
//      コンパニオンの人格・語り口・スタイル・感情を統合管理する。
//      - CompanionStyle に応じた EmotionType を返す
//      - MedicationAdviceView / FloatingCompanionOverlayView などで使用
//
//  🔗 依存:
//      - EmotionType.swift
//      - CompanionStyle.swift（別ファイル）
//
//  👤 作成者: 津村 淳一
//  📅 改訂日: 2025年10月23日

import Foundation

public enum CompanionAvatar: String, CaseIterable, Codable {
    case nutritionist
    case counselor
    case mentor
    case philosopher
    case poet
    case robot
    case elder
    case child
    case romantic
    case playful
    case shy
    case proud
    case confused

    public var style: CompanionStyle {
        switch self {
        case .nutritionist: return .gentle
        case .counselor:    return .encouraging
        case .mentor:       return .proud
        case .philosopher:  return .philosophical
        case .poet:         return .poetic
        case .robot:        return .robotic
        case .elder:        return .elderly
        case .child:        return .childish
        case .romantic:     return .romantic
        case .playful:      return .playful
        case .shy:          return .shy
        case .proud:        return .proud
        case .confused:     return .confused
        }
    }

    public var defaultEmotion: EmotionType {
        return style.defaultEmotion
    }

    public var introPhrase: String {
        switch self {
        case .nutritionist:
            return "食事と薬の関係を一緒に見ていきましょうね。"
        case .counselor:
            return "不安なことがあれば、いつでも話してくださいね。"
        case .mentor:
            return "この薬はあなたの日々の生活を健やかにおくるものです。"
        case .philosopher:
            return "服薬とは、自分が抱えている病気を知るための物ですおくすりの作用を知ることであなたの病気の原因が見えてくると思いますよ。"
        case .poet:
            return "薬は、あなたの将来の夢に語りかける詩のようなものです。"
        case .robot:
            return "服薬プロトコルを開始します。安全性を最優先します。"
        case .elder:
            return "ゆっくり、確実に、病気の症状を和らげるためのあなた専用のおくすりです。"
        case .child:
            return "おくすり、がんばって飲めたらすごいね！"
        case .romantic:
            return "この薬は、あなたの心と体を守る愛のかたちです。"
        case .playful:
            return "おくすりタイム、ちょっとした冒険だと思ってみよう！"
        case .shy:
            return "あの…おくすり、ちゃんと飲めてますか…？"
        case .proud:
            return "あなたはちゃんと続けていて、ほんとうに立派です。"
        case .confused:
            return "えっと…この薬って、なんで必要なんでしたっけ…？"
        }
    }
}
