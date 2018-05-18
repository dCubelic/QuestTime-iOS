import UIKit

protocol AddRoomPopupViewControllerDelegate: class {
    func createNewRoomSelected()
    func searchPressed(categories: [Category], roomName: String)
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.preferredContentSize = CGSize(width: 220, height: 150)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.beginAnimations(nil, context: nil)
        self.presentingViewController?.presentedViewController?.preferredContentSize = CGSize(width: 220, height: 150)
        UIView.commitAnimations()
    }
    
    @objc func tapAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func joinPublicRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: JoinPublicRoomViewController.self)
        vc.delegate = delegate
        
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func joinPrivateRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(ofType: JoinPrivateRoomViewController.self)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func createRoomAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        dismiss(animated: false) {
            self.delegate?.createNewRoomSelected()
        }
    }
}
