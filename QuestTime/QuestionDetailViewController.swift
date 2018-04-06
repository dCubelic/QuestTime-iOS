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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        questionView.layer.cornerRadius = 20
        questionView.layer.masksToBounds = true
        
        underlineView.layer.cornerRadius = 2
        underlineView.layer.masksToBounds = true
        
        let answerButtons: [UIButton] = [firstAnswerButton, secondAnswerButton, thirdAnswerButton, fourthAnswerButton]
        
        for button in answerButtons {
            button.layer.cornerRadius = 15
            button.layer.masksToBounds = true
        }
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
