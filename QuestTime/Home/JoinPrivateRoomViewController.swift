import UIKit
import FirebaseAuth

protocol JoinPrivateRoomViewControllerDelegate: class {
    func backPressed()
}

class JoinPrivateRoomViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var privateKeyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.beginAnimations(nil, context: nil)
        self.presentingViewController?.presentedViewController?.preferredContentSize = CGSize(width: 220, height: 120)
        UIView.commitAnimations()
    }

    @IBAction func backAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func joinPrivateRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        guard let userUid = Auth.auth().currentUser?.uid, let privateKey = privateKeyTextField.text else { return }
        
        QTClient.shared.joinPrivateRoom(userUid: userUid, privateKey: privateKey) { (error) in
            guard error == nil else {
                self.backgroundView.shake()
                return
            }
            
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
}
