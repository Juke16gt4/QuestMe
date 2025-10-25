//
//  CompanionExpression.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Emotion/CompanionExpression.swift
//
//  🎯 ファイルの目的:
//      コンパニオンの感情表現を定義する列挙型。
//      - 各表情に対応する絵文字を保持。
//      - ユーザーの発話や状態に応じて表情を切り替える。
//      - CompanionFaceView や FloatingCompanionView で使用される。
//      - 表情と語り口の連動に対応。
//
//  🔗 依存:
//      - CompanionFaceView.swift（絵文字表示）
//      - FloatingCompanionView.swift（表情描画）
//      - EmotionAnalyzer.swift（推定元）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月29日

import Foundation

enum CompanionExpression: String, CaseIterable {
    case joy = "😄"
    case sadness = "😢"
    case anger = "😠"
    case surprise = "😲"
    case calm = "😌"
    case neutral = "😐"
    case smile = "😊"
    case sad = "😭"
    case surprised = "😮"
    case serious = "😑"
    case confused = "😕"
    case discomfort = "😣"
    case disgust = "🤢"
}
