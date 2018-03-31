import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var unansweredView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        cellView.backgroundColor = .white
        
        selectionStyle = .none
        
        cellView.layer.cornerRadius = 15
        cellView.layer.masksToBounds = true
    }
    
    func showUnansweredView() {
        unansweredView.isHidden = false
        pointsLabel.isHidden = true
    }
    
    func hideUnansweredView() {
        unansweredView.isHidden = true
        pointsLabel.isHidden = false
    }
    
}
