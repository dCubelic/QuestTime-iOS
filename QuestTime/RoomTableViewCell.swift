import UIKit

class RoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        cellView.layer.cornerRadius = 8
        cellView.clipsToBounds = false
        cellView.backgroundColor = .clear
    }

}
