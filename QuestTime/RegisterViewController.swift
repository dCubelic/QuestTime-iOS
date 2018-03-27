import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: QTTextField!
    @IBOutlet weak var displayNameTextField: QTTextField!
    @IBOutlet weak var passwordTextField: QTTextField!
    @IBOutlet weak var repeatPasswordTextField: QTTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        displayNameTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
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
