//
//  PastExamImportView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/PastExamImportView.swift
//
//  🎯 ファイルの目的:
//      資格ごとの過去問を手動入力またはファイルからインポートし、問題バンクに追加する。
//      - 手動入力フォーム（問題文、正答、解説、難易度、タグ）
//      - CSV/JSONファイルからの一括インポート
//      - 保存先: ProblemBankService
//

import SwiftUI
import UniformTypeIdentifiers

struct PastExamImportView: View {
    let certificationName: String

    @State private var text: String = ""
    @State private var isCorrect: Bool = true
    @State private var explanation: String = ""
    @State private var difficulty: Int = 3
    @State private var tags: String = ""
    @State private var showImporter = false
    @State private var importMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("📥 過去問インポート: \(certificationName)")
                .font(.title2).bold()

            Form {
                Section(header: Text("手動入力")) {
                    TextField("問題文", text: $text)
                    Toggle("正答は○か？", isOn: $isCorrect)
                    TextField("解説", text: $explanation)
                    Stepper("難易度: \(difficulty)", value: $difficulty, in: 1...5)
                    TextField("タグ（カンマ区切り）", text: $tags)

                    Button("追加") {
                        let q = BankQuestion(
                            text: text,
                            correct: isCorrect,
                            explanation: explanation,
                            difficulty: difficulty,
                            tags: tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        )
                        ProblemBankService.merge([q], into: certificationName)
                        importMessage = "1問を追加しました。"
                        clearForm()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section(header: Text("ファイルからインポート")) {
                    Button("CSV/JSONを選択") { showImporter = true }
                        .fileImporter(
                            isPresented: $showImporter,
                            allowedContentTypes: [UTType.json, UTType.commaSeparatedText]
                        ) { result in
                            switch result {
                            case .success(let url):
                                importFromFile(url)
                            case .failure(let error):
                                importMessage = "インポート失敗: \(error.localizedDescription)"
                            }
                        }
                }
            }

            if !importMessage.isEmpty {
                Text(importMessage).foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
    }

    private func clearForm() {
        text = ""
        isCorrect = true
        explanation = ""
        difficulty = 3
        tags = ""
    }

    private func importFromFile(_ url: URL) {
        if url.pathExtension.lowercased() == "json" {
            if let data = try? Data(contentsOf: url),
               let items = try? JSONDecoder().decode([BankQuestion].self, from: data) {
                ProblemBankService.merge(items, into: certificationName)
                importMessage = "\(items.count)問をJSONからインポートしました。"
            }
        } else if url.pathExtension.lowercased() == "csv" {
            if let text = try? String(contentsOf: url) {
                let lines = text.split(separator: "\n")
                var items: [BankQuestion] = []
                for line in lines {
                    let cols = line.split(separator: ",")
                    if cols.count >= 5 {
                        let q = BankQuestion(
                            text: String(cols[0]),
                            correct: cols[1].trimmingCharacters(in: .whitespaces) == "○",
                            explanation: String(cols[2]),
                            difficulty: Int(cols[3]) ?? 3,
                            tags: cols[4].split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                        )
                        items.append(q)
                    }
                }
                ProblemBankService.merge(items, into: certificationName)
                importMessage = "\(items.count)問をCSVからインポートしました。"
            }
        }
    }
}
