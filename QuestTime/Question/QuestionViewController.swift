import UIKit
import FirebaseAuth

protocol QuestionViewControllerDelegate: class {
    func questionViewControllerWillDismiss()
    func questionViewControllerAnsweredQuestion()
}

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var firstAnswerButton: UIButton!
    @IBOutlet weak var secondAnswerButton: UIButton!
    @IBOutlet weak var thirdAnswerButton: UIButton!
    @IBOutlet weak var fourthAnswerButton: UIButton!
    
    weak var delegate: QuestionViewControllerDelegate?
    var answerButtons: [UIButton] = []
//    var answers: [String] = []
    
    var room: Room?
    var question: Question?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        questionView.layer.cornerRadius = 20
        questionView.layer.masksToBounds = true
        
        underlineView.layer.cornerRadius = 2
        underlineView.layer.masksToBounds = true
        
        answerButtons = [firstAnswerButton, secondAnswerButton, thirdAnswerButton, fourthAnswerButton]
        setupLabels()
        answerButtons.forEach { (button) in
            button.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
        for button in answerButtons {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
        }

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
    
    @IBAction func answerAction(_ sender: UIButton) {
        question?.myAnswer = sender.title(for: .normal)
        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionDetailViewController.self)
        
        vc.delegate = self.delegate
        vc.question = question
        
        //flip transition
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        
        guard let room = room, let question = question, let userUid = Auth.auth().currentUser?.uid else { return }
        
        QTClient.shared.setAnswer(for: room, question: question, userUid: userUid) {
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
            self.delegate?.questionViewControllerAnsweredQuestion()
        }
        
    }

}
