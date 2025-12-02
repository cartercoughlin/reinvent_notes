import Foundation

struct ReInventSession: Codable, Identifiable {
    let id: String
    let title: String
    let sessionCode: String
    let speakers: [String]
    let track: String
    let description: String
    let startTime: Date?
    let endTime: Date?
    let location: String
    let level: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, sessionCode = "sessionId", speakers, track, description, startTime, endTime, location, level
    }
}

struct SessionsResponse: Codable {
    let sessions: [ReInventSession]
}