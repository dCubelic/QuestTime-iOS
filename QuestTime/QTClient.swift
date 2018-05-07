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
    
    public func loadQuestion(with id: String, category: String, completion: @escaping (Question) -> Void ) {
        questions.child(category).child(id).observe(.value) { (snapshot) in
            if let question = Question(with: snapshot) {
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
    
    
    
}
