import Foundation

class SessionService: ObservableObject {
    @Published var sessions: [ReInventSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchSessions() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        await MainActor.run {
            self.sessions = []
            self.isLoading = false
        }
    }
}