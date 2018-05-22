import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstPointsLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondPointsLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var thirdPointsLabel: UILabel!
    @IBOutlet weak var goldMedal: UIImageView!
    @IBOutlet weak var silverMedal: UIImageView!
    @IBOutlet weak var bronzeMedal: UIImageView!
    
    var room: Room?
    
    var users: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        separatorView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonTableViewCell")
        
        firstPointsLabel.isHidden = true
        secondPointsLabel.isHidden = true
        thirdPointsLabel.isHidden = true
        firstLabel.isHidden = true
        secondLabel.isHidden = true
        thirdLabel.isHidden = true
        
        guard let room = room else { return }
        
        QTClient.shared.registerForRoomChange(room: room) { (room) in
            self.room = room
            self.loadUsers()
        }
    }
    
    private func loadUsers() {
        guard let room = room else { return }
        
        QTClient.shared.people(for: room) { (people) in
            self.users = people
            self.users.sort(by: { (person, person2) -> Bool in
                if person.points == person2.points {
                    return person.displayName.lowercased() < person2.displayName.lowercased()
                }
                return person.points > person2.points
            })
            self.tableView.reloadData()
            self.setupFirstPlaces()
        }
    }
    
    private func setupFirstPlaces() {
        switch users.count {
        case 0:
            break
        case _ where users.count >= 3:
            thirdPointsLabel.text = String(users[2].points)
            thirdLabel.text = users[2].displayName
            thirdPointsLabel.isHidden = false
            thirdLabel.isHidden = false
            fallthrough
        case 2:
            secondPointsLabel.text = String(users[1].points)
            secondLabel.text = users[1].displayName
            secondPointsLabel.isHidden = false
            secondLabel.isHidden = false
            fallthrough
        default:
            firstPointsLabel.text = String(users[0].points)
            firstLabel.text = users[0].displayName
            firstPointsLabel.isHidden = false
            firstLabel.isHidden = false
        }
    }
    
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count - 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PersonTableViewCell.self, for: indexPath)
        
        cell.setup(with: users[indexPath.row + 3], forPlace: indexPath.row + 4)
        
        return cell
    }
}
