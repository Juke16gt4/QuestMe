//
//  MannersAPIManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/MannersAPIManager.swift
//
//  🎯 ファイルの目的:
//      GPS/WiFiから取得した位置情報に基づき、国・地域のマナー情報をAPI経由で取得。
//      API取得に失敗した場合はローカル辞書（JSON）にフォールバック。
//      Companionのマナー儀式に統合可能な構造で、EmotionType連携・履歴記録・ジオフェンシング・発音練習にも対応。
//
//  🔗 依存:
//      - CoreLocation
//      - EmotionType.swift
//      - CompanionSpeechBubbleView.swift
//      - default_manners.json（ローカル辞書）
//
//  👤 製作者: 津村 淳一
//  📅 改変日: 2025年10月13日
//

import Foundation
import CoreLocation

// MARK: - マナー項目構造
struct RegionManners: Codable {
    let country: String
    let region: String
    let language: String
    let manners: [String: MannersItem]
}

struct MannersItem: Codable {
    let summary: String
    let emotion: String
}

// MARK: - マナーAPIマネージャ
class MannersAPIManager {
    static let shared = MannersAPIManager()
    private let fallbackFile = "default_manners.json"

    // マナー取得（API → フォールバック）
    func fetchManners(for location: CLLocationCoordinate2D, completion: @escaping (RegionManners?) -> Void) {
        let country = resolveCountry(from: location)
        let region = resolveRegion(from: location)

        guard let url = URL(string: "https://api.questme.ai/manners?country=\(country)&region=\(region)") else {
            completion(loadFallbackManners())
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(RegionManners.self, from: data)
                    completion(decoded)
                } catch {
                    completion(self.loadFallbackManners())
                }
            } else {
                completion(self.loadFallbackManners())
            }
        }.resume()
    }

    // ローカル辞書読み込み
    private func loadFallbackManners() -> RegionManners? {
        guard let path = Bundle.main.path(forResource: fallbackFile, ofType: nil),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let decoded = try? JSONDecoder().decode(RegionManners.self, from: data) else {
            return nil
        }
        return decoded
    }

    // 仮の国名取得（逆ジオコーディングに置き換え可能）
    private func resolveCountry(from location: CLLocationCoordinate2D) -> String {
        return "Japan"
    }

    // 仮の地域名取得（逆ジオコーディングに置き換え可能）
    private func resolveRegion(from location: CLLocationCoordinate2D) -> String {
        return "Masuda"
    }

    // ジオフェンシング警告（寺院・病院など）
    func checkGeofence(for location: CLLocationCoordinate2D) {
        let sensitiveZones = [
            ("寺院", CLLocationCoordinate2D(latitude: 34.67, longitude: 131.85)),
            ("病院", CLLocationCoordinate2D(latitude: 34.66, longitude: 131.86))
        ]
        for (label, zone) in sensitiveZones {
            let distance = location.distance(to: zone)
            if distance < 100 {
                CompanionOverlay.shared.speak("現在 \(label) に近づいています。マナーにご注意ください。")
            }
        }
    }

    // 発音練習（現地語）
    func practicePhrase(_ phrase: String, language: String) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }

    // 理解済みマナー記録
    func markMannerAsUnderstood(_ key: String) {
        var understood = UserDefaults.standard.stringArray(forKey: "understoodManners") ?? []
        if !understood.contains(key) {
            understood.append(key)
            UserDefaults.standard.set(understood, forKey: "understoodManners")
        }
    }

    // 理解済みかどうか確認
    func isMannerUnderstood(_ key: String) -> Bool {
        let understood = UserDefaults.standard.stringArray(forKey: "understoodManners") ?? []
        return understood.contains(key)
    }
}

// MARK: - 距離計算（ジオフェンシング用）
extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
}
