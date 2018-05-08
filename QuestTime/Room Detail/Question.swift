import Foundation
import FirebaseDatabase

public class Question {
    var uid: String?
    var question: String
    var incorrectAnswers: [String]
    var correctAnswer: String
    var myAnswer: String?
    var isAnswered: Bool = false
    var date = Date()
    var myPoints: Int?
    var answers: [String] = []
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    init(question: String, incorrectAnswers: [String], correctAnswer: String) {
        self.question = question
        self.incorrectAnswers = incorrectAnswers
        self.correctAnswer = correctAnswer
    }
    
    init?(with snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any?],
            let correctAnswer = value["correct_answer"] as? String,
            let question = value["question"] as? String,
            let incorrectAnswers = value["incorrect_answers"] as? [String]
            else { return nil }
        
        self.uid = snapshot.key
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
        
        self.answers = incorrectAnswers
        self.answers.append(correctAnswer)
        self.answers.sort { $0.hash < $1.hash }
    }
    
}
