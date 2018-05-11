import UIKit

protocol SearchRoomTableViewCellDelegate: class {
    func searchRoomTableViewCellDidPressJoinRoom(_ cell: SearchRoomTableViewCell)
}

class SearchRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
    weak var delegate: SearchRoomTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        selectionStyle = .none
        
        cellView.layer.cornerRadius = 20
        cellView.layer.masksToBounds = true
        
        underlineView.layer.cornerRadius = 2
        underlineView.layer.masksToBounds = true
        
        difficultyView.layer.cornerRadius = 5
        difficultyView.layer.masksToBounds = true
        
        joinButton.backgroundColor = .qtRed
    }
    
    @IBAction func joinAction(_ sender: Any) {
        joinButton.isEnabled = false
        joinButton.backgroundColor = .gray
        delegate?.searchRoomTableViewCellDidPressJoinRoom(self)
    }
    
    func setup(with room: Room) {
        roomNameLabel.text = room.name
        if let uid = room.uid {
            underlineView.backgroundColor = UIColor.from(hashString: uid)
        }
        difficultyView.backgroundColor = difficultyColor(for: room.difficulty)
        peopleLabel.text = "\(room.peopleUIDs.count)"
//        peopleLabel.text = "\(room.peopleUIDs.count) \(room.peopleUIDs.count == 1 ? "person" : "people")"
        setupCategoryImageViews(for: room.categories)
    }
    
    func difficultyColor(for difficulty: Difficulty) -> UIColor {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    func setupCategoryImageViews(for categories: [Category]) {
        let categoryImageViews = [firstImageView, secondImageView, thirdImageView]
        
        for (index, category) in categories.enumerated() {
            categoryImageViews[index]?.image = UIImage(named: category.rawValue)
        }
    }
}
