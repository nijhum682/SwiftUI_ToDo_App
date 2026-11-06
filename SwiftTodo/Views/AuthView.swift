//
//  AuthView.swift
//  SwiftTodo
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.tint)
                    Text("Tasks ToDo")
                        .font(.largeTitle.bold())
                    Text("Keep your day organized.")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 28)

                HStack(spacing: 12) {
                    modeButton("Sign In", isSelected: !isSignUp) {
                        isSignUp = false
                        auth.errorMessage = nil
                    }
                    modeButton("Sign Up", isSelected: isSignUp) {
                        isSignUp = true
                        auth.errorMessage = nil
                    }
                }

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)

                    if let message = auth.errorMessage {
                        Text(message)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            if isSignUp {
                                await auth.signUp(email: email, password: password)
                            } else {
                                await auth.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if auth.isLoading {
                                ProgressView()
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(auth.isLoading)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .textFieldStyle(.roundedBorder)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 440)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func modeButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
