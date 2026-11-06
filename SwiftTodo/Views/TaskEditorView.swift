//
//  TaskEditorView.swift
//  SwiftTodo
//

import SwiftUI

/// Used for both creating (task == nil) and editing a task.
struct TaskEditorView: View {
    private enum Field: Hashable {
        case title
        case description
    }

    let task: TodoTask?
    let onSave: (_ title: String, _ description: String) async throws -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var errorMessage: String?
    @State private var isSaving = false
    @FocusState private var focusedField: Field?

    init(task: TodoTask?, onSave: @escaping (_ title: String, _ description: String) async throws -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.description ?? "")
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Task title", text: $title)
                        .focused($focusedField, equals: .title)
                }
                Section("Description") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(4...10)
                        .focused($focusedField, equals: .description)
                }

                if let errorMessage {
                    Section("Couldn’t Save Task") {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: save) {
                    HStack(spacing: 10) {
                        if isSaving { ProgressView().tint(.white) }
                        Text(isSaving ? "Saving…" : "Save Task")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.bar)
            }
        }
    }

    private func save() {
        guard !isSaving else { return }
        guard canSave else {
            errorMessage = "Enter a task title before saving."
            return
        }

        focusedField = nil
        isSaving = true
        errorMessage = nil
        let newTitle = title
        let newDescription = description

        Task {
            do {
                try await onSave(newTitle, newDescription)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}
