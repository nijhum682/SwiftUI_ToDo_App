//
//  AuthViewModel.swift
//  SwiftTodo
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    // MARK: - Sign up / Sign in / Sign out

    func signUp(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().createUser(withEmail: email.trimmed, password: password)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    func signIn(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().signIn(withEmail: email.trimmed, password: password)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    // MARK: - Helpers

    private func validate(email: String, password: String) -> Bool {
        if email.trimmed.isEmpty || password.isEmpty {
            errorMessage = "Enter both your email and password."
            return false
        }
        if password.count < 6 {
            errorMessage = "Your password must be at least 6 characters long."
            return false
        }
        return true
    }

    private static func message(for error: Error) -> String {
        let nsError = error as NSError
        if let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .invalidEmail:
                return "Enter a valid email address."
            case .emailAlreadyInUse:
                return "An account already exists for this email."
            case .weakPassword:
                return "That password is too weak. Choose a stronger password."
            case .wrongPassword, .invalidCredential, .userNotFound:
                return "The email or password is incorrect."
            case .networkError:
                return "A network error occurred. Check your internet connection and try again."
            case .tooManyRequests:
                return "Too many attempts. Please try again later."
            default:
                break
            }
        }
        return error.localizedDescription
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
