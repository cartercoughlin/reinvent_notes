import Foundation
import UIKit

struct SessionNote: Codable, Identifiable {
    let id = UUID()
    var title: String
    var sessionCode: String
    var speaker: String
    var track: String
    var content: [NoteElement]
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, sessionCode: String = "", speaker: String = "", track: String = "") {
        self.title = title
        self.sessionCode = sessionCode
        self.speaker = speaker
        self.track = track
        self.content = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum NoteElement: Codable, Identifiable {
    case text(TextElement)
    case photo(PhotoElement)
    case drawing(DrawingElement)
    
    var id: UUID {
        switch self {
        case .text(let element): return element.id
        case .photo(let element): return element.id
        case .drawing(let element): return element.id
        }
    }
}

struct TextElement: Codable, Identifiable {
    let id = UUID()
    var content: String
    var timestamp: Date
    var position: Int
    
    init(content: String, position: Int) {
        self.content = content
        self.timestamp = Date()
        self.position = position
    }
}

struct PhotoElement: Codable, Identifiable {
    let id = UUID()
    var imageData: Data
    var caption: String
    var timestamp: Date
    var position: Int
    
    init(imageData: Data, caption: String = "", position: Int) {
        self.imageData = imageData
        self.caption = caption
        self.timestamp = Date()
        self.position = position
    }
}

struct DrawingElement: Codable, Identifiable {
    let id = UUID()
    var paths: [DrawingPath]
    var timestamp: Date
    var position: Int
    
    init(position: Int) {
        self.paths = []
        self.timestamp = Date()
        self.position = position
    }
}

struct DrawingPath: Codable {
    var points: [CGPoint]
    var color: String
    var width: Double
}