import SwiftUI

struct NewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var themeManager: ReInventThemeManager
    
    @State private var title = ""
    @State private var sessionCode = ""
    @State private var speaker = ""
    @State private var track = ""

    
    // Common re:Invent tracks
    private let tracks = [
        "Keynote",
        "Breakout Session",
        "Workshop",
        "Chalk Talk",
        "Builder Session",
        "Leadership Session",
        "Partner Session"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Session Title", text: $title)
                    TextField("Session Code (e.g., ARC301)", text: $sessionCode)
                    TextField("Speaker", text: $speaker)
                    
                    Picker("Track", selection: $track) {
                        Text("Select Track").tag("")
                        ForEach(tracks, id: \.self) { track in
                            Text(track).tag(track)
                        }
                    }
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        notesManager.createNewSession(
                            title: title.isEmpty ? "Untitled Session" : title,
                            sessionCode: sessionCode,
                            speaker: speaker,
                            track: track
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.theme.accentColor)
                }
            }
        }
    }
}

#Preview {
    NewSessionView()
        .environmentObject(NotesManager())
        .environmentObject(ReInventThemeManager())
}