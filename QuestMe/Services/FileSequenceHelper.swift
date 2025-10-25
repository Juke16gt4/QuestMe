//
//  FileSequenceHelper.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/FileSequenceHelper.swift
//
//  🎯 ファイルの目的:
//      指定フォルダに「当日分の連番ファイル名」を発行する。
//      - 形式: yyyyMMdd_NN.md（NNは01〜）
//
//  🔗 依存: なし
//

import Foundation

struct FileSequenceHelper {
    static func nextDailySequenceFileName(in folder: URL, ext: String = "md") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let datePrefix = formatter.string(from: Date())

        // 既存の当日ファイルを走査して最大番号＋1
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        let todays = files.filter { $0.lastPathComponent.hasPrefix(datePrefix) && $0.pathExtension.lowercased() == ext }
        let maxSeq = todays.compactMap { url -> Int? in
            let name = url.deletingPathExtension().lastPathComponent // yyyyMMdd_NN
            let comps = name.split(separator: "_")
            guard comps.count == 2, let n = Int(comps[1]) else { return nil }
            return n
        }.max() ?? 0
        let next = String(format: "%02d", maxSeq + 1)
        return "\(datePrefix)_\(next).\(ext)"
    }
}
