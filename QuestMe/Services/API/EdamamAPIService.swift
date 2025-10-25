//
//  EdamamAPIService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/API/EdamamAPIService.swift
//
//  🎯 ファイルの目的:
//      Edamamサーバ（Mac上の中継サーバ）に接続し、栄養解析結果を取得する。
//      - APIキーはサーバ側で保持（アプリには埋め込まない）
//      - QuestMe 側は JSON を受け取るだけ
//

import Foundation

struct EdamamNutritionResult: Codable {
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
}

final class EdamamAPIService {
    static let shared = EdamamAPIService()
    private init() {}

    func analyzeRecipe(text: String, completion: @escaping (Result<EdamamNutritionResult, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/analyze") else { return } // Mac上のサーバ
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["text": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(EdamamNutritionResult.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
