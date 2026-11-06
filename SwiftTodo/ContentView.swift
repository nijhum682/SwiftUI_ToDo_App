//
//  ContentView.swift
//  SwiftTodo
//

import SwiftUI
import FirebaseAuth

/// Root view: shows the task list when signed in, otherwise the login screen.
struct ContentView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        Group {
            if let user = auth.user {
                TaskListView(userId: user.uid)
                    .id(user.uid) // fresh state if a different user signs in
            } else {
                AuthView()
            }
        }
        .animation(.default, value: auth.user?.uid)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
