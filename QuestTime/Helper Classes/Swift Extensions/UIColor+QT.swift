import Foundation
import UIKit

extension UIColor {
    
    public class var qtGreen: UIColor {
        return UIColor(red: 54.0/255.0, green: 179.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    }
    
    public class var qtRed: UIColor {
        return UIColor(red: 196.0/255.0, green: 6.0/255.0, blue: 6.0/255.0, alpha: 1.0)
    }
    
    static func from(hashString: String) -> UIColor {
        let hash: Int = hashString.hashValue
        
        let r: Int = (hash & 0xFF0000) >> 16
        let g: Int = (hash & 0x00FF00) >> 8
        let b: Int = (hash & 0x0000FF)
        
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
    
}
