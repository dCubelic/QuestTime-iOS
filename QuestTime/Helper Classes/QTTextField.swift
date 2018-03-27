import UIKit

class QTTextField: UITextField {
    
    override func awakeFromNib() {
        self.borderStyle = .none
        
        self.layer.cornerRadius = 15
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }

}
