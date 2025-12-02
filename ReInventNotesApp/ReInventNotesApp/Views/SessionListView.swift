import SwiftUI

struct SessionListView: View {
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var themeManager: ReInventThemeManager
    
    var body: some View {
        List {
            ForEach(notesManager.sessions) { session in
                SessionRowView(session: session)
                    .environmentObject(themeManager)
                    .onTapGesture {
                        notesManager.currentSession = session
                    }
                    .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteSessions)
            .onMove(perform: moveSessions)
        }
        .scrollContentBackground(.hidden)
    }
    
    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            notesManager.deleteSession(notesManager.sessions[index])
        }
    }
    
    private func moveSessions(from source: IndexSet, to destination: Int) {
        notesManager.sessions.move(fromOffsets: source, toOffset: destination)
        notesManager.saveNotes()
    }
}

struct SessionRowView: View {
    let session: SessionNote
    @EnvironmentObject var themeManager: ReInventThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(themeManager.theme.primaryTextColor)
                
                Spacer()
                
                if !session.sessionCode.isEmpty {
                    Text(session.sessionCode)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.theme.cardBackground)
                        .foregroundStyle(themeManager.theme.rainbowGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(themeManager.theme.rainbowGradient, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
            
            if !session.speaker.isEmpty {
                Text(session.speaker)
                    .font(.subheadline)
                    .foregroundColor(themeManager.theme.secondaryTextColor)
            }
            
            HStack {
                if !session.track.isEmpty {
                    Text(session.track)
                        .font(.caption)
                        .foregroundColor(themeManager.theme.secondaryTextColor)
                }
                
                Spacer()
                
                Text("\(session.content.count) notes")
                    .font(.caption)
                    .foregroundColor(themeManager.theme.secondaryTextColor)
                
                Text(session.updatedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(themeManager.theme.secondaryTextColor)
            }
        }
        .padding(16)
        .background(themeManager.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.theme.rainbowGradient, lineWidth: 1)
        )
    }
}

#Preview {
    SessionListView()
        .environmentObject(NotesManager())
        .environmentObject(ReInventThemeManager())
}