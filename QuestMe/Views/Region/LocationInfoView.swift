//
//  LocationInfoView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Region/LocationInfoView.swift
//
//  🎯 ファイルの目的:
//      地域情報カテゴリ選択＋Google Maps連動ナビ案内＋場所検索表示＋交通手段選択＋お気に入り登録＋到着時の滞在メモ保存。
//      - Google Maps を画面内に統合（現在地マーカー／検索候補表示／ピンタップで選択）。
//      - 検索バーから地点検索、候補タップでピン表示＆選択。
//      - 交通手段を VoiceNavigatedPicker で「車・徒歩・公共交通」から選択（将来の Directions API 経路描画へ拡張可能）。
//      - 選択地点をお気に入りへスター保存、次回はワンタップで呼び出し。
//      - 到着イベントで滞在メモを入力し、UserEventHistory.impression に保存。
//      - 12言語対応のヘルプとナビゲーションボタン（次へ／戻る／メイン画面／ヘルプ）。
//
//  🔗 関連/連動ファイル:
//      - GoogleMapView.swift（Google MapsをSwiftUIへ統合、選択地点共有）
//      - SpeechSync.swift（音声案内・言語判定）
//      - CompanionSpeechBubble.swift（吹き出しUI）
//      - LocationManager.swift（現在地取得・到着/帰宅監視）
//      - UserEventHistory.swift（訪問履歴＋感想保存）
//      - VoiceNavigatedPicker.swift（交通手段選択の音声操作）
//      - FavoritesManager.swift（お気に入り保存・取得）
//      - StayMemoSheet.swift（到着時の滞在メモ入力）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月20日
//

import SwiftUI
import CoreLocation

// 交通手段モデル
struct TransportMode: Identifiable, Hashable {
    let id = UUID()
    let key: String // "driving", "walking", "transit"
    let label: String
}

struct LocationInfoView: View {
    @Environment(\.dismiss) private var dismiss

    // 検索・カテゴリ・ナビ状態
    @State private var showCategoryDialog = false
    @State private var selectedCategory: String? = nil
    @State private var searchText: String = ""
    @State private var selectedPlaceName: String? = nil
    @State private var isNavigating: Bool = false

    // 到着/帰宅監視
    @State private var hasArrived = false
    @State private var hasReturned = false

    // 地図更新トリガ
    @State private var mapQuery: String = ""

    // 交通手段選択
    @State private var transportSelection = TransportMode(key: "driving", label: "🚗 車")
    private let transportItems: [TransportMode] = [
        TransportMode(key: "driving", label: "🚗 車"),
        TransportMode(key: "walking", label: "🚶 徒歩"),
        TransportMode(key: "transit", label: "🚉 公共交通")
    ]

    // お気に入り
    @State private var favorites: [FavoritePlace] = FavoritesManager.shared.all()

    // 滞在メモ
    @State private var showMemoSheet = false
    @State private var memoText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // 吹き出し（カテゴリ選択後の案内）
                if let category = selectedCategory {
                    CompanionSpeechBubble(message: bubbleMessage(for: category), isVisible: !isNavigating)
                }

                // 検索バー＋お気に入りスター
                HStack(spacing: 8) {
                    TextField(localized("searchPlaceholder"), text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit { handleSearch() }

                    Button(localized("searchButton")) {
                        handleSearch()
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: saveFavoriteIfPossible) {
                        Label(localized("favoriteButton"), systemImage: "star.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .disabled(selectedPlaceName == nil)
                }
                .padding(.horizontal)

                // お気に入り一覧（タップで検索反映）
                if !favorites.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(favorites) { fav in
                                Button(action: { selectFavorite(fav) }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "star.fill").foregroundColor(.yellow)
                                        Text(fav.title).lineLimit(1)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Google Maps 表示
                GoogleMapView(searchQuery: $mapQuery, selectedPlaceName: $selectedPlaceName)
                    .frame(height: 320)
                    .cornerRadius(12)
                    .padding(.horizontal)

                // 交通手段選択（音声操作可能）
                VoiceNavigatedPicker(
                    selection: $transportSelection,
                    items: transportItems,
                    label: localized("transportPickerLabel"),
                    display: { $0.label }
                )
                .padding(.horizontal)

                // カテゴリ選択・ナビ開始
                HStack(spacing: 10) {
                    Button(localized("categoryButton")) {
                        SpeechSync().speak(localized("categorySpoken"))
                        showCategoryDialog = true
                    }
                    .buttonStyle(.bordered)

                    Button(localized("startNavButton")) {
                        startNavigation()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedPlaceName == nil)
                }
                .padding(.horizontal)

                // 下部ナビゲーションボタン
                HStack(spacing: 10) {
                    Button(localized("prevButton")) {
                        SpeechSync().speak(localized("prevSpoken"))
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Button(localized("nextButton")) {
                        SpeechSync().speak(localized("nextSpoken"))
                        // ScreenRegistry がある場合は遷移を接続
                    }
                    .buttonStyle(.bordered)

                    Button(localized("homeButton")) {
                        SpeechSync().speak(localized("homeSpoken"))
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Button(localized("helpButton")) {
                        SpeechSync().speak(helpText(for: SpeechSync().currentLanguage))
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .navigationTitle(localized("title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← " + localized("backLabel")) {
                        SpeechSync().speak(localized("prevSpoken"))
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("❓") {
                        SpeechSync().speak(helpText(for: SpeechSync().currentLanguage))
                    }
                }
            }
            // カテゴリ選択ダイアログ
            .confirmationDialog(localized("categoryDialogTitle"),
                                isPresented: $showCategoryDialog,
                                titleVisibility: .visible) {
                Button(localized("catGourmet")) { handleCategory("gourmet") }
                Button(localized("catLeisure")) { handleCategory("leisure") }
                Button(localized("catMedical")) { handleCategory("medical") }
                Button(localized("catEvent")) { handleCategory("event") }
                Button(localized("catGourmetHidden")) { handleCategory("gourmet_hidden") }
                Button(localized("catLeisureHidden")) { handleCategory("leisure_hidden") }
                Button(localized("cancelButton"), role: .cancel) { selectedCategory = nil }
            }
            // 到着/帰宅応答
            .onChange(of: hasArrived) { arrived in
                if arrived {
                    SpeechSync().speak(arrivalMessage(for: selectedCategory))
                    isNavigating = false
                    // 滞在メモシートを開く
                    showMemoSheet = true
                }
            }
            .onChange(of: hasReturned) { returned in
                if returned {
                    SpeechSync().speak(returnMessage(for: selectedCategory))
                    isNavigating = false
                }
            }
            .onAppear {
                // 現在地取得可否をチェック
                if !LocationManager.shared.isLocationAvailable() {
                    SpeechSync().speak(localized("noLocationSpoken"))
                } else {
                    SpeechSync().speak(localized("welcomeSpoken"))
                }
            }
            // 滞在メモ入力シート
            .sheet(isPresented: $showMemoSheet) {
                StayMemoSheet(
                    placeName: selectedPlaceName ?? localized("unknownPlace"),
                    memoText: $memoText,
                    onSave: { text in
                        // 到着時の履歴保存（感想付き）
                        if let place = selectedPlaceName, let category = selectedCategory {
                            UserEventHistory.shared.addEvent(
                                category: category,
                                title: place,
                                location: "浜田市周辺",
                                impression: text.isEmpty ? nil : text
                            )
                        }
                        SpeechSync().speak(localized("memoSavedSpoken"))
                    },
                    onCancel: {
                        SpeechSync().speak(localized("memoCanceledSpoken"))
                    }
                )
            }
        }
    }

    // MARK: - 検索実行
    private func handleSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        mapQuery = trimmed
        SpeechSync().speak(localized("searchSpoken") + " " + trimmed)
    }

    // MARK: - カテゴリ選択
    private func handleCategory(_ category: String) {
        selectedCategory = category
        SpeechSync().speak(bubbleMessage(for: category))
        // 履歴へ暫定保存（場所未定）
        UserEventHistory.shared.addEvent(category: category, title: categoryTitle(for: category), location: "浜田市周辺", impression: nil)
    }

    // MARK: - ナビ開始（Google Maps URLスキームで外部ナビも可能）
    private func startNavigation() {
        guard LocationManager.shared.isLocationAvailable() else {
            SpeechSync().speak(localized("noLocationSpoken"))
            return
        }
        guard let dest = selectedPlaceName else { return }
        isNavigating = true
        SpeechSync().speak(localized("navStartSpoken"))

        // 画面内マップでの誘導（擬似）と到着／帰宅監視
        LocationManager.shared.monitorArrival { arrived in
            hasArrived = arrived
            if arrived, let place = selectedPlaceName, let category = selectedCategory {
                UserEventHistory.shared.addEvent(category: category, title: place, location: "浜田市周辺", impression: nil)
            }
        }
        LocationManager.shared.monitorReturn { returned in
            hasReturned = returned
        }

        // 外部Google Mapsアプリ／ブラウザでのナビ起動（経路モード反映）
        let mode = transportSelection.key // "driving", "walking", "transit"
        let encodedDest = dest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? dest
        let urlString = "https://www.google.com/maps/dir/?api=1&destination=\(encodedDest)&travelmode=\(mode)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - お気に入り
    private func saveFavoriteIfPossible() {
        guard let name = selectedPlaceName, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        FavoritesManager.shared.add(title: name)
        favorites = FavoritesManager.shared.all()
        SpeechSync().speak(localized("favoriteSavedSpoken"))
    }

    private func selectFavorite(_ fav: FavoritePlace) {
        mapQuery = fav.title
        searchText = fav.title
        SpeechSync().speak(localized("favoriteSelectedSpoken") + " " + fav.title)
    }

    // MARK: - 吹き出しメッセージ
    private func bubbleMessage(for category: String) -> String {
        switch category {
        case "gourmet": return "浜田市周辺の人気グルメ店はこちらです：\n1. ケンボロー\n2. すし蔵\n3. 豆狸\nどちらに行かれますか？"
        case "leisure": return "浜田市周辺のレジャー施設はこちらです：\n1. 石見畳ヶ浦\n2. 金城温泉ゆうゆ\n3. 三隅神社\n行き先はお決まりですか？"
        case "medical": return "浜田市周辺の病院・薬局はこちらです。どのような症状がありますか？"
        case "event": return "浜田市周辺のイベントはこちらです：\n1. 美又温泉まつり\n2. お月見の会\n3. BUY浜田昼市\nどちらのイベントに行かれますか？"
        case "gourmet_hidden": return "浜田市周辺の穴場グルメ店はこちらです：\n1. 風のえんがわ\n2. まるみ食堂\n3. 旬菜たまき\n4. ひなた屋\n5. こもれび亭\nどちらに行かれますか？"
        case "leisure_hidden": return "浜田市周辺の穴場レジャー施設はこちらです：\n1. 三隅公園\n2. 石見神楽資料館\n3. 旧浜田灯台跡\n4. 田の浦海岸\n5. 浜田市立郷土館\n行き先はお決まりですか？"
        default: return "地域情報を取得しています…"
        }
    }

    private func categoryTitle(for category: String) -> String {
        switch category {
        case "gourmet": return "グルメ"
        case "leisure": return "レジャー"
        case "medical": return "医療"
        case "event": return "イベント"
        case "gourmet_hidden": return "穴場グルメ"
        case "leisure_hidden": return "穴場レジャー"
        default: return "地域情報"
        }
    }

    // MARK: - 到着/帰宅メッセージ
    private func arrivalMessage(for category: String?) -> String {
        switch category {
        case "gourmet", "gourmet_hidden": return "ナビゲーションを閉じます。美味しい食事や会話を楽しんできてください。"
        case "leisure", "leisure_hidden": return "ナビゲーションを閉じます。ゆったりとした時間をお楽しみください。お気をつけて。"
        case "medical": return "ナビゲーションを閉じます。しっかり症状を医師に伝えてくださいね。早く治ることを願っています。"
        case "event": return "ナビゲーションを閉じます。イベントを存分に楽しんできてください。"
        default: return "ナビゲーションを閉じます。お気をつけて。"
        }
    }

    private func returnMessage(for category: String?) -> String {
        switch category {
        case "gourmet", "gourmet_hidden": return "お帰りなさい。どんな料理が印象に残りましたか？"
        case "leisure", "leisure_hidden": return "お帰りなさい。癒されましたか？またご案内しますね。"
        case "medical": return "お帰りなさい。体調はいかがですか？無理なさらず、ゆっくりお休みください。"
        case "event": return "お帰りなさい。印象に残ったことがあれば、ぜひ教えてくださいね。"
        default: return "お帰りなさい。またいつでもご案内できますよ。"
        }
    }

    // MARK: - 多言語ラベル/音声（主要キー）
    private func localized(_ key: String) -> String {
        let lang = SpeechSync().currentLanguage
        switch (key, lang) {
        // 日本語
        case ("title", "ja"): return "🌏 地域情報"
        case ("searchPlaceholder", "ja"): return "場所を検索"
        case ("searchButton", "ja"): return "検索"
        case ("favoriteButton", "ja"): return "お気に入り保存"
        case ("favoriteSavedSpoken", "ja"): return "お気に入りへ保存しました。"
        case ("favoriteSelectedSpoken", "ja"): return "お気に入りから選択しました。"
        case ("unknownPlace", "ja"): return "未選択の場所"
        case ("transportPickerLabel", "ja"): return "交通手段"
        case ("categoryButton", "ja"): return "カテゴリ選択"
        case ("startNavButton", "ja"): return "ナビ開始"
        case ("prevButton", "ja"): return "戻る"
        case ("nextButton", "ja"): return "次へ"
        case ("homeButton", "ja"): return "メイン画面"
        case ("helpButton", "ja"): return "ヘルプ"
        case ("backLabel", "ja"): return "戻る"
        case ("categoryDialogTitle", "ja"): return "地域情報カテゴリ"
        case ("catGourmet", "ja"): return "グルメ"
        case ("catLeisure", "ja"): return "レジャー施設"
        case ("catMedical", "ja"): return "病院・薬局"
        case ("catEvent", "ja"): return "イベント情報"
        case ("catGourmetHidden", "ja"): return "飲食店（穴場）"
        case ("catLeisureHidden", "ja"): return "レジャー（穴場）"
        case ("cancelButton", "ja"): return "キャンセル"
        case ("welcomeSpoken", "ja"): return "地域情報の儀式へようこそ。検索またはカテゴリ選択から始めてください。"
        case ("noLocationSpoken", "ja"): return "現在地が取得できません。Wi‑Fi または GPS をご確認ください。"
        case ("searchSpoken", "ja"): return "検索します。"
        case ("categorySpoken", "ja"): return "カテゴリを選んでください。"
        case ("navStartSpoken", "ja"): return "ナビを開始します。到着と帰宅を見守ります。"
        case ("prevSpoken", "ja"): return "前の画面に戻ります。"
        case ("nextSpoken", "ja"): return "次のステップへ進みます。"
        case ("homeSpoken", "ja"): return "メイン画面に戻ります。"
        case ("memoSavedSpoken", "ja"): return "滞在メモを保存しました。"
        case ("memoCanceledSpoken", "ja"): return "滞在メモはキャンセルされました。"

        // 英語
        case ("title", "en"): return "🌏 Local info"
        case ("searchPlaceholder", "en"): return "Search place"
        case ("searchButton", "en"): return "Search"
        case ("favoriteButton", "en"): return "Save favorite"
        case ("favoriteSavedSpoken", "en"): return "Saved to favorites."
        case ("favoriteSelectedSpoken", "en"): return "Selected from favorites."
        case ("unknownPlace", "en"): return "Unknown place"
        case ("transportPickerLabel", "en"): return "Transport"
        case ("categoryButton", "en"): return "Choose category"
        case ("startNavButton", "en"): return "Start navigation"
        case ("prevButton", "en"): return "Back"
        case ("nextButton", "en"): return "Next"
        case ("homeButton", "en"): return "Home"
        case ("helpButton", "en"): return "Help"
        case ("backLabel", "en"): return "Back"
        case ("categoryDialogTitle", "en"): return "Local info categories"
        case ("catGourmet", "en"): return "Gourmet"
        case ("catLeisure", "en"): return "Leisure"
        case ("catMedical", "en"): return "Hospitals & Pharmacies"
        case ("catEvent", "en"): return "Events"
        case ("catGourmetHidden", "en"): return "Gourmet (Hidden)"
        case ("catLeisureHidden", "en"): return "Leisure (Hidden)"
        case ("cancelButton", "en"): return "Cancel"
        case ("welcomeSpoken", "en"): return "Welcome. Start by searching a place or choosing a category."
        case ("noLocationSpoken", "en"): return "Location unavailable. Please check Wi‑Fi or GPS."
        case ("searchSpoken", "en"): return "Searching."
        case ("categorySpoken", "en"): return "Please choose a category."
        case ("navStartSpoken", "en"): return "Starting navigation. I'll watch for arrival and return."
        case ("prevSpoken", "en"): return "Going back."
        case ("nextSpoken", "en"): return "Proceeding to next."
        case ("homeSpoken", "en"): return "Returning to home."
        case ("memoSavedSpoken", "en"): return "Stay memo saved."
        case ("memoCanceledSpoken", "en"): return "Stay memo canceled."

        default:
            return key
        }
    }

    private func helpText(for lang: String) -> String {
        switch lang {
        case "ja":
            return "Googleマップで場所を検索し、カテゴリと交通手段を選んでナビを開始できます。お気に入り保存や到着時の滞在メモ記録にも対応しています。"
        case "en":
            return "Search places on Google Maps, choose category and transport, then start navigation. You can save favorites and record a stay memo on arrival."
        case "fr":
            return "Recherchez des lieux sur Google Maps, choisissez la catégorie et le moyen de transport, puis démarrez la navigation. Favoris et mémo d'arrivée pris en charge."
        case "de":
            return "Suchen Sie Orte auf Google Maps, wählen Sie Kategorie und Verkehrsmittel und starten Sie die Navigation. Favoriten speichern und Ankunftsnotiz möglich."
        case "es":
            return "Busque lugares en Google Maps, elija categoría y transporte, y comience la navegación. Favoritos y notas de llegada compatibles."
        case "zh":
            return "在 Google 地图上搜索地点，选择类别和交通方式并开始导航。支持收藏和到达时记录备注。"
        case "ko":
            return "Google 지도에서 장소를 검색하고, 카테고리와 교통수단을 선택해 내비게이션을 시작하세요. 즐겨찾기 및 도착 메모 기록을 지원합니다."
        case "pt":
            return "Pesquise locais no Google Maps, escolha categoria e transporte e inicie a navegação. Suporta favoritos e memo de chegada."
        case "it":
            return "Cerca luoghi su Google Maps, scegli categoria e trasporto e avvia la navigazione. Supporta preferiti e memo all'arrivo."
        case "hi":
            return "Google Maps पर स्थान खोजें, श्रेणी और परिवहन चुनें और नेविगेशन शुरू करें। पसंदीदा और आगमन पर मेमो रिकॉर्डिंग समर्थित है।"
        case "sv":
            return "Sök platser på Google Maps, välj kategori och transport och starta navigering. Favoriter och ankomstanteckning stöds."
        case "no":
            return "Søk steder på Google Maps, velg kategori og transport og start navigasjon. Favoritter og ankomstnotat støttes."
        default:
            return "Search places on Google Maps, choose category and transport, then start navigation. Favorites and arrival memo supported."
        }
    }
}
