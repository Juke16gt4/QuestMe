//
//  PostalCodeResolver.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/PostalCodeResolver.swift
//
//  🎯 ファイルの目的:
//      世界中の郵便番号から居住地（国＋州/県＋市区町村）を自動入力する。
//      - Google Places API を基盤とし、Geoapify API を補助として利用。
//      - 日本国内は ZipCloud API を優先利用。
//      - Companion が音声で確認し、UserProfile に保存可能。
//
//  🔗 依存:
//      - URLSession（API通信）
//      - UserProfile.swift（保存先）
//      - SQLStorageManager.swift（永続化）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import Foundation

final class PostalCodeResolver {
    static let shared = PostalCodeResolver()
    private init() {}
    
    // MARK: - Public API
    func resolve(postalCode: String, country: String, completion: @escaping (String?) -> Void) {
        if country.uppercased() == "JP" {
            lookupZipCloud(postalCode: postalCode, completion: completion)
        } else {
            lookupGooglePlaces(postalCode: postalCode, country: country) { region in
                if let region = region {
                    completion(region)
                } else {
                    self.lookupGeoapify(postalCode: postalCode, country: country, completion: completion)
                }
            }
        }
    }
    
    // MARK: - 日本国内: ZipCloud API
    private func lookupZipCloud(postalCode: String, completion: @escaping (String?) -> Void) {
        let urlStr = "https://zipcloud.ibsnet.co.jp/api/search?zipcode=\(postalCode)"
        guard let url = URL(string: urlStr) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first else {
                completion(nil)
                return
            }
            let prefecture = first["address1"] as? String ?? ""
            let city = first["address2"] as? String ?? ""
            let region = prefecture + city
            completion(region.isEmpty ? nil : region)
        }.resume()
    }
    
    // MARK: - Google Places API
    private func lookupGooglePlaces(postalCode: String, country: String, completion: @escaping (String?) -> Void) {
        let apiKey = "<YOUR_GOOGLE_API_KEY>"
        let urlStr = "https://maps.googleapis.com/maps/api/geocode/json?address=\(postalCode)&components=country:\(country)&key=\(apiKey)"
        guard let url = URL(string: urlStr) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first,
                  let components = first["address_components"] as? [[String: Any]] else {
                completion(nil)
                return
            }
            
            var region = ""
            for comp in components {
                if let types = comp["types"] as? [String], let name = comp["long_name"] as? String {
                    if types.contains("administrative_area_level_1") { region = name + region }
                    if types.contains("locality") { region += name }
                }
            }
            completion(region.isEmpty ? nil : region)
        }.resume()
    }
    
    // MARK: - Geoapify API (フォールバック)
    private func lookupGeoapify(postalCode: String, country: String, completion: @escaping (String?) -> Void) {
        let apiKey = "<YOUR_GEOAPIFY_API_KEY>"
        let urlStr = "https://api.geoapify.com/v1/geocode/search?postcode=\(postalCode)&country=\(country)&apiKey=\(apiKey)"
        guard let url = URL(string: urlStr) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let features = json["features"] as? [[String: Any]],
                  let props = features.first?["properties"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            let state = props["state"] as? String ?? ""
            let city = props["city"] as? String ?? ""
            let region = state + city
            completion(region.isEmpty ? nil : region)
        }.resume()
    }
}
