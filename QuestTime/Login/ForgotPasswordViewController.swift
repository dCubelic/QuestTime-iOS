import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: QTTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self

    }
    
    @IBAction func resetPasswordAction(_ sender: Any) {
        guard let email = emailTextField.text else {
            emailTextField.shake()
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let _ = error {
                self.emailTextField.shake()
            } else {
                let popup = UIAlertController(title: "Info", message: "Password reset link sent to email.", preferredStyle: .alert)
                popup.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
