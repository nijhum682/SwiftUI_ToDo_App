# SwiftUI ToDo App

A to-do list app for iOS built with **SwiftUI** and **Firebase**. Users sign up with email and password, and their tasks sync in real time through Cloud Firestore.

## Features

- Email and password authentication (sign up, sign in, sign out)
- Create, edit, complete, and delete tasks
- Optional description for each task
- Active and Completed tabs
- Real-time sync across devices with Firestore snapshot listeners
- Swipe to delete
- Friendly error messages for common auth problems
- Per-user data protected by Firestore security rules

## Tech Stack

| Area | Technology |
| --- | --- |
| UI | SwiftUI |
| Architecture | MVVM (`ObservableObject` view models) |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Dependency management | Swift Package Manager (`firebase-ios-sdk`) |

## Project Structure

```
SwiftTodo/
├── SwiftTodo/
│   ├── SwiftTodoApp.swift        # App entry point, configures Firebase
│   ├── ContentView.swift         # Switches between auth and task list
│   ├── Models/
│   │   └── TodoTask.swift        # Task model and Firestore mapping
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift   # Sign up, sign in, sign out
│   │   └── TaskViewModel.swift   # Firestore CRUD and live listener
│   └── Views/
│       ├── AuthView.swift        # Sign in / sign up screen
│       ├── TaskListView.swift    # Active and completed task lists
│       └── TaskEditorView.swift  # Create and edit a task
├── firestore.rules               # Firestore security rules
├── firebase.json
└── SwiftTodo.xcodeproj
```

## Getting Started

### Requirements

- macOS with **Xcode 15 or later**
- iOS 17 or later (the app uses `ContentUnavailableView`)
- A Firebase account

### 1. Clone the repository

```bash
git clone https://github.com/nijhum682/SwiftUI_ToDo_App.git
cd SwiftUI_ToDo_App
```

### 2. Set up Firebase

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an **iOS app** and use the same bundle identifier as the Xcode project.
3. Download `GoogleService-Info.plist` and place it in the `SwiftTodo/SwiftTodo/` folder (replace the existing file if present).
4. In **Authentication, Sign-in method**, enable **Email/Password**.
5. In **Firestore Database**, create a database.

### 3. Deploy the security rules

Install the [Firebase CLI](https://firebase.google.com/docs/cli), then run:

```bash
firebase login
firebase deploy --only firestore:rules
```

Or paste the contents of `firestore.rules` into the Rules tab in the Firebase Console.

### 4. Run the app

1. Open `SwiftTodo.xcodeproj` in Xcode.
2. Wait for Swift Package Manager to resolve the Firebase packages.
3. Select a simulator or device and press **Run** (Cmd + R).

## Data Model

Tasks are stored in the top-level `tasks` collection:

| Field | Type | Description |
| --- | --- | --- |
| `userId` | string | UID of the task owner |
| `title` | string | Task title |
| `description` | string | Optional details |
| `isCompleted` | bool | Completion status |
| `createdAt` | timestamp | When the task was created |
| `updatedAt` | timestamp | When the task was last changed |

## Security

Firestore rules make sure a signed-in user can only create, read, update, and delete their own tasks (documents where `userId` matches their auth UID).

## License

This project is open source. Add a license of your choice if you plan to share or reuse it.
