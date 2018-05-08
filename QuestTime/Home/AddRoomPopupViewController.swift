import UIKit

protocol AddRoomPopupViewControllerDelegate: class {
    func createNewRoomSelected()
}

class AddRoomPopupViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: AddRoomPopupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundTapGesture = UITapGestureRecognizer(target: nil, action: nil)
        backgroundView.addGestureRecognizer(backgroundTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        backgroundView.layer.cornerRadius = 30
        backgroundView.layer.masksToBounds = true
    }
    
    @objc func tapAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func joinPrivateRoomAction(_ sender: Any) {
        
    }
    
    @IBAction func createRoomAction(_ sender: Any) {
        dismiss(animated: false) {
            self.delegate?.createNewRoomSelected()
        }
    }
}
