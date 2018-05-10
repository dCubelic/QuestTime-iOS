import Foundation
import FirebaseDatabase

enum Difficulty: String {
    case easy, medium, hard
}

enum RoomType: String {
    case privateRoom, publicRoom
}

public enum Category: String {
    case art, sport, science, movies, music, general, maths, physics, geography
}

struct RoomQuestion {
    var id: String
    var category: String
    var points: [String: Int]
    var timestamp: Date
    var answers: [String: String]
}

public class Room {
    var uid: String?
    var name: String
    var difficulty: Difficulty
    var type: RoomType
    var privateKey: String?
    var peopleUIDs: [String] = []
    var personTimeIntervalJoined: [String: Date] = [:]
//    var questionIDs: [String] = []
    var roomQuestions: [RoomQuestion] = []
    var categories: [Category]
    var points: [String: Int] = [:]
    
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
        
        let questions = (value["questions"] as? [String: Any]) ?? [:]
        let members = (value["members"] as? [String: Double]) ?? [:]
        
        for member in members {
            peopleUIDs.append(member.key)
            personTimeIntervalJoined[member.key] = Date(timeIntervalSince1970: member.value)
        }
        
        self.uid = snapshot.key
        self.name = roomName
        self.categories = Room.parseCategories(categoryStrings: categoryStrings)
        self.difficulty = Room.parseDifficulty(difficulty: difficultyString)
        self.type = Room.parseType(typeString: typeString)
        
        for question in questions {
            if let values = question.value as? [String: Any],
                let category = values["category"] as? String,
                let timestamp = values["timestamp"] as? Double {
                
                let points: [String: Int] = values["points"] as? [String: Int] ?? [:]
                let answers: [String: String] = values["answers"] as? [String: String] ?? [:]
                
                for point in points {
                    self.points[point.key] = (self.points[point.key] ?? 0) + point.value
                }
                
                roomQuestions.append(RoomQuestion(id: question.key, category: category, points: points, timestamp: Date(timeIntervalSince1970: timestamp), answers: answers))
            }
        }
        
        if self.type == .privateRoom {
            guard let privateKey = value["privateKey"] as? String else { return nil }
            self.privateKey = privateKey
        }
    }
    
    func add(personUID: String) {
        peopleUIDs.append(personUID)
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
            "members": peopleUIDs
        ]
    }

    
    private static func parseDifficulty(difficulty: String) -> Difficulty {
        return Difficulty(rawValue: difficulty) ?? .medium
    }
    
    private static func parseCategories(categoryStrings: [String]) -> [Category] {
        var categories: [Category] = []
        
        for category in categoryStrings {
            if let c = Category(rawValue: category) {
                categories.append(c)
            }
        }
        
        return categories
    }
    
    private static func parseType(typeString: String) -> RoomType {
        if typeString == "private" {
            return .privateRoom
        }
        if typeString == "public" {
            return .publicRoom
        }
        return RoomType(rawValue: typeString) ?? .publicRoom
    }
}
