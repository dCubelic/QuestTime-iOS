import UIKit

protocol CategoryCollectionViewCellDelegate: class {
    func categoryCollectionViewCell(_ cell: CategoryCollectionViewCell, didChangeSelectionTo categorySelected: Bool)
}

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    
    let unselectedAlpha: CGFloat = 0.3
    
    weak var delegate: CategoryCollectionViewCellDelegate?

    var categorySelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.alpha = unselectedAlpha
    }
    
    func toggleSelection() {
        categorySelected = !categorySelected
        
        if categorySelected {
            self.alpha = 1
        } else {
            self.alpha = unselectedAlpha
        }
        
        delegate?.categoryCollectionViewCell(self, didChangeSelectionTo: categorySelected)
    }

}
