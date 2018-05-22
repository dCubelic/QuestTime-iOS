import UIKit
import FirebaseDatabase
import FirebaseAuth

class RoomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    @IBOutlet weak var privateKeyViewHeightConstraint: NSLayoutConstraint!
    
    var refreshControl = UIRefreshControl()
    
    var room: Room?
    var questions: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionTableViewCell")
        
        privateKeyViewHeightConstraint.constant = 0
        separatorView.layer.cornerRadius = 2
        
        privateKeyLabel.isHidden = room?.type == .publicRoom
        lockImageView.isHidden = room?.type == .publicRoom
        privateKeyViewHeightConstraint.isActive = room?.type == .publicRoom
        
        privateKeyLabel.text = room?.privateKey
        title = room?.name
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        privateKeyLabel.isUserInteractionEnabled = true
        privateKeyLabel.addGestureRecognizer(longPressGesture)
        
        guard let room = room else { return }
        
        QTClient.shared.registerForRoomChange(room: room) { (room) in
            self.room = room
            self.loadQuestions()
        }
        
    }
    
    @objc func longPressAction() {
        UIPasteboard.general.string = room?.privateKey
        
        let popup = UIAlertController(title: "Info", message: "Private key copied to clipboard.", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(popup, animated: true, completion: nil)
    }
    
    @objc private func loadQuestions() {
        guard let room = room, let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        QTClient.shared.loadQuestions(for: room) { (questions) in
            self.questions = []
            
            for question in questions {
                if question.date > room.personTimeIntervalJoined[currentUserUid] ?? Date() && question.date < Date() {
                    self.questions.append(question)
                }
            }
            
            self.questions.sort { $0.date > $1.date }
            self.tableView.reloadData()
        }
    }

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

        let questionVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionViewController.self)
        questionVC.question = questions[indexPath.row]
        questionVC.room = room
        
        let navVC: UINavigationController
        if questions[indexPath.row].myPoints == nil {
            navVC = UINavigationController(rootViewController: questionVC)
        } else {
            navVC = UINavigationController(rootViewController: questionDetailVC)
        }
        
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .overCurrentContext
        
        present(navVC, animated: false, completion: nil)
        
    }
}
