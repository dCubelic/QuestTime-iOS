import UIKit

protocol JoinPublicRoomViewControllerDelegate: class {
    func backPressed()
    func searchPressed(categories: [Category], roomName: String)
}

class JoinPublicRoomViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var categories: [Category] = [.animals, .art, .celebrities, .entertainment, .general, .geography,
                                  .history, .mythology, .politics, .science, .sports, .vehicles]
    var selectedCategories: [Category] = [] {
        didSet {
            var categoriesString = ""
            for (index, c) in selectedCategories.enumerated() {
                categoriesString += c.rawValue
                if index != selectedCategories.count - 1 {
                    categoriesString += ", "
                }
            }
            categoriesLabel.text = categoriesString
            
            adjustViewSize()
        }
    }
    
    weak var delegate: AddRoomPopupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameTextField.delegate = self
        
        categoriesLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustViewSize()
    }
    
    private func adjustViewSize() {
        UIView.beginAnimations(nil, context: nil)
        if let categoriesString = categoriesLabel.text {
            self.presentingViewController?.presentedViewController?.preferredContentSize = CGSize(width: 250, height: 262+categoriesString.height(withConstrainedWidth: collectionView.frame.width, font: UIFont.systemFont(ofSize: 12.0)))
        }
        UIView.commitAnimations()
    }
    
    @IBAction func backAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        Sounds.shared.play(sound: .buttonClick)
        
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
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        Sounds.shared.play(sound: .buttonClick)
        
        UIView.beginAnimations(nil, context: nil)
        categoriesLabel.frame.height
        self.presentingViewController?.presentedViewController?.preferredContentSize = CGSize(width: 250, height: 280)
        UIView.commitAnimations()
        
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
