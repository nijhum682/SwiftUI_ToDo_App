//
//  SwiftTodoApp.swift
//  SwiftTodo
//

import SwiftUI
import FirebaseCore

@main
struct SwiftTodoApp: App {
    @StateObject private var authViewModel: AuthViewModel

    init() {
        // Firebase must be configured before any Auth / Firestore call.
        FirebaseApp.configure()
        _authViewModel = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
