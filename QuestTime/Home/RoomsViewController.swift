import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseMessaging

class RoomsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        questionsLeftTodayNumberLabel.adjustsFontSizeToFitWidth = true
        
        underlineView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "RoomTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomTableViewCell")
        
        loadUserRooms()
//        setupNavigationButtons()
    }
    
    private func setupNavigationButtons() {
        let addButton = UIButton(type: .custom)
        addButton.frame = CGRect(x: 50, y: 50, width: 25, height: 44)
        addButton.setImage(#imageLiteral(resourceName: "add"), for: .normal)
        addButton.addTarget(self, action: #selector(addRoomAction(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsAction(_:)), for: .touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 25, height: 100)
        let settingsBarButton = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.leftBarButtonItem = settingsBarButton
    }
    
    private func registerForTopics() {
        guard let notificationsOn = UserDefaults.standard.value(forKey: Constants.UserDefaults.notifications) as? Bool else {
            rooms.forEach { if let uid = $0.uid { Messaging.messaging().subscribe(toTopic: uid ) } }
            return
        }
        
        rooms.forEach { if let uid = $0.uid, notificationsOn { Messaging.messaging().subscribe(toTopic: uid ) } }
    }
    
    @objc private func loadUserRooms() {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        QTClient.shared.loadRoomsForUser(with: userUid) { (rooms) in
            self.rooms = rooms
            self.rooms.sort(by: { (room, room2) -> Bool in
                if room.containsUnansweredQuestion() && !room2.containsUnansweredQuestion() {
                    return true
                }
                if !room.containsUnansweredQuestion() && room2.containsUnansweredQuestion() {
                    return false
                }
                return room.name.lowercased() < room2.name.lowercased()
            })
            self.tableView.reloadData()
            
            self.registerForTopics()
            
            self.questionsLeftTodayNumberLabel.text = String(self.calculateNumberOfQuestionsLeftToday())
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
    
    private func calculateNumberOfQuestionsLeftToday() -> Int {
        var number = 0
        
        rooms.forEach { number += $0.roomQuestions.filter { $0.timestamp > Date() }.count }
        return number
    }
    
    @objc func test() {
        print("test")
    }
    
    @IBAction func addRoomAction(_ sender: Any) {
        guard let button = sender as? UIBarButtonItem else { return }
        Sounds.shared.play(sound: .buttonClick)
        
        let addRoomVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: AddRoomPopupViewController.self)
        addRoomVc.delegate = self
        
        let navVC = UINavigationController(rootViewController: addRoomVc)
        
        navVC.modalPresentationStyle = .popover
        guard let popover = navVC.popoverPresentationController else { return }
        popover.backgroundColor = .qtGray
        popover.delegate = self
        popover.barButtonItem = button
        popover.permittedArrowDirections = .up
        
        present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        guard let button = sender as? UIBarButtonItem else { return }
        Sounds.shared.play(sound: .buttonClick)
        
        let settingsVC = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: SettingsViewController.self)
        
        settingsVC.rooms = self.rooms
        
        settingsVC.modalPresentationStyle = .popover
        guard let popover = settingsVC.popoverPresentationController else { return }
        popover.backgroundColor = .qtGray
        popover.delegate = self
        popover.barButtonItem = button
        popover.permittedArrowDirections = .up
        
        present(settingsVC, animated: true, completion: nil)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .default, title: "Leave") { (_, _) in
            let room = self.rooms[indexPath.row]
            
            let alert = UIAlertController(title: "Leave room?", message: "Are you sure you want to leave '\(room.name)'? All your progress will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                guard let roomUid = room.uid else { return }
                QTClient.shared.leaveRoom(roomUid: roomUid, completion: { } )
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        action.backgroundColor = .qtRed
        
        return [action]
    }
    
}

extension RoomsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        
        if #available(iOS 11.0, *) {
            if tableView.contentSize.height + 160 + view.safeAreaInsets.top < view.frame.height {
                headerViewHeightConstraint.constant = 160
                questionsLeftTodayNumberLabel.font = UIFont.systemFont(ofSize: 100, weight: .black)
                questionsLeftTodayLabel.font = UIFont.systemFont(ofSize: 20, weight: .black)
                return
            }
        } else {
            guard let nbh = navigationController?.navigationBar.frame.height else { return }
            if tableView.contentSize.height + 160 + nbh < view.frame.height {
                headerViewHeightConstraint.constant = 160
                questionsLeftTodayNumberLabel.font = UIFont.systemFont(ofSize: 100, weight: .black)
                questionsLeftTodayLabel.font = UIFont.systemFont(ofSize: 20, weight: .black)
                return
            }
        }
        
        //Scroll up
        if y > 0 {
            UIView.beginAnimations(nil, context: nil)
            
            let height = max(80, headerView.frame.height - y)
            
            headerViewHeightConstraint.constant = height
            questionsLeftTodayNumberLabel.font = UIFont.systemFont(ofSize: max(50, 0.625*height), weight: .black)
            questionsLeftTodayLabel.font = UIFont.systemFont(ofSize: max(10, 0.125*height) , weight: .black)
            
            if headerView.frame.height > 80 {
                resetScrollBounds(scrollView: scrollView)
            }
            
            UIView.commitAnimations()
        } else { //Scroll down
            UIView.beginAnimations(nil, context: nil)
            
            let height = min(160, headerView.frame.height - y)
            
            headerViewHeightConstraint.constant = height
            questionsLeftTodayNumberLabel.font = UIFont.systemFont(ofSize: min(100, 0.625*height), weight: .black)
            questionsLeftTodayLabel.font = UIFont.systemFont(ofSize: min(20, 0.125*height) , weight: .black)
            
            if headerView.frame.height < 160 {
                resetScrollBounds(scrollView: scrollView)
            }
            
            UIView.commitAnimations()
        }
        
    }
    
    private func resetScrollBounds(scrollView: UIScrollView) {
        var scrollBounds = scrollView.bounds
        scrollBounds.origin = CGPoint(x: 0, y: 0)
        scrollView.bounds = scrollBounds
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
