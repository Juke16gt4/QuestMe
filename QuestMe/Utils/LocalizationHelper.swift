//
//  LocalizationHelper.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Utils/LocalizationHelper.swift
//
//  🎯 ファイルの目的:
//      アプリ内文言の多言語管理（12言語対応）。
//      - 画面やダイアログで使うキーを型安全に定義
//      - 右上ヘルプ文言のロジック提供
//      - Localizable.strings を前提に NSLocalizableString を仲介
//
//  🔗 連動・関連:
//      - Localizable.strings（Base, ja, en, fr, de, es, it, pt, ru, zh-Hans, zh-Hant, ko, id）
//      - QuestMe/Views/Nutrition/NutritionCameraRecordView.swift（localized()/helpText()使用）
//      - QuestMe/Managers/Nutrition/NutritionStorageManager.swift（保存完了メッセージなど）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-23 13:30 JST
//

import Foundation

// MARK: - 言語識別サポート（現在言語）
public func currentLangCode() -> String {
    // iOS16+ の LocaleComponents を利用（フォールバックは "en"）
    Locale.current.language.languageCode?.identifier ?? "en"
}

// MARK: - ローカライズキー（型安全）
public enum L {
    // 画面タイトル・ボタン
    case nutritionTitle            // "栄養記録"
    case helpButton                // "ヘルプ" or "❓"
    case captureButton             // "撮影"
    case menuButton                // "メニュー"
    case mainButton                // "メイン画面"
    case takeAnother               // "追加撮影"

    // ステータス・メッセージ
    case analyzingWait             // "解析までしばらくお待ちください…"
    case analysisDone              // "解析が完了しました。"
    case saveDoneTitle             // "保存が完了しました"
    case saveDoneMessage           // "保存しました。追加撮影、メニュー、またはメイン画面を選んでください。"
    case initCameraFailed          // "カメラを初期化できませんでした。"

    // 推定表示
    case estimatedCaloriesFormat   // "推定摂取カロリー: %.0f kcal"

    // 記録用語
    case meal                      // "食事"
    case capturedMeal              // "撮影された食事"

    // ヘルプテキスト（長文）
    case helpTextLong              // 長文ヘルプ
}

// MARK: - Localizable.strings のキー対応
private func key(_ l: L) -> String {
    switch l {
    case .nutritionTitle:          return "nutrition_title"
    case .helpButton:               return "help_button"
    case .captureButton:            return "capture_button"
    case .menuButton:               return "menu_button"
    case .mainButton:               return "main_button"
    case .takeAnother:              return "take_another"
    case .analyzingWait:            return "analyzing_wait"
    case .analysisDone:             return "analysis_done"
    case .saveDoneTitle:            return "save_done_title"
    case .saveDoneMessage:          return "save_done_message"
    case .initCameraFailed:         return "init_camera_failed"
    case .estimatedCaloriesFormat:  return "estimated_calories_format"
    case .meal:                     return "meal"
    case .capturedMeal:             return "captured_meal"
    case .helpTextLong:             return "help_text_long"
    }
}

// MARK: - ローカライズ関数（NSLocalizedString）
public func localized(_ l: L) -> String {
    NSLocalizedString(key(l), comment: "")
}

// MARK: - 直接文字列をローカライズ（既存互換）
public func localized(_ raw: String) -> String {
    // 既存コード互換用（可能なら L ベースに置換していく）
    NSLocalizedString(raw, comment: "")
}

// MARK: - 12言語ヘルプテキスト（Localizable.strings に無い場合のフォールバック）
public func helpText(for langCode: String) -> String {
    // まず Localizable.strings の長文を優先
    let fromStrings = localized(.helpTextLong)
    if fromStrings != "help_text_long" { // 未定義ならキーそのままが返る想定 → フォールバックへ
        return fromStrings
    }

    // 12言語フォールバック
    switch langCode {
    case "ja":
        return "中央の枠に料理を収めて静止すると自動で撮影します。撮影後は解析・保存が行われ、完了後に「追加撮影」「メニュー」「メイン画面」を選べます。解析が2秒以上かかる場合は待機メッセージが表示されます。"
    case "en":
        return "Place the meal within the central frame and hold still for auto-capture. After capture, analysis and saving run automatically; choose 'Take Another', 'Menu', or 'Home'. If analysis exceeds 2 seconds, a waiting message appears."
    case "fr":
        return "Placez le repas dans le cadre central et restez immobile pour la capture automatique. Après la capture, l’analyse et l’enregistrement se lancent automatiquement ; choisissez « Reprendre », « Menu » ou « Accueil ». Au-delà de 2 secondes, un message d’attente s’affiche."
    case "de":
        return "Platzieren Sie die Mahlzeit im zentralen Rahmen und halten Sie still für die Autoaufnahme. Nach der Aufnahme laufen Analyse und Speicherung automatisch; wählen Sie „Weitere Aufnahme“, „Menü“ oder „Start“. Bei über 2 Sekunden erscheint eine Wartemeldung."
    case "es":
        return "Coloque la comida en el marco central y manténgase quieto para la captura automática. Tras la captura, el análisis y guardado se ejecutan automáticamente; elija «Otra», «Menú» o «Inicio». Si supera 2 segundos, aparece un mensaje de espera."
    case "it":
        return "Posiziona il pasto nel riquadro centrale e rimani fermo per la cattura automatica. Dopo la cattura, analisi e salvataggio partono automaticamente; scegli «Nuovo scatto», «Menu» o «Home». Oltre 2 secondi appare un messaggio di attesa."
    case "pt":
        return "Coloque a refeição dentro do quadro central e fique imóvel para captura automática. Após capturar, análise e salvamento são automáticos; escolha ‘Nova Foto’, ‘Menu’ ou ‘Início’. Se exceder 2 segundos, aparece uma mensagem de espera."
    case "ru":
        return "Разместите блюдо в центральной рамке и удерживайте неподвижно для автосъёмки. После съёмки анализ и сохранение выполняются автоматически; выберите «Снять ещё», «Меню» или «Домой». Если анализ превышает 2 секунды, появится сообщение ожидания."
    case "zh": // 简体
        return "将餐食置于中心框内并保持稳定，系统将自动拍摄。拍摄后会自动分析与保存；可选择“再次拍摄”、“菜单”或“主页”。分析超过2秒时会显示等待消息。"
    case "zh-Hant": // 繁體
        return "將餐食置於中央框內並保持靜止，系統會自動拍攝。拍攝後會自動分析與儲存；可選擇「再次拍攝」、「選單」或「主畫面」。分析超過2秒時會顯示等待訊息。"
    case "ko":
        return "음식을 중앙 프레임에 맞추고 고정하면 자동 촬영됩니다. 촬영 후 분석·저장이 자동으로 진행되며 ‘추가 촬영’, ‘메뉴’, ‘메인 화면’을 선택할 수 있습니다. 분석이 2초를 넘으면 대기 메시지가 표시됩니다."
    case "id":
        return "Letakkan makanan di dalam bingkai tengah dan tetap diam untuk tangkapan otomatis. Setelah tangkap, analisis dan penyimpanan berjalan otomatis; pilih ‘Ambil Lagi’, ‘Menu’, atau ‘Beranda’. Jika analisis lebih dari 2 detik, akan muncul pesan menunggu."
    default:
        return "Place the meal within the central frame and hold still for auto-capture. After capture, analysis and saving run automatically; choose 'Take Another', 'Menu', or 'Home'. If analysis exceeds 2 seconds, a waiting message appears."
    }
}
