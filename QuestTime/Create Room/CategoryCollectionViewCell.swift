import UIKit

protocol CategoryCollectionViewCellDelegate: class {
    func categoryCollectionViewCell(_ cell: CategoryCollectionViewCell, didChangeSelectionTo categorySelected: Bool)
}

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    
    let unselectedAlpha: CGFloat = 0.3
    var categorySelected = false
    
    weak var delegate: CategoryCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.categoryImageView.alpha = unselectedAlpha
    }
    
    func toggleSelection() {
        categorySelected = !categorySelected
        
        if categorySelected {
            self.categoryImageView.alpha = 1
        } else {
            self.categoryImageView.alpha = unselectedAlpha
        }
        
        delegate?.categoryCollectionViewCell(self, didChangeSelectionTo: categorySelected)
    }

}
