import Foundation
import FirebaseDatabase

enum Difficulty: String {
    case easy, medium, hard
}

enum RoomType: String {
    case privateRoom, publicRoom
}

enum Category: String {
    case art, sport, science, movies, music, general, maths, physics, geography
}

class Room {
    var uid: String?
    var name: String
    var difficulty: Difficulty
    var type: RoomType
    var privateKey: String?
    var people: [Person] = []
    var questions: [Question] = []
    var categories: [Category]
    
    init(name: String, type: RoomType, privateKey: String? = nil, difficulty: Difficulty, categories: [Category]) {
//        self.uid = uid
        self.name = name
        self.type = type
        self.privateKey = privateKey
        self.difficulty = difficulty
        self.categories = categories
    }
    
    init?(with snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any?],
            let roomName = value["roomName"] as? String,
            let categoryStrings = value["categories"] as? [String],
            let difficultyString = value["difficulty"] as? String,
            let typeString = value["type"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.name = roomName
        self.categories = Room.parseCategories(categoryStrings: categoryStrings)
        self.difficulty = Room.parseDifficulty(difficulty: difficultyString)
        self.type = Room.parseType(typeString: typeString)
    }
    
    func add(person: Person) {
        people.append(person)
    }
    
    func toJson() -> [String: Any] {
//        if type == .privateRoom && privateKey == nil {
//            return [:]
//        }
        
        var categoryStrings: [String] = []
        for category in categories {
            categoryStrings.append(category.rawValue)
        }
        
        return [
            "roomName": name,
            "difficulty": difficulty.rawValue,
            "type": type.rawValue,
            "privateKey": privateKey ?? "",
            "categories": categoryStrings,
            "members": people
        ]
    }

    
    private static func parseDifficulty(difficulty: String) -> Difficulty {
        switch difficulty {
        case "easy":
            return .easy
        case "medium":
            return .medium
        case "hard":
            return .hard
        default:
            return .medium
        }
    }
    
    private static func parseCategories(categoryStrings: [String]) -> [Category] {
        var categories: [Category] = []
        
        for category in categoryStrings {
            if let c = Category.init(rawValue: category) {
                categories.append(c)
            }
        }
        
        return categories
    }
    
    private static func parseType(typeString: String) -> RoomType {
        switch typeString {
        case "private":
            return .privateRoom
        case "public":
            return .publicRoom
        default:
            return .publicRoom
        }
    }
}
