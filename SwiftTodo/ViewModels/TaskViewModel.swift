//
//  TaskViewModel.swift
//  SwiftTodo
//

import Foundation
import Combine
import FirebaseFirestore

/// Handles all Firestore CRUD for the signed-in user's tasks.
/// Stores tasks in the top-level `tasks` collection, scoped by `userId`.
@MainActor
final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let userId: String
    private var listener: ListenerRegistration?

    init(userId: String) {
        self.userId = userId
    }

    private var collection: CollectionReference {
        db.collection("tasks")
    }

    // MARK: - Read (real-time)

    func startListening() {
        guard listener == nil else { return }
        isLoading = true

        listener = collection
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.tasks = (snapshot?.documents.compactMap { TodoTask(document: $0) } ?? [])
                    .sorted { $0.createdAt > $1.createdAt }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Create

    func addTask(title: String, description: String) async throws {
        let task = TodoTask(userId: userId,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            description: description.trimmingCharacters(in: .whitespacesAndNewlines))
        try await collection.document(task.id).setData(task.firestoreData)
    }

    // MARK: - Update

    func updateTask(_ task: TodoTask, title: String, description: String) async throws {
        try await collection.document(task.id).updateData([
            "title": title.trimmingCharacters(in: .whitespacesAndNewlines),
            "description": description.trimmingCharacters(in: .whitespacesAndNewlines),
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func toggleCompletion(_ task: TodoTask) async {
        do {
            try await collection.document(task.id).updateData([
                "isCompleted": !task.isCompleted,
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteTask(_ task: TodoTask) async {
        do {
            try await collection.document(task.id).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
