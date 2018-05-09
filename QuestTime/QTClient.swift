//
//  QTClient.swift
//  QuestTime
//
//  Created by dominik on 07/05/2018.
//  Copyright © 2018 BlabLab. All rights reserved.
//

import Foundation
import FirebaseDatabase

public class QTClient {
    
    public static var shared = QTClient()
    
    let database = Database.database()
    let rooms = Database.database().reference(withPath: "rooms")
    let users = Database.database().reference(withPath: "users")
    let questions = Database.database().reference(withPath: "questions")
    
    public func loadQuestion(with id: String, category: String, date: Date, completion: @escaping (Question) -> Void ) {
        questions.child(category).child(id).observe(.value) { (snapshot) in
            if let question = Question(with: snapshot) {
                question.date = date
                completion(question)
            }
        }
    }
    
    public func loadRoomsForUser(with uid: String, completion: @escaping ([Room]) -> Void) {
        users.child(uid).child("rooms").observe(.value) { (snapshot) in
            var rooms: [Room] = []
            
            if let snapshotDict = snapshot.value as? [String: Any] {
                
                for (index, roomID) in snapshotDict.keys.enumerated() {
                    self.loadRoom(with: roomID, completion: { (room) in
                        rooms.append(room)
                        
                        if index == snapshotDict.keys.count - 1 {
                            completion(rooms)
                        }
                    })
                }
                
            } else {
                completion(rooms)
            }
        }
    }
    
    public func loadRoom(with id: String, completion: @escaping (Room) -> Void) {
        rooms.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let room = Room(with: snapshot) {
                completion(room)
            }
        }
    }
    
    public func setAnswer(for room: Room, question: Question, userUid: String, completion: @escaping () -> Void) {
        guard let roomUid = room.uid, let questionUid = question.uid else { return }
        
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
                
                completion()
            }
        } else {
            rooms.child("\(roomUid)/questions/\(questionUid)/points/\(userUid)").setValue(0)
            question.myPoints = 0
            
            completion()
        }

    }
    
    public func displayName(for userUid: String, completion: @escaping (String) -> Void) {
        users.child(userUid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let displayName = snapshot.value as? String {
                completion(displayName)
            }
        }
    }

}
