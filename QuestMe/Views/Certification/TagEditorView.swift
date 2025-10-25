//
//  TagEditorView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/TagEditorView.swift
//
//  🎯 ファイルの目的:
//      問題バンク内の問題に付与されたタグを編集・統合する。
//      - タグ一覧表示
//      - タグの追加・削除・リネーム
//      - 保存は ProblemBankService
//

import SwiftUI

struct TagEditorView: View {
    let certificationName: String
    @State private var questions: [BankQuestion] = []
    @State private var selectedQuestion: BankQuestion? = nil
    @State private var newTag: String = ""

    var body: some View {
        VStack {
            Text("🏷 タグ編集: \(certificationName)")
                .font(.title2).bold()

            List {
                ForEach(questions) { q in
                    VStack(alignment: .leading) {
                        Text(q.text).font(.headline)
                        HStack {
                            ForEach(q.tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        Button("編集") { selectedQuestion = q }
                            .buttonStyle(.bordered)
                    }
                }
            }

            Spacer()
        }
        .sheet(item: $selectedQuestion) { q in
            TagEditSheet(certificationName: certificationName, question: q) { updated in
                if let idx = questions.firstIndex(where: { $0.id == updated.id }) {
                    questions[idx] = updated
                    ProblemBankService.merge([updated], into: certificationName)
                }
            }
        }
        .onAppear {
            questions = ProblemBankService.load(for: certificationName)
        }
    }
}

struct TagEditSheet: View {
    let certificationName: String
    @State var question: BankQuestion
    var onSave: (BankQuestion) -> Void

    @State private var newTag: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text(question.text).font(.headline).padding()

                List {
                    ForEach(question.tags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                            Spacer()
                            Button("削除") {
                                question.tags.removeAll { $0 == tag }
                            }
                            .foregroundColor(.red)
                        }
                    }
                }

                HStack {
                    TextField("新しいタグ", text: $newTag)
                        .textFieldStyle(.roundedBorder)
                    Button("追加") {
                        if !newTag.isEmpty {
                            question.tags.append(newTag)
                            newTag = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                Spacer()
            }
            .navigationBarItems(
                leading: Button("閉じる") { dismiss() },
                trailing: Button("保存") {
                    onSave(question)
                    dismiss()
                }
            )
        }
    }

    private func dismiss() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
    }
}
