//
//  EventService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Event/EventService.swift
//
//  🎯 目的:
//      現在地周辺のイベント情報を取得し、録音制限判定に使用。
//      - 外部APIまたはカレンダー連携でイベント情報を取得（ここではモック）
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月18日
//

import Foundation
import CoreLocation

struct NearbyEvent {
    let title: String
    let location: String
    let isOngoing: Bool
}

final class EventService {
    static let shared = EventService()

    func fetchEvents(near location: CLLocationCoordinate2D, completion: @escaping ([NearbyEvent]) -> Void) {
        // ✅ モック実装（実運用では Ticketing API / iOS Calendar 連携）
        let mockEvents = [
            NearbyEvent(title: "映画『未来薬局』上映中", location: "益田シネマ", isOngoing: true),
            NearbyEvent(title: "市民劇団公演", location: "島根劇場", isOngoing: false)
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(mockEvents)
        }
    }
}
