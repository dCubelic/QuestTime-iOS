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
