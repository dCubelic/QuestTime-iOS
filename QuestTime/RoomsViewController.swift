import UIKit

class RoomsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionsLeftTodayNumberLabel: UILabel!
    @IBOutlet weak var questionsLeftTodayLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    let rooms: [String] = ["First Room", "Second Room", "Third Room", "Fourth Room", "Fifth Room"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RoomTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomTableViewCell")
    }

    @IBAction func addRoomAction(_ sender: Any) {
    }
    
    @IBAction func settingsAction(_ sender: Any) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell", for: indexPath) as! RoomTableViewCell
        
        cell.roomNameLabel.text = rooms[indexPath.row]
        
        if indexPath.row == 0 {
            cell.showUnansweredView()
        }
        
        return cell
    }
}
