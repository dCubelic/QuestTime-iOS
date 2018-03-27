import UIKit

class RoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var unansweredView: UIView!
    @IBOutlet weak var firstCategoryImageView: UIImageView!
    @IBOutlet weak var secondCategoryImageView: UIImageView!
    @IBOutlet weak var thirdCategoryImageView: UIImageView!
    
    lazy var zeroWidthConstraint = unansweredView.widthAnchor.constraint(equalToConstant: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        selectionStyle = .none
        
        cellView.layer.cornerRadius = 20
        cellView.clipsToBounds = true
        
        underlineView.layer.cornerRadius = 2
        underlineView.clipsToBounds = true
        
        difficultyView.layer.cornerRadius = 5
        difficultyView.clipsToBounds = true
        
        firstCategoryImageView.image = UIImage(named: "sport")
        secondCategoryImageView.image = UIImage(named: "music")
        thirdCategoryImageView.image = UIImage(named: "physics")
        
        hideUnansweredView()
    }
    
    func showUnansweredView() {
        NSLayoutConstraint.deactivate([zeroWidthConstraint])
    }
    
    func hideUnansweredView() {
        NSLayoutConstraint.activate([zeroWidthConstraint])
    }
    
}
