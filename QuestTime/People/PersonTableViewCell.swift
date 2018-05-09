import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(with person: Person, forPlace place: Int) {
        placeLabel.text = "\(place)."
        nameLabel.text = person.displayName
        pointsLabel.text = String(person.points)
    }
    
}
