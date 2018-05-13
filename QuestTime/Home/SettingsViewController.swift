import UIKit
import FirebaseAuth
import FirebaseMessaging

class SettingsViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.cornerRadius = 30
        backgroundView.layer.masksToBounds = true
        
        let backgroundTapGesture = UITapGestureRecognizer(target: nil, action: nil)
        backgroundView.addGestureRecognizer(backgroundTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        if let soundOn = UserDefaults.standard.value(forKey: Constants.UserDefaults.sound) as? Bool {
            soundSwitch.isOn = soundOn
        } else {
            UserDefaults.standard.setValue(true, forKey: Constants.UserDefaults.sound)
        }
        
        if let notificationsOn = UserDefaults.standard.value(forKey: Constants.UserDefaults.notifications) as? Bool {
            notificationSwitch.isOn = notificationsOn
        } else {
            UserDefaults.standard.setValue(true, forKey: Constants.UserDefaults.notifications)
        }
    }
    
    @objc func tapAction() {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func soundSwitchChanged(_ sender: Any) {
        guard let soundOn = UserDefaults.standard.value(forKey: Constants.UserDefaults.sound) as? Bool else { return }
        
        Sounds.shared.toggleMute()
        UserDefaults.standard.setValue(!soundOn, forKey: Constants.UserDefaults.sound)
    }
    
    @IBAction func notificationsSwitchChanged(_ sender: Any) {
        guard let notificationsOn = UserDefaults.standard.value(forKey: Constants.UserDefaults.notifications) as? Bool else { return }
        
        
        for room in rooms {
            if let roomUid = room.uid {
                if notificationsOn {
                    Messaging.messaging().unsubscribe(fromTopic: roomUid)
                } else {
                    Messaging.messaging().subscribe(toTopic: roomUid)
                }
            }
        }
        
        UserDefaults.standard.setValue(!notificationsOn, forKey: Constants.UserDefaults.notifications)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        do {
            try Auth.auth().signOut()
            Window.main?.showLogin()
        } catch {
            print("error")
        }
    }
}
