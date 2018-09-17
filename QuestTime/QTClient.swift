import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseMessaging

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
    
    public func loadQuestions(for room: Room, completion: @escaping ([Question]) -> Void) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.questions.observe(.value) { (snapshot) in
            var questions: [Question] = []
            
            for roomQuestion in room.roomQuestions {
                let questionSnapshot = snapshot.childSnapshot(forPath: roomQuestion.category).childSnapshot(forPath: roomQuestion.id)
                if let question = Question(with: questionSnapshot) {
                    question.date = roomQuestion.timestamp
                    question.myAnswer = roomQuestion.answers[currentUserUid]
                    question.myPoints = roomQuestion.points[currentUserUid]
                    question.peopleAnswers = roomQuestion.answers
                    questions.append(question)
                }
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(questions)
        }
    }
    
    public func registerForRoomChange(room: Room, completion: @escaping (Room) -> Void) {
        guard let roomUid = room.uid else { return }
        
        rooms.child(roomUid).observe(.value) { (snapshot) in
            if let room = Room(with: snapshot) {
                completion(room)
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
                            
                            Messaging.messaging().subscribe(toTopic: room.key)
                            
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
        
        Messaging.messaging().subscribe(toTopic: roomUid)
        
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
        
        Messaging.messaging().unsubscribe(fromTopic: roomUid)
        
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
    
    public func people(for room: Room, completion: @escaping ([Person]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        users.observe(.value) { (snapshot) in
            var people: [Person] = []
            
            for personUid in room.peopleUIDs {
                let userSnapshot = snapshot.childSnapshot(forPath: personUid)
                guard let snapshotDict = userSnapshot.value as? [String: Any], let displayName = snapshotDict["username"] as? String else { return }
                
                people.append(Person(uid: personUid, displayName: displayName, points: room.points[personUid] ?? 0))
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(people)
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
            
            if let midnight = Calendar.autoupdatingCurrent.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) {
                if Date() < midnight.addingTimeInterval(-60*60*2) { //2 hours before midnight
                    self.randomQuestionJson(for: room, completion: { (json) in
                        ref.child("questions").setValue(json)
                    })
                }
            }
            
            Messaging.messaging().subscribe(toTopic: ref.key)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let room = Room(with: snapshot) {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(room)
                }
            })
        }
    }
    
    private func randomQuestionJson(for room: Room, completion: @escaping ([String : Any]) -> Void) {
        guard let randomCategory = room.categories.randomElement() else { return }
        
        var roomUids: [String] = []
        
        questions.child(randomCategory.rawValue).observeSingleEvent(of: .value) { (questionsSnapshot) in
            if let questions = questionsSnapshot.value as? [String: Any] {
                for question in questions {
                    if let questionDict = question.value as? [String: Any] {
                        if questionDict["difficulty"] as? String == room.difficulty.rawValue {
                            roomUids.append(question.key)
                        }
                    }
                }
            }
            
            guard let range = Calendar.autoupdatingCurrent.date(bySettingHour: 23, minute: 59, second: 59, of: Date())?.timeIntervalSinceNow, let randomUid = roomUids.randomElement() else { return }
            
            let randomTime = Double(arc4random_uniform(UInt32(range))) + Date().timeIntervalSince1970
            
            let json = [
                randomUid: [
                    "category": randomCategory.rawValue,
                    "timestamp": randomTime
                ]
            ]
            
            completion(json)
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
    
    func randomElement() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
