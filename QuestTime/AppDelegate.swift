import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: Window?

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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.receivedNotification), object: nil)
        
        if let roomId = userInfo["roomId"] as? String {
            QTClient.shared.loadRoom(with: roomId) { (room) in
                if let vc = self.window?.getContainerChild() as? UINavigationController {
                    vc.popToRootViewController(animated: false)
                    let pushVc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: RoomViewController.self)
                    pushVc.room = room
                    
                    vc.pushViewController(pushVc, animated: true)
                }
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    
    
}

