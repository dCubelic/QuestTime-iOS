import UIKit
import FirebaseAuth

protocol JoinPrivateRoomViewControllerDelegate: class {
    func backPressed()
}

class JoinPrivateRoomViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var privateKeyTextField: UITextField!
    
    weak var delegate: JoinPrivateRoomViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.masksToBounds = true
    }
    
    @IBAction func backAction(_ sender: Any) {
        Sounds.shared.playButtonSound()
        
        dismiss(animated: false) {
            self.delegate?.backPressed()
        }
    }
    
    @IBAction func joinPrivateRoomAction(_ sender: Any) {
        Sounds.shared.playButtonSound()
        
        guard let userUid = Auth.auth().currentUser?.uid, let privateKey = privateKeyTextField.text else { return }
        
        QTClient.shared.joinPrivateRoom(userUid: userUid, privateKey: privateKey) {
            self.dismiss(animated: false, completion: nil)
            print(privateKey)
        }
    }
    
    
}
