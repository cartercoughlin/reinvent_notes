# re:Invent Notes App

A SwiftUI app for taking comprehensive notes during AWS re:Invent conference sessions.

## Features

- **Session Management**: Create and organize notes by conference session
- **Rich Note Taking**:
  - Text notes with timestamps
  - In-line photo capture
  - Drawing/sketching capabilities
  - Tap to expand images and drawings for full-screen viewing
  - Pinch-to-zoom on expanded images
- **AWS re:Invent Theming**: Uses official AWS brand colors and styling
- **Data Persistence**: Notes saved to device storage and persist between app launches
- **Session Details**: Track session codes, speakers, and tracks
- **Intuitive Editing**: Tap the "Edit" button to modify session titles

## Project Structure

```
ReInventNotesApp/
├── Models/
│   └── SessionNote.swift          # Core data models
├── Views/
│   ├── SessionNotesView.swift     # Main notes interface
│   ├── SessionDetailView.swift    # Individual session view
│   ├── NewSessionView.swift       # Session creation form
│   ├── SessionListView.swift      # Session browser
│   ├── CameraView.swift          # Photo capture
│   └── DrawingView.swift         # Drawing interface
├── Services/
│   └── NotesManager.swift        # Data persistence & management
├── Theme/
│   └── ReInventTheme.swift       # AWS brand styling
└── Assets.xcassets/              # App icons and colors
    └── AppIcon.appiconset/        # Custom app icon (all iOS sizes)
```

## Usage

1. Open the project in Xcode
2. Build and run on iOS device or simulator
3. Create a new session with session details
4. Take notes using text, photos, and drawings
5. Switch between sessions using the Sessions tab

## Data Storage

Notes are automatically saved to the device's Documents directory as JSON files, ensuring persistence across app launches and device restarts.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Camera access for photo capture

## App Icon

The app includes a complete set of app icons for all iOS device sizes and display densities, located in `Assets.xcassets/AppIcon.appiconset/`. The icon set includes sizes from 16x16 up to 1024x1024 pixels for App Store submission.