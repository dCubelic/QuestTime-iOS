import UIKit
import FirebaseAuth

class PublicSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchRoomTableViewCell")
    }

}

extension PublicSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rooms.count == 0 {
            emptyTableViewLabel.isHidden = false
        } else {
            emptyTableViewLabel.isHidden = true
        }
        
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SearchRoomTableViewCell.self, for: indexPath)
        
        cell.delegate = self
        cell.setup(with: rooms[indexPath.row])
        
        return cell
    }
}

extension PublicSearchViewController: SearchRoomTableViewCellDelegate {
    func searchRoomTableViewCellDidPressJoinRoom(_ cell: SearchRoomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
            let userUid = Auth.auth().currentUser?.uid,
            let roomUid = rooms[indexPath.row].uid
        else { return }
        
        Sounds.shared.play(sound: .buttonClick)
        
        QTClient.shared.joinPublicRoom(userUid: userUid, roomUid: roomUid) {
            cell.joinButton.setTitle("Joined", for: .normal)
        }
    }
}
