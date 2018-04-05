import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: QTTextField!
    @IBOutlet weak var displayNameTextField: QTTextField!
    @IBOutlet weak var passwordTextField: QTTextField!
    @IBOutlet weak var repeatPasswordTextField: QTTextField!
    
    @IBOutlet weak var textFieldsViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var separatorViewCenterYConstraint: NSLayoutConstraint!
    
    var keyboardObserver: NSObjectProtocol?
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        displayNameTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                if endFrameValue.cgRectValue.minY == self.view.frame.height {
                    self.logoWidthConstraint.constant = 150
                    self.separatorViewCenterYConstraint.constant = 0
                    self.textFieldsViewCenterYConstraint.constant = 0
                } else {
                    self.logoWidthConstraint.constant = 0
                    self.separatorViewCenterYConstraint.constant = -130
                    self.textFieldsViewCenterYConstraint.constant = -65
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

    @IBAction func registerAction(_ sender: Any) {
        
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            displayNameTextField.becomeFirstResponder()
        } else if textField == displayNameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            repeatPasswordTextField.becomeFirstResponder()
        } else if textField == repeatPasswordTextField {
            repeatPasswordTextField.resignFirstResponder()
        }
        
        return true
    }
}