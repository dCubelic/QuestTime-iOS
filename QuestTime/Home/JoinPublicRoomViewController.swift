import UIKit

protocol JoinPublicRoomViewControllerDelegate: class {
    func backPressed()
    func searchPressed(categories: [Category], roomName: String)
}

class JoinPublicRoomViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var roomNameTextField: UITextField!
    
    var categories: [Category] = [.art, .sport, .physics, .movies, .music, .science, .maths, .general, .geography]
    var selectedCategories: [Category] = []
    
    weak var delegate: JoinPublicRoomViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.masksToBounds = true
        
        roomNameTextField.delegate = self
    }

    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: false) {
            self.delegate?.backPressed()
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        dismiss(animated: false) {
            if let roomName = self.roomNameTextField.text {
                self.delegate?.searchPressed(categories: self.selectedCategories, roomName: roomName)
            }
        }
    }
}

extension JoinPublicRoomViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: CategoryCollectionViewCell.self, for: indexPath)
        
        cell.categoryImageView.image = UIImage(named: categories[indexPath.row].rawValue)
        cell.alpha = cell.unselectedAlpha
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        cell.toggleSelection()
    }
}

extension JoinPublicRoomViewController: CategoryCollectionViewCellDelegate {
    func categoryCollectionViewCell(_ cell: CategoryCollectionViewCell, didChangeSelectionTo categorySelected: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let category = categories[indexPath.row]
        
        if !categorySelected {
            if let selectedCategoryIndex = selectedCategories.index(of: category) {
                selectedCategories.remove(at: selectedCategoryIndex)
            }
        } else {
            selectedCategories.append(category)
        }
        
    }
}

extension JoinPublicRoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
}