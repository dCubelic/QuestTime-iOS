import UIKit

class RoomsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionsLeftTodayNumberLabel: UILabel!
    @IBOutlet weak var questionsLeftTodayLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    let rooms: [String] = ["First Room", "Second Room", "Third Room", "Fourth Room", "Fifth Room"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        underlineView.layer.cornerRadius = 2
        tableView.register(UINib(nibName: "RoomTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomTableViewCell")
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
        
        cell.roomNameLabel.text = rooms[indexPath.row]
        
        if indexPath.row == 0 {
            cell.showUnansweredView()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("touch")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: RoomViewController.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        for cell in tableView.visibleCells as [UITableViewCell] {
//            let point = tableView.convert(cell.center, to: tableView.superview)
//            cell.alpha = ((point.y * 100) / tableView.bounds.maxY) / 100
//        }
//    }
}

extension RoomsViewController: AddRoomPopupViewControllerDelegate {
    func createNewRoomSelected() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: CreateRoomViewController.self)
        present(vc, animated: true, completion: nil)
    }
}



