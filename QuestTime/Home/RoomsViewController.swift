import UIKit
import FirebaseDatabase
import FirebaseAuth

class RoomsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionsLeftTodayNumberLabel: UILabel!
    @IBOutlet weak var questionsLeftTodayLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        underlineView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "RoomTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomTableViewCell")

        loadUserRooms()
    }
    
    private func loadUserRooms() {
        guard let user = Auth.auth().currentUser else { return }
        
        QTClient.shared.loadRoomsForUser(with: user.uid) { (rooms) in
            self.rooms = rooms
            self.tableView.reloadData()
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
        vc.room = rooms[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Leave") { (_, _, completionHandler) in
            
            let room = self.rooms[indexPath.row]
            
            let alert = UIAlertController(title: "Leave room?", message: "Are you sure you want to leave '\(room.name)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                guard let roomUid = room.uid else { return }
                QTClient.shared.leaveRoom(roomUid: roomUid, completion: { } )
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
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: PublicSearchViewController.self)
        
        QTClient.shared.loadPublicRooms(categories: categories, roomName: roomName) { (rooms) in
            vc.rooms = rooms
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
