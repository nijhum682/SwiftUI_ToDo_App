//
//  TaskListView.swift
//  SwiftTodo
//

import SwiftUI

private enum TaskSegment: String, CaseIterable {
    case active = "Active"
    case completed = "Completed"
}

struct TaskListView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var viewModel: TaskViewModel

    @State private var showingNewTask = false
    @State private var taskToEdit: TodoTask?
    @State private var selectedSegment: TaskSegment = .active

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: TaskViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        Picker("Tasks", selection: $selectedSegment) {
                            ForEach(TaskSegment.allCases, id: \.self) { segment in
                                Text(segment.rawValue).tag(segment)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        if visibleTasks.isEmpty {
                            ContentUnavailableView(
                                selectedSegment == .active ? "No Active Tasks" : "No Completed Tasks",
                                systemImage: selectedSegment == .active ? "checklist" : "checkmark.circle",
                                description: Text(selectedSegment == .active
                                                  ? "Tap the plus button to add a task."
                                                  : "Tasks you complete will appear here.")
                            )
                        } else {
                            taskList
                        }
                    }
                }
            }
            .navigationTitle("Tasks ToDo")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out", role: .destructive) {
                        viewModel.stopListening()
                        auth.signOut()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTask) {
                TaskEditorView(task: nil) { title, description in
                    try await viewModel.addTask(title: title, description: description)
                }
            }
            .sheet(item: $taskToEdit) { task in
                TaskEditorView(task: task) { title, description in
                    try await viewModel.updateTask(task, title: title, description: description)
                }
            }
            .alert("Error",
                   isPresented: Binding(get: { viewModel.errorMessage != nil },
                                        set: { if !$0 { viewModel.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
    }

    private var taskList: some View {
        List {
            ForEach(visibleTasks) { task in
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        Task { await viewModel.toggleCompletion(task) }
                    } label: {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(task.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                            .strikethrough(task.isCompleted)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)

                        if !task.description.isEmpty {
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
                .onTapGesture { taskToEdit = task }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await viewModel.deleteTask(task) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private var visibleTasks: [TodoTask] {
        viewModel.tasks.filter { $0.isCompleted == (selectedSegment == .completed) }
    }
}
