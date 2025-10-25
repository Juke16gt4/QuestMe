//
//  RecordFolderView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Record/RecordFolderView.swift
//
//  🎯 ファイルの目的:
//      「議事録_講義」「食事栄養」「運動」などの用途別フォルダーを一覧表示し、記録ファイルにアクセスするビュー。
//      - フォルダーをタップすると、その中の記録ファイル一覧を表示。
//      - ファイルをタップすると開く。🗑ボタンで削除（浄化）可能。
//      - Companion の記録管理画面から呼び出され、ユーザーが記録を振り返り、不要な器を手放す儀式の入口として使用。
//
//  🔗 依存:
//      - FileManager（フォルダー・ファイル操作）
//      - UIApplication.shared.open（ファイル起動）
//      - CompanionOverlay.swift（音声連携予定）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct RecordFolderView: View {
    @State private var folders: [String] = []
    @State private var selectedFolder: String? = nil
    @State private var files: [URL] = []
    @State private var fileToDelete: URL? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack {
                if selectedFolder == nil {
                    List(folders, id: \.self) { folder in
                        Button(folder) {
                            selectedFolder = folder
                            loadFiles(in: folder)
                        }
                    }
                    .navigationTitle("📂 記録フォルダー一覧")
                } else {
                    List {
                        ForEach(files, id: \.self) { file in
                            HStack {
                                Text(file.lastPathComponent)
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()

                                Button("🗑") {
                                    confirmDelete(file: file)
                                }
                                .buttonStyle(.bordered)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(file)
                            }
                        }
                    }
                    .navigationTitle("📁 \(selectedFolder!)")
                    .toolbar {
                        Button("← 戻る") {
                            selectedFolder = nil
                            files = []
                        }
                    }
                }
            }
            .onAppear {
                loadFolders()
            }
            .alert("この記録を削除しますか？", isPresented: $showDeleteAlert, actions: {
                Button("削除", role: .destructive) {
                    deleteFile()
                }
                Button("キャンセル", role: .cancel) {}
            }, message: {
                if let file = fileToDelete {
                    Text(file.lastPathComponent)
                }
            })
        }
    }

    // MARK: - フォルダー一覧取得
    private func loadFolders() {
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderNames = ["議事録_講義", "食事栄養", "運動"]
        folders = folderNames.filter { name in
            let url = baseURL.appendingPathComponent(name)
            return FileManager.default.fileExists(atPath: url.path)
        }
    }

    // MARK: - ファイル一覧取得
    private func loadFiles(in folder: String) {
        let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folder)

        if let contents = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil) {
            files = contents.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        }
    }

    // MARK: - 削除確認
    private func confirmDelete(file: URL) {
        fileToDelete = file
        showDeleteAlert = true
    }

    // MARK: - ファイル削除処理
    private func deleteFile() {
        guard let file = fileToDelete else { return }
        do {
            try FileManager.default.removeItem(at: file)
            files.removeAll { $0 == file }
            print("🗑 記録ファイルを削除しました: \(file.lastPathComponent)")
        } catch {
            print("❌ 削除失敗: \(error.localizedDescription)")
        }
        fileToDelete = nil
    }
}
