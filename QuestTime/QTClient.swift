import Foundation
import FirebaseDatabase
import FirebaseAuth

public enum QTError {
    case privateRoomNotFound
}

public class QTClient {
    
    public static var shared = QTClient()
    
    let database = Database.database()
    let rooms = Database.database().reference(withPath: "rooms")
    let users = Database.database().reference(withPath: "users")
    let questions = Database.database().reference(withPath: "questions")

    public func loadQuestion(with id: String, category: String, date: Date, completion: @escaping (Question) -> Void ) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        questions.child(category).child(id).observe(.value) { (snapshot) in
            if let question = Question(with: snapshot) {
                question.date = date
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(question)
            }
        }
    }
    
    public func loadRooms(filter: @escaping (Room) -> Bool, completion: @escaping ([Room]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var rooms: [Room] = []
        
        self.rooms.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotDict = snapshot.value as? [String: Any] {
                
                for roomSnapshot in snapshotDict {
                    if let room = Room(with: snapshot.childSnapshot(forPath: roomSnapshot.key)) {
                        if filter(room) {
                            rooms.append(room)
                        }
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(rooms)
            }
        }
    }
    
    public func loadRoom(with id: String, completion: @escaping (Room) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        rooms.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let room = Room(with: snapshot) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(room)
            }
        }
    }
    
    public func loadRoomsForUser(with uid: String, completion: @escaping ([Room]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.rooms.observe(.value) { (snapshot) in
            var rooms: [Room] = []
            
            if let snapshotDict = snapshot.value as? [String: Any] {
                
                for roomSnapshot in snapshotDict {
                    if let room = Room(with: snapshot.childSnapshot(forPath: roomSnapshot.key)) {
                        if room.peopleUIDs.contains(uid) {
                            rooms.append(room)
                        }
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(rooms)
            }
        }
    }
    
    public func joinPrivateRoom(userUid: String, privateKey: String, completion: @escaping (QTError?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        rooms.observeSingleEvent(of: .value) { (snapshot) in
            if let rooms = snapshot.value as? [String: Any] {
                
                for room in rooms {
                    if let r = Room(with: snapshot.childSnapshot(forPath: room.key)) {
                        if r.privateKey == privateKey && !r.peopleUIDs.contains(userUid) {
                            self.rooms.child(room.key).child("members").child(userUid).setValue(Date().timeIntervalSince1970)
                            self.users.child(userUid).child("rooms").child(room.key).setValue(true)
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            completion(nil)
                            
                            break
                        }
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(.privateRoomNotFound)
            }
        }
    }
    
    public func joinPublicRoom(userUid: String, roomUid: String, completion: @escaping () -> Void) {
        rooms.child(roomUid).child("members").child(userUid).setValue(Date().timeIntervalSince1970)
        users.child(userUid).child("rooms").child(roomUid).setValue(true)
    
        completion()
    }
    
    public func leaveRoom(roomUid: String, completion: @escaping () -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        rooms.child(roomUid).child("members").observe(.value) { (snapshot) in
            if !snapshot.hasChildren() {
                self.rooms.child(roomUid).removeValue()
            }
        }
        
        users.child("\(userUid)/rooms/\(roomUid)").removeValue()
        rooms.child(roomUid).child("members").child(userUid).removeValue()
        
        rooms.child(roomUid).child("questions").observeSingleEvent(of: .value) { (snapshot) in
            guard let questionsDict = snapshot.value as? [String: Any] else { return }
            
            for question in questionsDict {
                self.rooms.child("\(roomUid)/questions/\(question.key)/answers/\(userUid)").removeValue()
                self.rooms.child("\(roomUid)/questions/\(question.key)/points/\(userUid)").removeValue()
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion()
        }
        
    }
    
    public func setAnswer(for room: Room, question: Question, userUid: String, completion: @escaping () -> Void) {
        guard let roomUid = room.uid, let questionUid = question.uid else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        question.peopleAnswers[userUid] = question.myAnswer
        
        rooms.child("\(roomUid)/questions/\(questionUid)/answers/\(userUid)").setValue(question.myAnswer)
        
        if question.correctAnswer == question.myAnswer {
            rooms.child("\(roomUid)/questions/\(questionUid)/next_points").observeSingleEvent(of: .value) { (snapshot) in
                
                if let nextPoints = snapshot.value as? Int {
                    self.rooms.child("\(roomUid)/questions/\(questionUid)/points/\(userUid)").setValue(nextPoints)
                    question.myPoints = nextPoints
                    let nextNextPoints = nextPoints - 1 < 1 ? 1 : nextPoints - 1
                    self.rooms.child("\(roomUid)/questions/\(questionUid)/next_points").setValue(nextNextPoints)
                } else {
                    self.rooms.child("\(roomUid)/questions/\(questionUid)/points/\(userUid)").setValue(room.peopleUIDs.count)
                    question.myPoints = room.peopleUIDs.count
                    let nextNextPoints = room.peopleUIDs.count - 1 < 1 ? 1 : room.peopleUIDs.count - 1
                    self.rooms.child("\(roomUid)/questions/\(questionUid)/next_points").setValue(nextNextPoints)
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion()
            }
        } else {
            rooms.child("\(roomUid)/questions/\(questionUid)/points/\(userUid)").setValue(0)
            question.myPoints = 0
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion()
        }

    }
    
    public func displayName(for userUid: String, completion: @escaping (String) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        users.child(userUid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let displayName = snapshot.value as? String {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(displayName)
            }
        }
    }
    
    public func createRoom(room: Room, completion: @escaping (Room) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        rooms.childByAutoId().setValue(room.toJson()) { (error, ref) in
            ref.child("members").child(userUid).setValue(Date().timeIntervalSince1970)
            self.users.child(userUid).child("rooms").child(ref.key).setValue(true)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let room = Room(with: snapshot) {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(room)
                }
            })
        }
    }
    
}

extension Array where Element: Equatable {
    func hasAtLeastOneSameElementAs(array: [Element]) -> Bool {
        if array.isEmpty {
            return true
        }
        
        for element in self {
            if array.contains(where: { $0 == element }) {
                return true
            }
        }
        return false
    }
}
