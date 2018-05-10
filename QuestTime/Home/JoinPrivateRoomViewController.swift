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
        
        let backgroundTapGesture = UITapGestureRecognizer(target: nil, action: nil)
        backgroundView.addGestureRecognizer(backgroundTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.masksToBounds = true
    }
    
    @objc func tapAction() {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: false) {
            self.delegate?.backPressed()
        }
    }
    
    @IBAction func joinAction(_ sender: Any) {
        guard let userUid = Auth.auth().currentUser?.uid, let privateKey = privateKeyTextField.text else { return }
        
        QTClient.shared.joinPrivateRoom(userUid: userUid, privateKey: privateKey) {
            print(privateKey)
        }
    }
}
