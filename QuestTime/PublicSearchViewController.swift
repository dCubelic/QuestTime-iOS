import UIKit

class PublicSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchRoomTableViewCell")
    }

}

extension PublicSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SearchRoomTableViewCell.self, for: indexPath)
        
        cell.setup(with: rooms[indexPath.row])
        
        return cell
    }
}
