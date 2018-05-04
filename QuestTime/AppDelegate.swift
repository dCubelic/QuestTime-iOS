import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        window = Window()
        window?.makeKeyAndVisible()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcm token: \(fcmToken)")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference(withPath: "users/\(uid)/registrationToken").setValue(fcmToken)
    }

}

