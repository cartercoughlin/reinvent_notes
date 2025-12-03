import SwiftUI

struct ContentView: View {
    @StateObject private var notesManager = NotesManager()
    @StateObject private var themeManager = ReInventThemeManager()
    @State private var isTextInputActive = false
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.theme.backgroundColor
                    .ignoresSafeArea()
                
                if notesManager.currentSession != nil {
                    SessionDetailView(session: notesManager.currentSession!, isTextInputActive: $isTextInputActive)
                        .environmentObject(notesManager)
                        .environmentObject(themeManager)
                } else {
                    SessionListView()
                        .environmentObject(notesManager)
                        .environmentObject(themeManager)
                }
            }
            .navigationTitle(notesManager.currentSession?.title ?? "Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if notesManager.currentSession != nil {
                        Button("Back") {
                            notesManager.currentSession = nil
                        }
                        .foregroundColor(themeManager.theme.primaryTextColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if notesManager.currentSession != nil && (isTextInputActive || isEditingTitle) {
                        Button("Done") {
                            if isEditingTitle {
                                if !editedTitle.isEmpty, let session = notesManager.currentSession {
                                    notesManager.updateSessionTitle(session, newTitle: editedTitle)
                                }
                                isEditingTitle = false
                            } else {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme, compact: true))
                    } else if notesManager.currentSession != nil {
                        Button("Edit") {
                            if let session = notesManager.currentSession {
                                editedTitle = session.title
                                isEditingTitle = true
                            }
                        }
                        .foregroundColor(themeManager.theme.primaryTextColor)
                    } else {
                        Button(action: {
                            notesManager.createNewSession(title: "New Session")
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme, compact: true))
                    }
                }
            }
        }
        .alert("Edit Title", isPresented: $isEditingTitle) {
            TextField("Session title", text: $editedTitle)
            Button("Save") {
                if !editedTitle.isEmpty, let session = notesManager.currentSession {
                    notesManager.updateSessionTitle(session, newTitle: editedTitle)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a new title for this session")
        }
    }
}

#Preview {
    ContentView()
}