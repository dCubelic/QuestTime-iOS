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
        let cell = tableView.dequeueReusableCell(ofType: RoomTableViewCell.self, for: indexPath)
        
        cell.roomNameLabel.text = rooms[indexPath.row]
        
        if indexPath.row == 0 {
            cell.showUnansweredView()
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells as [UITableViewCell] {
            let point = tableView.convert(cell.center, to: tableView.superview)
            cell.alpha = ((point.y * 100) / tableView.bounds.maxY) / 100
        }
    }
}

