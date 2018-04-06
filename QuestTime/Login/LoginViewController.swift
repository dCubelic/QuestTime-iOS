import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var forgotButton: UIButton!
    
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldsViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorViewCenterYConstraint: NSLayoutConstraint!
    
    var keyboardObserver: NSObjectProtocol?
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        separatorView.layer.cornerRadius = 2
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                if endFrameValue.cgRectValue.minY == self.view.frame.height {
                    self.logoWidthConstraint.constant = 200
                    self.separatorViewCenterYConstraint.constant = 0
                    self.textFieldsViewCenterYConstraint.constant = 0
                } else {
                    self.logoWidthConstraint.constant = 0
                    self.separatorViewCenterYConstraint.constant = -200
                    self.textFieldsViewCenterYConstraint.constant = -100
                }
                
                UIView.animate(withDuration: durationValue.doubleValue, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })

    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        Window.main?.showMain()
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.Storyboard.login, bundle: nil).instantiateViewController(ofType: RegisterViewController.self)
        vc.emailText = emailTextField.text
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == passwordTextField else { return true }
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        if newText.count == 0 {
            forgotButton.isHidden = false
        } else {
            forgotButton.isHidden = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
}
