import Foundation

enum Difficulty {
    case easy, medium, hard
}

enum RoomType {
    case privateRoom, publicRoom
}

enum Category: String {
    case art, sport, science, movies, music, general, maths, physics, geography
}

class Room {
    var uid: String
    var name: String
    var difficulty: Difficulty
    var type: RoomType
    var privateKey: String?
    var people: [String] = []
    var questions: [Question] = []
    var categories: [Category]
    
    init(uid: String, name: String, type: RoomType, privateKey: String? = nil, difficulty: Difficulty, categories: [Category]) {
        self.uid = uid
        self.name = name
        self.type = type
        self.privateKey = privateKey
        self.difficulty = difficulty
        self.categories = categories
    }
}
