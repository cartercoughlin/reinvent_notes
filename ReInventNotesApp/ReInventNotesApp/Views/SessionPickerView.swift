import SwiftUI

struct SessionPickerView: View {
    @StateObject private var sessionService = SessionService()
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var themeManager: ReInventThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredSessions: [ReInventSession] {
        if searchText.isEmpty {
            return sessionService.sessions
        }
        return sessionService.sessions.filter { session in
            session.title.localizedCaseInsensitiveContains(searchText) ||
            session.sessionCode.localizedCaseInsensitiveContains(searchText) ||
            session.speakers.joined().localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if sessionService.isLoading {
                    ProgressView("Loading sessions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredSessions) { session in
                        SessionPickerRow(session: session) {
                            createNoteFromSession(session)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search sessions...")
                }
            }
            .navigationTitle("Select Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task { await sessionService.fetchSessions() }
                    }
                    .foregroundColor(themeManager.theme.accentColor)
                }
            }
        }
        .task {
            await sessionService.fetchSessions()
        }
    }
    
    private func createNoteFromSession(_ session: ReInventSession) {
        notesManager.createNewSession(
            title: session.title,
            sessionCode: session.sessionCode,
            speaker: session.speakers.joined(separator: ", "),
            track: session.track
        )
        dismiss()
    }
}

struct SessionPickerRow: View {
    let session: ReInventSession
    let onSelect: () -> Void
    @EnvironmentObject var themeManager: ReInventThemeManager
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(session.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(session.sessionCode)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.theme.accentColor.opacity(0.2))
                        .foregroundColor(themeManager.theme.accentColor)
                        .cornerRadius(8)
                }
                
                if !session.speakers.isEmpty {
                    Text(session.speakers.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(session.track)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !session.level.isEmpty {
                        Text("Level \(session.level)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SessionPickerView()
        .environmentObject(NotesManager())
        .environmentObject(ReInventThemeManager())
}