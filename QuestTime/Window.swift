import UIKit
import FirebaseAuth
import UserNotifications

private class WindowContainerViewController: UIViewController {
    
    fileprivate var child: UIViewController? = nil {
        didSet {
            if let oldViewController = oldValue {
                if oldViewController.presentedViewController != nil {
                    oldViewController.dismiss(animated: false, completion: nil)
                }
                oldViewController.willMove(toParentViewController: nil)
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParentViewController()
            }
            
            if let newViewController = child {
                addChildViewController(newViewController)
                view.addSubview(newViewController.view)
                newViewController.view.frame = view.bounds
                newViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                newViewController.view.alpha = 0.8
                
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .transitionFlipFromLeft, animations: {
                    newViewController.view.alpha = 1
                }) { (finished) in
                    newViewController.didMove(toParentViewController: self)
                }
            }
            
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return child?.preferredStatusBarStyle ?? .lightContent
    }
    
}

class Window: UIWindow {
    
    public static var main: Window?
    
    private var container: WindowContainerViewController
    
    deinit {
        
    }
    
    public init() {
        container = WindowContainerViewController()
        super.init(frame: UIScreen.main.bounds)
        rootViewController = container
        
        if Auth.auth().currentUser != nil {
            showMain()
        } else {
            showLogin()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func makeKeyAndVisible() {
        super.makeKeyAndVisible()
        
        Window.main = self
    }
    
    public func getContainerChild() -> UIViewController? {
        return container.child
    }
    
    public func showLogin(loginMessage: String? = nil) {
        if container.child is LoginViewController {
            return
        }
        
        guard let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() else { return }
        
        container.child = viewController
    }
    
    public func showMain() {
        if container.child is RoomsViewController {
            return
        }
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else { return }
        
        container.child = viewController
        
        registerForPushNotifications()
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
}

