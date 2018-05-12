import UIKit
import FirebaseDatabase
import FirebaseAuth

class RoomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    @IBOutlet weak var privateKeyViewHeightConstraint: NSLayoutConstraint!
    
    var refreshControl = UIRefreshControl()
    
    var room: Room?
    var questions: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView.isHidden = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]
        NotificationCenter.default.addObserver(self, selector: #selector(loadQuestions), name: Notification.Name(Constants.Notifications.receivedNotification), object: nil)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .white
        tableView.addSubview(refreshControl)
        
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionTableViewCell")
        
        privateKeyViewHeightConstraint.constant = 0
        separatorView.layer.cornerRadius = 2
        
        privateKeyLabel.isHidden = room?.type == .publicRoom
        lockImageView.isHidden = room?.type == .publicRoom
        privateKeyViewHeightConstraint.isActive = room?.type == .publicRoom
        
        privateKeyLabel.text = room?.privateKey
        title = room?.name
        
        loadQuestions()
    }
    
    @objc func refresh() {
        guard let roomUid = room?.uid else { return }
        
        QTClient.shared.loadRoom(with: roomUid) { (room) in
            self.room = room
            self.loadQuestions()
        }
    }
    
    @objc private func loadQuestions() {
        guard let room = room, let uid = room.uid , let currentUserUid = Auth.auth().currentUser?.uid else { return }
        self.questions = []
        
        QTClient.shared.loadRoom(with: uid) { (room) in
            
            for (index, roomQuestion) in room.roomQuestions.enumerated() {
                QTClient.shared.loadQuestion(with: roomQuestion.id, category: roomQuestion.category, date: roomQuestion.timestamp) { (question) in
                    if question.date > room.personTimeIntervalJoined[currentUserUid] ?? Date() && question.date < Date() {
                        question.myAnswer = roomQuestion.answers[currentUserUid]
                        question.myPoints = roomQuestion.points[currentUserUid]
                        question.peopleAnswers = roomQuestion.answers
                        self.questions.append(question)
                    }
                    
                    if index == room.roomQuestions.count - 1 {
                        self.questions.sort { $0.date > $1.date }
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
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
        Sounds.shared.play(sound: .buttonClick)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: PeopleViewController.self)
        vc.room = room
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if questions.count == 0 {
            emptyTableViewLabel.isHidden = false
        } else {
            emptyTableViewLabel.isHidden = true
        }
        
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: QuestionTableViewCell.self, for: indexPath)
        
        cell.setup(with: questions[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Sounds.shared.play(sound: .buttonClick)
        
        let questionDetailVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionDetailViewController.self)
        questionDetailVC.question = questions[indexPath.row]
        questionDetailVC.delegate = self

        let questionVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionViewController.self)
        questionVC.question = questions[indexPath.row]
        questionVC.room = room
        questionVC.delegate = self
        
        let navVC: UINavigationController
        if questions[indexPath.row].myPoints == nil {
            navVC = UINavigationController(rootViewController: questionVC)
        } else {
            navVC = UINavigationController(rootViewController: questionDetailVC)
        }
        
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .overCurrentContext
        
        present(navVC, animated: false) {
            self.shadowView.isHidden = false
        }
        
    }
}

extension RoomViewController: QuestionViewControllerDelegate {
    func questionViewControllerAnsweredQuestion() {
        loadQuestions()
    }
    
    func questionViewControllerWillDismiss() {
        shadowView.isHidden = true
    }
}
