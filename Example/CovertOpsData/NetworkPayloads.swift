import Foundation

class TodoPostPayload: Codable {
    let localId: String
    let title: String
    let completed: Bool
    
    private enum CodingKeys: String, CodingKey {
        case localId, title, completed
    }
    
    init(localId: String, title: String, completed: Bool) {
        self.localId = localId
        self.title = title
        self.completed = completed
    }
}

class TodoPayload: Codable {
    let id: Int
    let title: String
    let userId: Int
    let completed: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, title, completed, userId
    }
}

class UserPayload: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: URL
    
    private enum CodingKeys: String, CodingKey {
        case id, name, username, email, phone, website
    }
}
