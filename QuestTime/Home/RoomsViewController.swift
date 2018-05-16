import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseAuth

class RoomsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionsLeftTodayNumberLabel: UILabel!
    @IBOutlet weak var questionsLeftTodayLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    @IBOutlet weak var headerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    var rooms: [Room] = []
    
    var audioPlayer: AVAudioPlayer?
    var test: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        questionsLeftTodayNumberLabel.adjustsFontSizeToFitWidth = true
        
        underlineView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "RoomTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomTableViewCell")
        
        loadUserRooms()
    }
    
    @objc private func loadUserRooms() {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        QTClient.shared.loadRoomsForUser(with: userUid) { (rooms) in
            self.rooms = rooms
            //TODO: - smislit bolji komparator
            self.rooms.sort { $0.name.lowercased() < $1.name.lowercased() }
            self.tableView.reloadData()
            
            //Broj neodg. pitanja ?
            self.questionsLeftTodayNumberLabel.text = String(rooms.filter({ (room) -> Bool in
                room.peopleUIDs.contains(userUid) &&
                    !(room.roomQuestions.sorted(by: { $0.timestamp > $1.timestamp }).first?.answers.contains(where: { (key, _) -> Bool in
                        key == userUid
                    }) ?? false)
            }).count)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .black), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    @IBAction func addRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        let popupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: AddRoomPopupViewController.self)
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        present(popupVC, animated: false, completion: nil)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        let settingsVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: SettingsViewController.self)
        
        settingsVC.rooms = self.rooms
        
        settingsVC.modalPresentationStyle = .overCurrentContext
        present(settingsVC, animated: false, completion: nil)
    }
    
}

extension RoomsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rooms.count == 0 {
            emptyTableViewLabel.isHidden = false
        } else {
            emptyTableViewLabel.isHidden = true
        }
        
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: RoomTableViewCell.self, for: indexPath)
        
        cell.setup(with: rooms[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Sounds.shared.play(sound: .buttonClick)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: RoomViewController.self)
        vc.room = rooms[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let room = self.rooms[indexPath.row]
            
            let alert = UIAlertController(title: "Leave room?", message: "Are you sure you want to leave '\(room.name)'? All your progress will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                guard let roomUid = room.uid else { return }
                QTClient.shared.leaveRoom(roomUid: roomUid, completion: { } )
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: "Leave") { (_, _, completionHandler) in

            let room = self.rooms[indexPath.row]

            let alert = UIAlertController(title: "Leave room?", message: "Are you sure you want to leave '\(room.name)'? All your progress will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                guard let roomUid = room.uid else { return }
                QTClient.shared.leaveRoom(roomUid: roomUid, completion: { } )
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
            completionHandler(false)
        }
        action.backgroundColor = .qtRed

        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

extension RoomsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        
        if y > 0 {
            headerViewHeightConstraint.constant = max(80, headerView.frame.height - y)
            
            questionsLeftTodayNumberLabel.font = UIFont.systemFont(ofSize: max(40, 0.810810*headerView.frame.height - 24.864864), weight: .black)
            questionsLeftTodayLabel.font = UIFont.systemFont(ofSize: max(12, 0.0675675*headerView.frame.height + 6.594594) , weight: .black)
            
            if headerView.frame.height > 80 {
                
                var scrollBounds = scrollView.bounds
                scrollBounds.origin = CGPoint(x: 0, y: 0)
                scrollView.bounds = scrollBounds
                
            }
        } else {
            headerViewHeightConstraint.constant = min(154, headerView.frame.height - y)
            
            questionsLeftTodayNumberLabel.font = UIFont.systemFont(ofSize: min(100, 0.675675*headerView.frame.height - 4.054054), weight: .black)
            questionsLeftTodayLabel.font = UIFont.systemFont(ofSize: min(17, 0.0675675*headerView.frame.height + 6.594594) , weight: .black)
            
            if headerView.frame.height < 154 {
                var scrollBounds = scrollView.bounds
                scrollBounds.origin = CGPoint(x: 0, y: 0)
                scrollView.bounds = scrollBounds
            }
        }
        
    }
    
}

extension RoomsViewController: AddRoomPopupViewControllerDelegate {
    func createNewRoomSelected() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: CreateRoomViewController.self)
        vc.delegate = self
        
        present(vc, animated: true, completion: nil)
    }
    
    func joinPrivateRoomSelected() {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: JoinPrivateRoomViewController.self)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: false, completion: nil)
    }
    
    func joinPublicRoomSelected() {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: JoinPublicRoomViewController.self)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: false, completion: nil)
    }
}

extension RoomsViewController: JoinPrivateRoomViewControllerDelegate {
    func backPressed() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: AddRoomPopupViewController.self)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
}

extension RoomsViewController: CreateRoomViewControllerDelegate {
    func didCreate(room: Room) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: RoomViewController.self)
        vc.room = room
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoomsViewController: JoinPublicRoomViewControllerDelegate {
    func searchPressed(categories: [Category], roomName: String) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: PublicSearchViewController.self)
        
        QTClient.shared.loadRooms(filter: { (room) -> Bool in
            return room.type == .publicRoom &&
                !room.peopleUIDs.contains(userUid) &&
                (roomName.isEmpty || room.name.lowercased().contains(roomName.lowercased())) &&
                room.categories.hasAtLeastOneSameElementAs(array: categories)
        }) { (rooms) in
            vc.rooms = rooms
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
