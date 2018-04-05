import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = Window()
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

}

