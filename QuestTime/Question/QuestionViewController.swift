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
    @IBOutlet weak var firstAnswerLabel: UILabel!
    @IBOutlet weak var secondAnswerLabel: UILabel!
    @IBOutlet weak var thirdAnswerLabel: UILabel!
    @IBOutlet weak var fourthAnswerLabel: UILabel!
    
    weak var delegate: QuestionViewControllerDelegate?
    var answerLabels: [UILabel] = []
    
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
        
        answerLabels = [firstAnswerLabel, secondAnswerLabel, thirdAnswerLabel, fourthAnswerLabel]
        setupLabels()
        
        for label in answerLabels {
            label.layer.cornerRadius = 15
            label.layer.masksToBounds = true
            label.isUserInteractionEnabled = true
            label.tag = 0
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(answerAction(_:)))
            label.addGestureRecognizer(tapGesture)
        }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = view.bounds
        view.insertSubview(visualEffectView, belowSubview: questionView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let label = touch.view as? UILabel {
                label.backgroundColor = UIColor(white: 220.0/255.0, alpha: 1.0)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let label = touch.view as? UILabel {
                label.backgroundColor = .white
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
    
    @objc func answerAction(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel, let room = room, let question = question, let userUid = Auth.auth().currentUser?.uid else { return }
        
        Sounds.shared.play(sound: .buttonClick)
        
        question.myAnswer = label.text
        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionDetailViewController.self)
        
        vc.delegate = self.delegate
        vc.question = question
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        
        QTClient.shared.setAnswer(for: room, question: question, userUid: userUid) {
            self.delegate?.questionViewControllerAnsweredQuestion()
            
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
}
