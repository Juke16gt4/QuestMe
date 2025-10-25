//
//  UserProfile.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/UserProfile.swift
//
//  🎯 ファイルの目的:
//      ユーザーの基本プロフィールを保持するモデル。
//      - SQLite保存（append-only）に対応（UserProfileStorage.swift）
//      - BMI計算・疾患・喫煙・サプリメント・地域情報を含む
//      - CompanionAdviceView / HealthAdviceView / ProfileEditView / UserProfileEditorView で使用
//      - LabResult や 検査履歴との連携も可能
//
//  👤 製作者: 津村 淳一
//  📅 最終更新: 2025年10月17日
//

import Foundation

// ✅ 喫煙習慣の列挙型
enum TobaccoType: String, CaseIterable, Codable {
    case none = "非喫煙者"
    case cigarette = "紙巻きたばこ"
    case vape = "電子タバコ"
    case other = "その他"
}

// ✅ 性別
enum GenderType: String, CaseIterable, Codable {
    case male = "男性"
    case female = "女性"
    case other = "その他"
}

// ✅ 血液型（RH+/-まで）
enum BloodType: String, CaseIterable, Codable {
    case A_Positive = "A+"
    case A_Negative = "A−"
    case B_Positive = "B+"
    case B_Negative = "B−"
    case AB_Positive = "AB+"
    case AB_Negative = "AB−"
    case O_Positive = "O+"
    case O_Negative = "O−"
}

// ✅ サプリメントモデル
struct Supplement: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var dosage: String?
    var purpose: String?
    var startedAt: Date?
}

// ✅ ユーザープロファイルモデル
struct UserProfile: Identifiable, Codable {
    var id: Int? = nil
    var title: String
    var name: String
    var email: String                // ← 追加（必須）
    var birthdate: Date
    var postalCode: String
    var region: String
    var heightCm: Double
    var weightKg: Double
    var isHealthy: Bool
    var diseases: [String]
    var lastUpdated: Date?
    var occupation: String
    var supplements: [Supplement]
    var tobaccoType: TobaccoType
    var cigarettesPerDay: Int

    // 任意入力項目
    var gender: GenderType = .other
    var bloodType: BloodType = .O_Positive
    var hobbies: [String] = []
    var allergies: [String] = []

    // ✅ BMI計算
    var bmi: Double {
        guard heightCm > 0 else { return 0.0 }
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }

    // ✅ BMIカテゴリ判定
    var bmiCategory: String {
        let value = bmi
        switch value {
        case ..<18.5: return "低体重"
        case 18.5..<25: return "普通体重"
        case 25..<30: return "肥満（1度）"
        case 30..<35: return "肥満（2度）"
        case 35..<40: return "肥満（3度）"
        default: return "肥満（4度）"
        }
    }

    // ✅ 空プロファイル生成（初期化用）
    static func empty() -> UserProfile {
        return UserProfile(
            id: nil,
            title: "未設定",
            name: "未入力",
            email: "",                // ← 初期値
            birthdate: Date(),
            postalCode: "",
            region: "",
            heightCm: 0.0,
            weightKg: 0.0,
            isHealthy: true,
            diseases: [],
            lastUpdated: nil,
            occupation: "",
            supplements: [],
            tobaccoType: .none,
            cigarettesPerDay: 0,
            gender: .other,
            bloodType: .O_Positive,
            hobbies: [],
            allergies: []
        )
    }
}
