import Foundation

class Question {
    var question: String
    var incorrectAnswers: [String]
    var correctAnswer: String
    var myAnswer: String?
    var isAnswered: Bool = false
    var date = Date()
    var myPoints: Int?
    
    init(question: String, incorrectAnswers: [String], correctAnswer: String) {
        self.question = question
        self.incorrectAnswers = incorrectAnswers
        self.correctAnswer = correctAnswer
    }
}
