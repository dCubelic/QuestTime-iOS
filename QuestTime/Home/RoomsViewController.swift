import UIKit
import FirebaseDatabase
import FirebaseAuth

class RoomsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionsLeftTodayNumberLabel: UILabel!
    @IBOutlet weak var questionsLeftTodayLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    var rooms: [Room] = [
//        Room(uid: "g45g5gwtrgsrgsd", name: "First Room", type: .publicRoom, difficulty: .medium, categories: [.maths, .science]),
//        Room(uid: "g3f3v24g42g4v34", name: "Second Room", type: .privateRoom, privateKey: "23FSG498F", difficulty: .hard, categories: [.general]),
//        Room(uid: "g43f34hhfsfsghf", name: "This is a third room name", type: .publicRoom, difficulty: .hard, categories: [.movies, .sport, .music]),
//        Room(uid: "gb45gbtrwtwdtgd", name: "Dummy Room", type: .privateRoom, privateKey: "23FSG498F", difficulty: .medium, categories: [.geography, .art, .science]),
//        Room(uid: "rgb54v4tg4das5g", name: "📚🏀🎨", type: .privateRoom, privateKey: "23FSG498F", difficulty: .easy, categories: [.general, .sport, .art]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        underlineView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "RoomTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomTableViewCell")

        loadUserRooms()
    }
    
    private func loadUserRooms() {
        guard let user = Auth.auth().currentUser else { return }
        
        let userRef = Database.database().reference(withPath: "users/\(user.uid)/rooms")
        let roomsRef = Database.database().reference(withPath: "rooms")
        
        userRef.observe(.value) { (userRoomsSnapshot) in
            self.rooms = []
            
            if let snapshotDictionary = userRoomsSnapshot.value as? [String: Any?] {
                for (index, snapshot) in snapshotDictionary.enumerated() {
                    roomsRef.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let room = Room(with: snapshot) {
                            self.rooms.append(room)
                            
                            if index == snapshotDictionary.count - 1 {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    @IBAction func addRoomAction(_ sender: Any) {
        let popupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: AddRoomPopupViewController.self)
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        present(popupVC, animated: false, completion: nil)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        let settingsVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: SettingsViewController.self)
        settingsVC.modalPresentationStyle = .overCurrentContext
        present(settingsVC, animated: false, completion: nil)
    }
    
}

extension RoomsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: RoomTableViewCell.self, for: indexPath)
        
        cell.setup(with: rooms[indexPath.row])
        
        if indexPath.row == 0 {
            cell.showUnansweredView()
        } else {
            cell.hideUnansweredView()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: RoomViewController.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Leave") { (_, _, completionHandler) in
            
            let room = self.rooms[indexPath.row]
            
            let alert = UIAlertController(title: "Leave room?", message: "Are you sure you want to leave '\(room.name)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                guard let user = Auth.auth().currentUser, let roomUid = room.uid else { return }
                Database.database().reference(withPath: "users/\(user.uid)/rooms/\(roomUid)").removeValue()
                Database.database().reference(withPath: "rooms/\(roomUid)/members/\(user.uid)").removeValue()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            completionHandler(false)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension RoomsViewController: AddRoomPopupViewControllerDelegate {
    func createNewRoomSelected() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: CreateRoomViewController.self)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension RoomsViewController: CreateRoomViewControllerDelegate {
    func didCreate(room: Room) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: RoomViewController.self)
        vc.room = room
        navigationController?.pushViewController(vc, animated: true)
    }
}
