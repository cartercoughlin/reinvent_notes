import SwiftUI

struct SessionNotesView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var themeManager: ReInventThemeManager
    @State private var showingNewSessionSheet = false
    @State private var isTextInputActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    if let session = notesManager.currentSession {
                        SessionDetailView(session: session, isTextInputActive: $isTextInputActive)
                    } else {
                        EmptySessionView()
                    }
                }
            }
            .navigationTitle("re:Invent Notes")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if notesManager.currentSession != nil {
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                    } else {
                        Button("New Session") {
                            showingNewSessionSheet = true
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewSessionSheet) {
            NewSessionView()
                .environmentObject(notesManager)
                .environmentObject(themeManager)
        }
    }
}

struct EmptySessionView: View {
    @EnvironmentObject var themeManager: ReInventThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(themeManager.theme.rainbowGradient)
            
            Text("No Active Session")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.theme.primaryTextColor)
            
            Text("Create a new session to start taking notes")
                .foregroundColor(themeManager.theme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    SessionNotesView()
        .environmentObject(NotesManager())
        .environmentObject(ReInventThemeManager())
}