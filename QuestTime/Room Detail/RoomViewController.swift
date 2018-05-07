import UIKit
import FirebaseDatabase

class RoomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    
    @IBOutlet weak var privateKeyViewHeightConstraint: NSLayoutConstraint!
    
    var room: Room?
    
    var questions: [Question] = [
//        "Question answer",
//        "This is a second question just to see how longer question appear,This is a second question just to see how longer question appear",
//        "This is a third question",
//        "This is a little longer fourth question"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView.isHidden = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]

        separatorView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionTableViewCell")
        
        privateKeyViewHeightConstraint.constant = 0
        
        privateKeyLabel.isHidden = room?.type == .publicRoom
        lockImageView.isHidden = room?.type == .publicRoom
        privateKeyViewHeightConstraint.isActive = room?.type == .publicRoom
        
        privateKeyLabel.text = room?.privateKey
        title = room?.name
        
        loadQuestions()
    }
    
    private func loadQuestions() {
        guard let room = room, let uid = room.uid else { return }
        
        QTClient.shared.loadRoom(with: uid) { (room) in
            for (index, roomQuestion) in room.roomQuestions.enumerated() {
                QTClient.shared.loadQuestion(with: roomQuestion.id, category: roomQuestion.category) { (question) in
                    self.questions.append(question)
                    
                    if index == room.roomQuestions.count - 1 {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }
    
//    private func loadQuestions() {
//        guard let room = room else { return }
//
//        for questionID in room.questionIDs {
//            questions = []
//
//            Database.database().reference(withPath: "questions/\(questionID)").observe(.value) { (snapshot) in
//                if let question = Question(with: snapshot) {
//                    self.questions.append(question)
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }

    @IBAction func peopleAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: PeopleViewController.self)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: QuestionTableViewCell.self, for: indexPath)
        
        if indexPath.row == 0 {
            cell.showUnansweredView()
        }
        cell.questionTextLabel.text = questions[indexPath.row].question
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let questionVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionViewController.self)
        
        questionVC.question = questions[indexPath.row]
        questionVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: questionVC)
        navVC.setNavigationBarHidden(true, animated: false)
        
        navVC.modalPresentationStyle = .overCurrentContext
        present(navVC, animated: false) {
            self.shadowView.isHidden = false
        }
        
    }
}

extension RoomViewController: QuestionViewControllerDelegate {
    func questionViewControllerWillDismiss() {
        shadowView.isHidden = true
    }
}
