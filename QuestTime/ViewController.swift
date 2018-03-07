import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var headerView: GradientView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderView.layer.shadowColor = UIColor.black.cgColor
        borderView.layer.shadowOpacity = 1
        borderView.layer.shadowOffset = CGSize.zero
        borderView.layer.shadowRadius = 10
        borderView.clipsToBounds = false

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
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell", for: indexPath) as! RoomTableViewCell
        cell.selectionStyle = .none
        return cell
    }
}
