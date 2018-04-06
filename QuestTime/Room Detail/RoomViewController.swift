import UIKit

class RoomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    var questions: [String] = [
        "Question answer",
        "This is a second question just to see how longer question appear,This is a second question just to see how longer question appear",
        "This is a third question",
        "This is a little longer fourth question"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView.isHidden = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]

        separatorView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionTableViewCell")
    }

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
        cell.questionTextLabel.text = questions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let questionVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: QuestionViewController.self)
        
        questionVC.questionText = questions[indexPath.row]
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
