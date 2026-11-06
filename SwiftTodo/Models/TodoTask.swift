//
//  TodoTask.swift
//  SwiftTodo
//

import Foundation
import FirebaseFirestore

/// A single to-do item stored in the top-level `tasks` collection.
struct TodoTask: Identifiable, Equatable {
    var id: String
    var userId: String
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString,
         userId: String,
         title: String,
         description: String = "",
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Build a task from a Firestore document.
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let title = data["title"] as? String,
              let userId = data["userId"] as? String else { return nil }

        self.id = document.documentID
        self.userId = userId
        self.title = title
        self.description = data["description"] as? String ?? ""
        self.isCompleted = data["isCompleted"] as? Bool ?? false
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
    }

    /// Firestore representation.
    var firestoreData: [String: Any] {
        [
            "userId": userId,
            "title": title,
            "description": description,
            "isCompleted": isCompleted,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
}
