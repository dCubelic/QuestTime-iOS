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
    lazy var categoryImageViews = [firstCategoryImageView, secondCategoryImageView, thirdCategoryImageView]
    
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
        
        firstCategoryImageView.image = nil
        secondCategoryImageView.image = nil
        thirdCategoryImageView.image = nil
        
//        shadowView.layer.masksToBounds = false
//        shadowView.layer.shadowOffset = CGSize.zero
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowOpacity = 0.23
//        shadowView.layer.shadowRadius = 4

        hideUnansweredView()
    }
    
    func showUnansweredView() {
        NSLayoutConstraint.deactivate([zeroWidthConstraint])
        NSLayoutConstraint.activate([unansweredView.widthAnchor.constraint(equalToConstant: 20)])
    }
    
    func hideUnansweredView() {
        NSLayoutConstraint.activate([zeroWidthConstraint])
    }
    
    func setup(with room: Room) {
        roomNameLabel.text = room.name
        underlineView.backgroundColor = .white
        difficultyView.backgroundColor = difficultyColor(for: room.difficulty)
        peopleLabel.text = "\(room.people.count) people"
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
        let categoryImageViews = [firstCategoryImageView, secondCategoryImageView, thirdCategoryImageView]
        
        for (index, category) in categories.enumerated() {
            categoryImageViews[index]?.image = UIImage(named: category.rawValue)
        }
    }
    
}
