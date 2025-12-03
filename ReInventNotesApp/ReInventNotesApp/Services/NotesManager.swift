import Foundation
import UIKit

class NotesManager: ObservableObject {
    @Published var sessions: [SessionNote] = []
    @Published var currentSession: SessionNote?
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var notesFileURL: URL {
        documentsPath.appendingPathComponent("reinvent_notes.json")
    }
    
    init() {
        loadNotes()
    }
    
    func createNewSession(title: String, sessionCode: String = "", speaker: String = "", track: String = "") {
        let newSession = SessionNote(title: title, sessionCode: sessionCode, speaker: speaker, track: track)
        sessions.append(newSession)
        currentSession = newSession
        saveNotes()
    }
    
    func addTextElement(to session: SessionNote, content: String) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        let position = sessions[index].content.count
        let textElement = TextElement(content: content, position: position)
        sessions[index].content.append(.text(textElement))
        sessions[index].updatedAt = Date()
        
        if currentSession?.id == session.id {
            currentSession = sessions[index]
        }
        
        saveNotes()
    }
    
    func addPhotoElement(to session: SessionNote, imageData: Data, caption: String = "") {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        let position = sessions[index].content.count
        let photoElement = PhotoElement(imageData: imageData, caption: caption, position: position)
        sessions[index].content.append(.photo(photoElement))
        sessions[index].updatedAt = Date()
        
        if currentSession?.id == session.id {
            currentSession = sessions[index]
        }
        
        saveNotes()
    }
    
    func addDrawingElement(to session: SessionNote, paths: [DrawingPath]) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }

        print("Adding drawing with \(paths.count) paths")
        for (i, path) in paths.enumerated() {
            print("Path \(i): \(path.points.count) points, color: \(path.color)")
        }

        let position = sessions[index].content.count
        var drawingElement = DrawingElement(position: position)
        drawingElement.paths = paths
        sessions[index].content.append(.drawing(drawingElement))
        sessions[index].updatedAt = Date()

        if currentSession?.id == session.id {
            currentSession = sessions[index]
        }

        saveNotes()
    }
    
    func updateSessionTitle(_ session: SessionNote, newTitle: String) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        sessions[index].title = newTitle
        sessions[index].updatedAt = Date()
        
        if currentSession?.id == session.id {
            currentSession = sessions[index]
        }
        
        saveNotes()
    }
    
    func updateTextElement(in session: SessionNote, elementId: UUID, newContent: String) {
        guard let sessionIndex = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        guard let elementIndex = sessions[sessionIndex].content.firstIndex(where: { $0.id == elementId }) else { return }
        
        if case .text(var textElement) = sessions[sessionIndex].content[elementIndex] {
            textElement.content = newContent
            sessions[sessionIndex].content[elementIndex] = .text(textElement)
            sessions[sessionIndex].updatedAt = Date()
            
            if currentSession?.id == session.id {
                currentSession = sessions[sessionIndex]
            }
            
            saveNotes()
        }
    }
    
    func deleteNoteElement(in session: SessionNote, elementId: UUID) {
        print("deleteNoteElement called for element: \(elementId)")
        guard let sessionIndex = sessions.firstIndex(where: { $0.id == session.id }) else {
            print("Session not found!")
            return
        }

        print("Found session at index \(sessionIndex), content count: \(sessions[sessionIndex].content.count)")
        sessions[sessionIndex].content.removeAll { $0.id == elementId }
        print("After delete, content count: \(sessions[sessionIndex].content.count)")
        sessions[sessionIndex].updatedAt = Date()

        if currentSession?.id == session.id {
            currentSession = sessions[sessionIndex]
        }

        saveNotes()
    }
    
    func reorderNoteElements(in session: SessionNote, from source: Int, to destination: Int) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        sessions[index].content.move(fromOffsets: IndexSet([source]), toOffset: destination)
        sessions[index].updatedAt = Date()
        
        if currentSession?.id == session.id {
            currentSession = sessions[index]
        }
        
        saveNotes()
    }
    
    func deleteSession(_ session: SessionNote) {
        sessions.removeAll { $0.id == session.id }
        if currentSession?.id == session.id {
            currentSession = nil
        }
        saveNotes()
    }
    
    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: notesFileURL)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    private func loadNotes() {
        guard FileManager.default.fileExists(atPath: notesFileURL.path) else {
            print("Notes file doesn't exist yet, starting with empty sessions")
            sessions = []
            saveNotes() // Create the initial empty file
            return
        }

        do {
            let data = try Data(contentsOf: notesFileURL)
            sessions = try JSONDecoder().decode([SessionNote].self, from: data)
            print("Successfully loaded \(sessions.count) sessions")

            // Debug: Check drawing elements
            for session in sessions {
                for element in session.content {
                    if case .drawing(let drawingElement) = element {
                        print("Loaded drawing with \(drawingElement.paths.count) paths")
                        for (i, path) in drawingElement.paths.enumerated() {
                            print("  Path \(i): \(path.points.count) points")
                        }
                    }
                }
            }
        } catch {
            print("Failed to load notes: \(error)")
            sessions = []
            saveNotes() // Create a fresh file if loading failed
        }
    }
}