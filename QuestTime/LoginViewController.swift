import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.borderColor = UIColor(red: 0/255, green: 79/255, blue: 107/255, alpha: 1).cgColor
        registerButton.layer.borderColor = UIColor(red: 0/255, green: 79/255, blue: 107/255, alpha: 1).cgColor
        
        loginButton.layer.borderWidth = 2
        registerButton.layer.borderWidth = 2
        loginButton.layer.cornerRadius = 20
        registerButton.layer.cornerRadius = 20
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        print("register")
    }
    
}
