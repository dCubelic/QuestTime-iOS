import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var headerView: GradientView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        profileImageView.tintColor = .white
        
//        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Rooms"
//        tableView.search
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.popViewController(animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell", for: indexPath) as! RoomTableViewCell
        cell.selectionStyle = .none
        
        let color: UIColor
        
        switch indexPath.row % 4 {
        case 0:
            color = UIColor(red: 255/255, green: 50/255, blue: 50/255, alpha: 1)
        case 1:
            color = UIColor(red: 255/255, green: 209/255, blue: 15/255, alpha: 1)
        case 2:
            color = UIColor(red: 0/255, green: 92/255, blue: 17/255, alpha: 1)
        case 3:
            color = UIColor(red: 0/255, green: 79/255, blue: 107/255, alpha: 1)
        default:
            color = .white
        }
        
//        cell.colorView.backgroundColor = color
        
        return cell
    }
}
