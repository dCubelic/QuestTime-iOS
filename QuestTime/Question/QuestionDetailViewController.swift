import UIKit

class QuestionDetailViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var firstPercentageLabel: UILabel!
    @IBOutlet weak var secondPercentageLabel: UILabel!
    @IBOutlet weak var thirdPercentageLabel: UILabel!
    @IBOutlet weak var fourthPercentageLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var firstAnswerLabel: UILabel!
    @IBOutlet weak var secondAnswerLabel: UILabel!
    @IBOutlet weak var thirdAnswerLabel: UILabel!
    @IBOutlet weak var fourthAnswerLabel: UILabel!
    
    weak var delegate: QuestionViewControllerDelegate?
    var answerLabels: [UILabel] = []
    
    var question: Question?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        questionView.layer.cornerRadius = 20
        questionView.layer.masksToBounds = true
        
        underlineView.layer.cornerRadius = 2
        underlineView.layer.masksToBounds = true
        
        answerLabels = [firstAnswerLabel, secondAnswerLabel, thirdAnswerLabel, fourthAnswerLabel]
        setupUI()
        
        for label in answerLabels {
            label.layer.cornerRadius = 15
            label.layer.masksToBounds = true
        }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = view.bounds
        view.insertSubview(visualEffectView, belowSubview: questionView)
    }
    
    private func setupUI() {
        guard let question = question else { return }
        
        setupLabels()
        
        answerLabels.first { $0.text == question.myAnswer }?.backgroundColor = .qtRed
        answerLabels.first { $0.text == question.myAnswer}?.textColor = .white
        answerLabels.first { $0.text == question.correctAnswer}?.backgroundColor = .qtGreen
        answerLabels.first { $0.text == question.correctAnswer}?.textColor = .white
        
        if question.myAnswer == question.correctAnswer {
            correctLabel.textColor = .qtGreen
            correctLabel.text = "Correct!"
            pointsLabel.textColor = .qtGreen
        } else {
            correctLabel.textColor = .qtRed
            correctLabel.text = "Wrong!"
            pointsLabel.textColor = .qtRed
        }
        
        if let points = question.myPoints {
            pointsLabel.text = String(points)
        }
        
        var numberOfAnswers: [String: Int] = [:]
        var answerCount = 0
        question.peopleAnswers.values.forEach({ (answer) in
            if let number = numberOfAnswers[answer] {
                numberOfAnswers[answer] = number + 1
            } else {
                numberOfAnswers[answer] = 1
            }
            answerCount += 1
        })
        
        if answerCount == 0 {
            return
        }
        
        let percentageLabels = [firstPercentageLabel, secondPercentageLabel, thirdPercentageLabel, fourthPercentageLabel]
        
        for index in 0...3 {
            if let number = numberOfAnswers[question.answers[index]] {
                percentageLabels[index]?.text = String(format: "%.1f%%", Double(number) / Double(answerCount) * 100)
            } else {
                percentageLabels[index]?.text = "0.0%"
            }
        }
    }
    
    private func setupLabels() {
        guard let question = question else { return }
        
        questionLabel.text = question.question
        
        answerLabels[0].text = question.answers[0]
        answerLabels[1].text = question.answers[1]
        answerLabels[2].text = question.answers[2]
        answerLabels[3].text = question.answers[3]
    }
    
    @objc func tapAction() {
        delegate?.questionViewControllerWillDismiss()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        delegate?.questionViewControllerWillDismiss()
        dismiss(animated: false, completion: nil)
    }
}
