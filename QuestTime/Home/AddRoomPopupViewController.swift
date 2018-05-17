import UIKit

protocol AddRoomPopupViewControllerDelegate: class {
    func createNewRoomSelected()
    func joinPrivateRoomSelected()
    func joinPublicRoomSelected()
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
        
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.masksToBounds = true
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = view.bounds
        view.insertSubview(visualEffectView, belowSubview: backgroundView)
    }
    
    @objc func tapAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func joinPublicRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        dismiss(animated: false) {
            self.delegate?.joinPublicRoomSelected()
        }
    }
    
    @IBAction func joinPrivateRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        dismiss(animated: false) {
            self.delegate?.joinPrivateRoomSelected()
        }
    }
    
    @IBAction func createRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        dismiss(animated: false) {
            self.delegate?.createNewRoomSelected()
        }
    }
}
