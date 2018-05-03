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
        
        registerForPushNotifications()
        
        return true
    }
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("Notification permission: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettigns()
        }
    }
    
    private func getNotificationSettigns() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print(settings)
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let deviceTokenString = NSString(format: "%@", deviceToken as CVarArg) as String
//        let pushToken = deviceTokenString.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
//
//        print("PushToken: \(pushToken)")
//    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //TODO: zapisat u userdefault i poslat na server kad se ulogira (ak nije vec)
        print("fcm token: \(fcmToken)")
    }

}

