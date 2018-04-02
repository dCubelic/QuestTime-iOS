import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonTableViewCell")
    }
    
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PersonTableViewCell.self, for: indexPath)
        
        cell.placeLabel.text = "\(indexPath.row+4)."
        cell.nameLabel.text = "Player"
        cell.pointsLabel.text = "\(max(0,7-indexPath.row))"
    
        return cell
    }
}
