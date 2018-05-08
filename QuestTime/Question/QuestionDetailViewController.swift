import UIKit

class QuestionDetailViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var firstAnswerButton: UIButton!
    @IBOutlet weak var secondAnswerButton: UIButton!
    @IBOutlet weak var thirdAnswerButton: UIButton!
    @IBOutlet weak var fourthAnswerButton: UIButton!
    
    @IBOutlet weak var underlineView: UIView!
    
    weak var delegate: QuestionViewControllerDelegate?
    var answerButtons: [UIButton] = []
    
    var question: Question?
//    var answers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        questionView.layer.cornerRadius = 20
        questionView.layer.masksToBounds = true
        
        underlineView.layer.cornerRadius = 2
        underlineView.layer.masksToBounds = true
        
        answerButtons = [firstAnswerButton, secondAnswerButton, thirdAnswerButton, fourthAnswerButton]
        setupUI()
        
        answerButtons.forEach { (button) in
            button.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
        for button in answerButtons {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
        }
        
    }
    
    private func setupUI() {
        setupLabels()
        
        answerButtons.first { $0.title(for: .normal) == question?.myAnswer }?.backgroundColor = .red
        answerButtons.first { $0.title(for: .normal) == question?.correctAnswer}?.backgroundColor = .green
        
        if question?.myAnswer == question?.correctAnswer {
            correctLabel.textColor = .green
            correctLabel.text = "Correct!"
        } else {
            correctLabel.textColor = .red
            correctLabel.text = "Wrong!"
        }
        
        if let points = question?.myPoints {
            pointsLabel.text = String(points)
        }
        
        //percentages
        //people ?
    }
    
    private func setupLabels() {
        guard let question = question else { return }
        
        questionLabel.text = question.question
        
        answerButtons[0].setTitle(question.answers[0], for: .normal)
        answerButtons[1].setTitle(question.answers[1], for: .normal)
        answerButtons[2].setTitle(question.answers[2], for: .normal)
        answerButtons[3].setTitle(question.answers[3], for: .normal)
    }
    
    @objc func tapAction() {
        delegate?.questionViewControllerWillDismiss()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        delegate?.questionViewControllerWillDismiss()
        dismiss(animated: false, completion: nil)
    }
}
