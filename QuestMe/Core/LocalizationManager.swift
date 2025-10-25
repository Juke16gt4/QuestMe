//
//  LocalizationManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Localization/LocalizationManager.swift
//
//  🎯 ファイルの目的:
//      - アプリ全体の文言を、ユーザーが選択した母国語（LanguageOption）に同期する。
//      - UI表示と音声合成（speechCode）を統一。
//      - 全12言語（LanguageOption.all）を完全カバー。
//      - プレースホルダ（%name, %style, %engine）に対応。
//      - キー未登録時は安全なフォールバック（英語→日本語→キー名）。
//
//  🔗 依存:
//      - Models/LanguageOption.swift（選択言語・speechCode）
//      - Combine（状態配信）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月16日 JST
//

import Foundation
import Combine

@MainActor
final class LocalizationManager: ObservableObject {
    // 現在選択中の言語（LanguageOption を唯一の真実源に）
    @Published var current: LanguageOption = LanguageOption.all.first { $0.code == "ja" }! // 既定: 日本語

    // 12言語の翻訳辞書
    // キー一覧は共通ボタン/認証/Companion UI を完全カバー
    private let translations: [String: [String: String]] = [
        // 日本語 (ja)
        "ja": [
            // 基本操作
            "button_back": "戻る",
            "button_next": "次へ",
            "button_finish": "完了",
            "button_save": "保存",
            "button_cancel": "キャンセル",
            "button_retry": "再試行",
            "button_skip": "スキップ",
            "button_main": "メインへ",
            // 認証
            "auth_title": "認証してください",
            "face_auth_title": "顔で認証",
            "face_capture_button": "顔を撮影する",
            "face_verify_button": "認証する",
            "face_no_target": "照合対象がありません",
            "face_auth_success": "顔認証成功",
            "face_auth_fail": "顔認証失敗",
            "voice_auth_title": "声で認証",
            "voice_record_start": "録音開始",
            "voice_record_stop": "録音停止",
            "voice_playback": "録音を再生",
            "voice_verify_button": "認証する",
            "voice_auth_success": "音声認証成功",
            "voice_auth_fail": "音声認証失敗",
            // Companion
            "companion_advice_title": "Companion のアドバイス",
            "companion_advice_placeholder": "アドバイスを入力",
            "emotion_label": "感情",
            "speak_button": "語らせる",
            "thinking_button": "考え中で語らせる",
            "thinking_text": "少し考えさせてください",
            "companion_home_welcome": "ようこそ、%name さん！",
            "companion_home_voice_style": "声のスタイル: %style",
            "companion_home_ai_engine": "AIエンジン: %engine"
        ],

        // 英語 (en)
        "en": [
            "button_back": "Back",
            "button_next": "Next",
            "button_finish": "Finish",
            "button_save": "Save",
            "button_cancel": "Cancel",
            "button_retry": "Retry",
            "button_skip": "Skip",
            "button_main": "Main",
            "auth_title": "Please authenticate",
            "face_auth_title": "Face Authentication",
            "face_capture_button": "Capture Face",
            "face_verify_button": "Verify",
            "face_no_target": "No stored face data",
            "face_auth_success": "Face authentication succeeded",
            "face_auth_fail": "Face authentication failed",
            "voice_auth_title": "Voice Authentication",
            "voice_record_start": "Start Recording",
            "voice_record_stop": "Stop Recording",
            "voice_playback": "Play Recording",
            "voice_verify_button": "Verify",
            "voice_auth_success": "Voice authentication succeeded",
            "voice_auth_fail": "Voice authentication failed",
            "companion_advice_title": "Companion Advice",
            "companion_advice_placeholder": "Enter advice",
            "emotion_label": "Emotion",
            "speak_button": "Speak",
            "thinking_button": "Speak as Thinking",
            "thinking_text": "Let me think for a moment",
            "companion_home_welcome": "Welcome, %name!",
            "companion_home_voice_style": "Voice Style: %style",
            "companion_home_ai_engine": "AI Engine: %engine"
        ],

        // フランス語 (fr)
        "fr": [
            "button_back": "Retour",
            "button_next": "Suivant",
            "button_finish": "Terminer",
            "button_save": "Enregistrer",
            "button_cancel": "Annuler",
            "button_retry": "Réessayer",
            "button_skip": "Ignorer",
            "button_main": "Accueil",
            "auth_title": "Veuillez vous authentifier",
            "face_auth_title": "Authentification faciale",
            "face_capture_button": "Capturer le visage",
            "face_verify_button": "Vérifier",
            "face_no_target": "Aucune donnée faciale enregistrée",
            "face_auth_success": "Authentification faciale réussie",
            "face_auth_fail": "Échec de l'authentification faciale",
            "voice_auth_title": "Authentification vocale",
            "voice_record_start": "Démarrer l’enregistrement",
            "voice_record_stop": "Arrêter l’enregistrement",
            "voice_playback": "Lire l’enregistrement",
            "voice_verify_button": "Vérifier",
            "voice_auth_success": "Authentification vocale réussie",
            "voice_auth_fail": "Échec de l’authentification vocale",
            "companion_advice_title": "Conseil du compagnon",
            "companion_advice_placeholder": "Saisir un conseil",
            "emotion_label": "Émotion",
            "speak_button": "Parler",
            "thinking_button": "Parler en réfléchissant",
            "thinking_text": "Laissez-moi réfléchir un instant",
            "companion_home_welcome": "Bienvenue, %name !",
            "companion_home_voice_style": "Style de voix : %style",
            "companion_home_ai_engine": "Moteur IA : %engine"
        ],

        // ドイツ語 (de)
        "de": [
            "button_back": "Zurück",
            "button_next": "Weiter",
            "button_finish": "Fertig",
            "button_save": "Speichern",
            "button_cancel": "Abbrechen",
            "button_retry": "Wiederholen",
            "button_skip": "Überspringen",
            "button_main": "Hauptmenü",
            "auth_title": "Bitte authentifizieren",
            "face_auth_title": "Gesichtsauthentifizierung",
            "face_capture_button": "Gesicht aufnehmen",
            "face_verify_button": "Verifizieren",
            "face_no_target": "Keine gespeicherten Gesichtsdaten",
            "face_auth_success": "Gesichtsauthentifizierung erfolgreich",
            "face_auth_fail": "Gesichtsauthentifizierung fehlgeschlagen",
            "voice_auth_title": "Stimmenauthentifizierung",
            "voice_record_start": "Aufnahme starten",
            "voice_record_stop": "Aufnahme stoppen",
            "voice_playback": "Aufnahme abspielen",
            "voice_verify_button": "Verifizieren",
            "voice_auth_success": "Stimmenauthentifizierung erfolgreich",
            "voice_auth_fail": "Stimmenauthentifizierung fehlgeschlagen",
            "companion_advice_title": "Ratschlag des Begleiters",
            "companion_advice_placeholder": "Ratschlag eingeben",
            "emotion_label": "Emotion",
            "speak_button": "Sprechen",
            "thinking_button": "Nachdenklich sprechen",
            "thinking_text": "Lass mich kurz nachdenken",
            "companion_home_welcome": "Willkommen, %name!",
            "companion_home_voice_style": "Stimmstil: %style",
            "companion_home_ai_engine": "KI-Engine: %engine"
        ],

        // スペイン語 (es)
        "es": [
            "button_back": "Atrás",
            "button_next": "Siguiente",
            "button_finish": "Finalizar",
            "button_save": "Guardar",
            "button_cancel": "Cancelar",
            "button_retry": "Reintentar",
            "button_skip": "Saltar",
            "button_main": "Principal",
            "auth_title": "Por favor autentíquese",
            "face_auth_title": "Autenticación facial",
            "face_capture_button": "Capturar rostro",
            "face_verify_button": "Verificar",
            "face_no_target": "No hay datos faciales almacenados",
            "face_auth_success": "Autenticación facial exitosa",
            "face_auth_fail": "Fallo en la autenticación facial",
            "voice_auth_title": "Autenticación por voz",
            "voice_record_start": "Iniciar grabación",
            "voice_record_stop": "Detener grabación",
            "voice_playback": "Reproducir grabación",
            "voice_verify_button": "Verificar",
            "voice_auth_success": "Autenticación por voz exitosa",
            "voice_auth_fail": "Fallo en la autenticación por voz",
            "companion_advice_title": "Consejo del compañero",
            "companion_advice_placeholder": "Ingrese un consejo",
            "emotion_label": "Emoción",
            "speak_button": "Hablar",
            "thinking_button": "Hablar pensando",
            "thinking_text": "Déjame pensar un momento",
            "companion_home_welcome": "¡Bienvenido, %name!",
            "companion_home_voice_style": "Estilo de voz: %style",
            "companion_home_ai_engine": "Motor de IA: %engine"
        ],

        // 中国語（簡体字）(zh)
        "zh": [
            "button_back": "返回",
            "button_next": "下一步",
            "button_finish": "完成",
            "button_save": "保存",
            "button_cancel": "取消",
            "button_retry": "重试",
            "button_skip": "跳过",
            "button_main": "主界面",
            "auth_title": "请进行认证",
            "face_auth_title": "人脸认证",
            "face_capture_button": "拍摄人脸",
            "face_verify_button": "验证",
            "face_no_target": "没有存储的人脸数据",
            "face_auth_success": "人脸认证成功",
            "face_auth_fail": "人脸认证失败",
            "voice_auth_title": "声纹认证",
            "voice_record_start": "开始录音",
            "voice_record_stop": "停止录音",
            "voice_playback": "播放录音",
            "voice_verify_button": "验证",
            "voice_auth_success": "声纹认证成功",
            "voice_auth_fail": "声纹认证失败",
            "companion_advice_title": "伙伴建议",
            "companion_advice_placeholder": "输入建议",
            "emotion_label": "情绪",
            "speak_button": "说出来",
            "thinking_button": "思考中说出",
            "thinking_text": "让我想一想",
            "companion_home_welcome": "欢迎，%name！",
            "companion_home_voice_style": "声音风格: %style",
            "companion_home_ai_engine": "AI引擎: %engine"
        ],

        // 韓国語 (ko)
        "ko": [
            "button_back": "뒤로",
            "button_next": "다음",
            "button_finish": "완료",
            "button_save": "저장",
            "button_cancel": "취소",
            "button_retry": "다시 시도",
            "button_skip": "건너뛰기",
            "button_main": "메인",
            "auth_title": "인증해주세요",
            "face_auth_title": "얼굴 인증",
            "face_capture_button": "얼굴 촬영",
            "face_verify_button": "인증하기",
            "face_no_target": "저장된 얼굴 데이터 없음",
            "face_auth_success": "얼굴 인증 성공",
            "face_auth_fail": "얼굴 인증 실패",
            "voice_auth_title": "음성 인증",
            "voice_record_start": "녹음 시작",
            "voice_record_stop": "녹음 중지",
            "voice_playback": "녹음 재생",
            "voice_verify_button": "인증하기",
            "voice_auth_success": "음성 인증 성공",
            "voice_auth_fail": "음성 인증 실패",
            "companion_advice_title": "동반자의 조언",
            "companion_advice_placeholder": "조언 입력",
            "emotion_label": "감情",
            "speak_button": "말하게 하기",
            "thinking_button": "생각 중 말하기",
            "thinking_text": "잠시 생각해볼게요",
            "companion_home_welcome": "환영합니다, %name 님!",
            "companion_home_voice_style": "음성 스타일: %style",
            "companion_home_ai_engine": "AI 엔진: %engine"
        ],

        // イタリア語 (it)
        "it": [
            "button_back": "Indietro",
            "button_next": "Avanti",
            "button_finish": "Fine",
            "button_save": "Salva",
            "button_cancel": "Annulla",
            "button_retry": "Riprova",
            "button_skip": "Salta",
            "button_main": "Home",
            "auth_title": "Autenticarsi per favore",
            "face_auth_title": "Autenticazione facciale",
            "face_capture_button": "Cattura volto",
            "face_verify_button": "Verifica",
            "face_no_target": "Nessun dato facciale salvato",
            "face_auth_success": "Autenticazione facciale riuscita",
            "face_auth_fail": "Autenticazione facciale fallita",
            "voice_auth_title": "Autenticazione vocale",
            "voice_record_start": "Avvia registrazione",
            "voice_record_stop": "Interrompi registrazione",
            "voice_playback": "Riproduci registrazione",
            "voice_verify_button": "Verifica",
            "voice_auth_success": "Autenticazione vocale riuscita",
            "voice_auth_fail": "Autenticazione vocale fallita",
            "companion_advice_title": "Consiglio del compagno",
            "companion_advice_placeholder": "Inserisci un consiglio",
            "emotion_label": "Emozione",
            "speak_button": "Parla",
            "thinking_button": "Parla riflettendo",
            "thinking_text": "Fammi pensare un momento",
            "companion_home_welcome": "Benvenuto, %name!",
            "companion_home_voice_style": "Stile di voce: %style",
            "companion_home_ai_engine": "Motore IA: %engine"
        ],

        // ポルトガル語 (pt)
        "pt": [
            "button_back": "Voltar",
            "button_next": "Avançar",
            "button_finish": "Concluir",
            "button_save": "Salvar",
            "button_cancel": "Cancelar",
            "button_retry": "Tentar novamente",
            "button_skip": "Pular",
            "button_main": "Principal",
            "auth_title": "Por favor, autentique-se",
            "face_auth_title": "Autenticação facial",
            "face_capture_button": "Capturar rosto",
            "face_verify_button": "Verificar",
            "face_no_target": "Nenhum dado facial armazenado",
            "face_auth_success": "Autenticação facial bem-sucedida",
            "face_auth_fail": "Falha na autenticação facial",
            "voice_auth_title": "Autenticação por voz",
            "voice_record_start": "Iniciar gravação",
            "voice_record_stop": "Parar gravação",
            "voice_playback": "Reproduzir gravação",
            "voice_verify_button": "Verificar",
            "voice_auth_success": "Autenticação por voz bem-sucedida",
            "voice_auth_fail": "Falha na autenticação por voz",
            "companion_advice_title": "Conselho do companheiro",
            "companion_advice_placeholder": "Insira um conselho",
            "emotion_label": "Emoção",
            "speak_button": "Falar",
            "thinking_button": "Falar pensando",
            "thinking_text": "Deixe-me pensar um momento",
            "companion_home_welcome": "Bem-vindo, %name!",
            "companion_home_voice_style": "Estilo de voz: %style",
            "companion_home_ai_engine": "Motor de IA: %engine"
        ],

        // スウェーデン語 (sv)
        "sv": [
            "button_back": "Tillbaka",
            "button_next": "Nästa",
            "button_finish": "Slutför",
            "button_save": "Spara",
            "button_cancel": "Avbryt",
            "button_retry": "Försök igen",
            "button_skip": "Hoppa över",
            "button_main": "Huvudmeny",
            "auth_title": "Vänligen autentisera",
            "face_auth_title": "Ansiktsautentisering",
            "face_capture_button": "Fånga ansikte",
            "face_verify_button": "Verifiera",
            "face_no_target": "Inga sparade ansiktsdata",
            "face_auth_success": "Ansiktsautentisering lyckades",
            "face_auth_fail": "Ansiktsautentisering misslyckades",
            "voice_auth_title": "Röstautentisering",
            "voice_record_start": "Starta inspelning",
            "voice_record_stop": "Stoppa inspelning",
            "voice_playback": "Spela upp inspelning",
            "voice_verify_button": "Verifiera",
            "voice_auth_success": "Röstautentisering lyckades",
            "voice_auth_fail": "Röstautentisering misslyckades",
            "companion_advice_title": "Följeslagarens råd",
            "companion_advice_placeholder": "Ange råd",
            "emotion_label": "Känsla",
            "speak_button": "Tala",
            "thinking_button": "Tala eftertänksamt",
            "thinking_text": "Låt mig tänka ett ögonblick",
            "companion_home_welcome": "Välkommen, %name!",
            "companion_home_voice_style": "Röststil: %style",
            "companion_home_ai_engine": "AI-motor: %engine"
        ],

        // ヒンディー語 (hi)
        "hi": [
            "button_back": "वापस",
            "button_next": "अगला",
            "button_finish": "समाप्त",
            "button_save": "सहेजें",
            "button_cancel": "रद्द करें",
            "button_retry": "पुनः प्रयास",
            "button_skip": "छोड़ें",
            "button_main": "मुख्य",
            "auth_title": "कृपया प्रमाणीकरण करें",
            "face_auth_title": "चेहरा प्रमाणीकरण",
            "face_capture_button": "चेहरा कैप्चर करें",
            "face_verify_button": "सत्यापित करें",
            "face_no_target": "कोई सहेजा हुआ चेहरा डेटा नहीं",
            "face_auth_success": "चेहरा प्रमाणीकरण सफल",
            "face_auth_fail": "चेहरा प्रमाणीकरण विफल",
            "voice_auth_title": "वॉइस प्रमाणीकरण",
            "voice_record_start": "रिकॉर्डिंग शुरू करें",
            "voice_record_stop": "रिकॉर्डिंग रोकें",
            "voice_playback": "रिकॉर्डिंग चलाएँ",
            "voice_verify_button": "सत्यापित करें",
            "voice_auth_success": "वॉइस प्रमाणीकरण सफल",
            "voice_auth_fail": "वॉइस प्रमाणीकरण विफल",
            "companion_advice_title": "साथी की सलाह",
            "companion_advice_placeholder": "सलाह दर्ज करें",
            "emotion_label": "भावना",
            "speak_button": "बोलें",
            "thinking_button": "सोचते हुए बोलें",
            "thinking_text": "मुझे एक पल सोचने दें",
            "companion_home_welcome": "स्वागत है, %name!",
            "companion_home_voice_style": "आवाज़ शैली: %style",
            "companion_home_ai_engine": "एआई इंजन: %engine"
        ],

        // ノルウェー語 (no)
        "no": [
            "button_back": "Tilbake",
            "button_next": "Neste",
            "button_finish": "Fullfør",
            "button_save": "Lagre",
            "button_cancel": "Avbryt",
            "button_retry": "Prøv igjen",
            "button_skip": "Hopp over",
            "button_main": "Hovedmeny",
            "auth_title": "Vennligst autentiser",
            "face_auth_title": "Ansiktsautentisering",
            "face_capture_button": "Ta bilde av ansikt",
            "face_verify_button": "Verifiser",
            "face_no_target": "Ingen lagrede ansiktsdata",
            "face_auth_success": "Ansiktsautentisering vellykket",
            "face_auth_fail": "Ansiktsautentisering mislyktes",
            "voice_auth_title": "Stemmeautentisering",
            "voice_record_start": "Start opptak",
            "voice_record_stop": "Stopp opptak",
            "voice_playback": "Spill av opptak",
            "voice_verify_button": "Verifiser",
            "voice_auth_success": "Stemmeautentisering vellykket",
            "voice_auth_fail": "Stemmeautentisering mislyktes",
            "companion_advice_title": "Følgesvennens råd",
            "companion_advice_placeholder": "Skriv inn råd",
            "emotion_label": "Følelse",
            "speak_button": "Snakk",
            "thinking_button": "Snakk tenkende",
            "thinking_text": "La meg tenke et øyeblikk",
            "companion_home_welcome": "Velkommen, %name!",
            "companion_home_voice_style": "Stil på stemmen: %style",
            "companion_home_ai_engine": "AI-motor: %engine"
        ]
    ]

    // 文言取得（%name などの置換に対応）
    func localized(_ key: String, _ args: [String: String] = [:]) -> String {
        // 1) 現在言語 → 2) 英語 → 3) 日本語 → 4) キー名
        let langCode = current.code
        let template = translations[langCode]?[key]
            ?? translations["en"]?[key]
            ?? translations["ja"]?[key]
            ?? key
        var result = template
        for (k, v) in args {
            result = result.replacingOccurrences(of: "%\(k)", with: v)
        }
        return result
    }

    // 音声合成で使用する言語コード（LanguageOption.speechCode をそのまま提供）
    func speechCode() -> String {
        current.speechCode
    }

    // 言語切替（Picker 選択などで呼ぶ）
    func setLanguage(_ option: LanguageOption) {
        current = option
    }
}
