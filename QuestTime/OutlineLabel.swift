import UIKit

class OutlineLabel: UILabel {

    override func drawText(in rect: CGRect) {
//        let newRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width+4, height: rect.height+4)
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        
        let c = UIGraphicsGetCurrentContext()
        c?.setLineWidth(2)
        c?.setLineJoin(CGLineJoin.round)
        
        c?.setTextDrawingMode(CGTextDrawingMode.strokeClip)
        self.textColor = UIColor(red: 25/255, green: 85/255, blue: 0, alpha: 1)
        super.drawText(in: rect)
        
        c?.setTextDrawingMode(CGTextDrawingMode.fill)
        self.textColor = textColor
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: rect)
        
        self.shadowOffset = shadowOffset
    }


}
