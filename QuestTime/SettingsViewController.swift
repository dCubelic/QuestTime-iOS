import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.cornerRadius = 30
        backgroundView.layer.masksToBounds = true
        
        let backgroundTapGesture = UITapGestureRecognizer(target: nil, action: nil)
        backgroundView.addGestureRecognizer(backgroundTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapAction() {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func soundSwitchChanged(_ sender: Any) {
    }
    
    @IBAction func notificationsSwitchChanged(_ sender: Any) {
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
//        dismiss(animated: false, completion: nil)
    }
}