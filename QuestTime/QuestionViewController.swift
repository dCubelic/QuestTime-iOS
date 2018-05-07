import UIKit

protocol QuestionViewControllerDelegate: class {
    func questionViewControllerWillDismiss()
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
        answerButtons.sort { _,_ in arc4random() < arc4random() }
        
        for button in answerButtons {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
        }
        
        setupLabels()
    }
    
    private func setupLabels() {
        guard let question = question else { return }
        
        questionLabel.text = question.question
        
        answerButtons.first?.setTitle(question.correctAnswer, for: .normal)
        answerButtons[1].setTitle(question.incorrectAnswers[0], for: .normal)
        answerButtons[2].setTitle(question.incorrectAnswers[1], for: .normal)
        answerButtons[3].setTitle(question.incorrectAnswers[2], for: .normal)
    }
    
    @objc func tapAction() {
        delegate?.questionViewControllerWillDismiss()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func answerAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionDetailViewController.self)
        
        vc.delegate = delegate
        
        //flip transition
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        self.navigationController?.pushViewController(vc, animated: false)
    }

}
