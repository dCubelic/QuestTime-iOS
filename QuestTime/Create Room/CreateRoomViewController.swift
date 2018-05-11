import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol CreateRoomViewControllerDelegate: class {
    func didCreate(room: Room)
}

class CreateRoomViewController: UIViewController {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var roomNameTextField: QTTextField!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var easyWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mediumWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hardWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: CreateRoomViewControllerDelegate?
    
    var selectedDifficulty: Difficulty = .medium
    var selectedRoomType: RoomType = .privateRoom
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
        }
    }
    
    let cellWidth: CGFloat = 25
    let cellInset: CGFloat = 25
    
    private let selectedDifficultyWidth: CGFloat = 24
    private let unselectedDifficultyWidth: CGFloat = 18
    
    var categories: [Category] = [.animals, .art, .celebrities, .entertainment, .general, .geography,
                                 .history, .mythology, .politics, .science, .sports, .vehicles]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        separatorView.layer.cornerRadius = 2
        
        easyButton.layer.cornerRadius = unselectedDifficultyWidth / 2
        mediumButton.layer.cornerRadius = unselectedDifficultyWidth / 2
        hardButton.layer.cornerRadius = selectedDifficultyWidth / 2
        
        roomNameTextField.delegate = self
        
        doneButton.isEnabled = false
        doneButton.alpha = 0.3
        
        categoriesLabel.text = ""
    }
    
    
    @IBAction func difficultyAction(_ sender: UIButton) {
        
        easyWidthConstraint.constant = unselectedDifficultyWidth
        mediumWidthConstraint.constant = unselectedDifficultyWidth
        hardWidthConstraint.constant = unselectedDifficultyWidth
        easyButton.layer.cornerRadius = unselectedDifficultyWidth / 2
        mediumButton.layer.cornerRadius = unselectedDifficultyWidth / 2
        hardButton.layer.cornerRadius = unselectedDifficultyWidth / 2
        easyButton.alpha = 0.3
        mediumButton.alpha = 0.3
        hardButton.alpha = 0.3
        
        switch sender {
        case easyButton:
            easyWidthConstraint.constant = selectedDifficultyWidth
            easyButton.layer.cornerRadius = selectedDifficultyWidth / 2
            selectedDifficulty = .easy
        case mediumButton:
            mediumWidthConstraint.constant = selectedDifficultyWidth
            mediumButton.layer.cornerRadius = selectedDifficultyWidth / 2
            selectedDifficulty = .medium
        case hardButton:
            hardWidthConstraint.constant = selectedDifficultyWidth
            hardButton.layer.cornerRadius = selectedDifficultyWidth / 2
            selectedDifficulty = .hard
        default:
            return
        }
        
        sender.alpha = 1
    }
    
    @IBAction func roomTypeAction(_ sender: UIButton) {
        switch sender {
        case privateButton:
            publicButton.alpha = 0.6
            publicButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)
            selectedRoomType = .privateRoom
        case publicButton:
            privateButton.alpha = 0.6
            privateButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)
            selectedRoomType = .publicRoom
        default:
            return
        }
        
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .black)
        sender.alpha = 1
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        guard let roomName = roomNameTextField.text else { return }
        
        let room: Room
        if selectedRoomType == .publicRoom {
            room = Room(name: roomName , type: selectedRoomType, difficulty: selectedDifficulty, categories: selectedCategories)
        } else {
            let privateKey = String.random(length: 8)
            room = Room(name: roomName, type: selectedRoomType, privateKey: privateKey, difficulty: selectedDifficulty, categories: selectedCategories)
        }
        
        Database.database().reference(withPath: "rooms").childByAutoId().setValue(room.toJson()) { (error, ref) in
            guard let user = Auth.auth().currentUser else { return }
            
            ref.child("members").child(user.uid).setValue(true)
//            ref.child("members").observe(.childRemoved, with: { (snapshot) in
//                print(snapshot)
//                print(snapshot.children)
//                if !snapshot.hasChildren() {
//                    ref.removeValue()
//                }
//            })
            
            Database.database().reference(withPath: "users/\(user.uid)/rooms").child(ref.key).setValue(true)
            
            self.dismiss(animated: true, completion: {
                self.delegate?.didCreate(room: room)
            })
        }
    }
    
}

extension CreateRoomViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //        return numberOfSections()
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return numberOfCellsIn(section: section)
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: CategoryCollectionViewCell.self, for: indexPath)
        
        cell.categoryImageView.image = UIImage(named: categories[indexPath.row].rawValue)
        cell.alpha = cell.unselectedAlpha
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }
        
        if cell.categorySelected || selectedCategories.count < 3 {
            cell.toggleSelection()
        }
        
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        if section == numberOfSections() - 1 { //last section
    //            let difNum = CGFloat((maxNumberOfCellsInSection() - numberOfCellsIn(section: section)))
    //            let inset = CGFloat((difNum * cellWidth + (difNum - 1) * cellInset) / 2)
    //
    //            return UIEdgeInsets(top: 10, left: inset, bottom: 10, right: inset)
    //        } else {
    //            return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    //        }
    //    }
    //
    //    private func numberOfSections() -> Int {
    //        return Int(ceil(Double(categories.count) / Double(maxNumberOfCellsInSection())))
    //    }
    //
    //    private func maxNumberOfCellsInSection() -> Int {
    //        return Int((collectionView.frame.width + cellInset) / (cellWidth + cellInset))
    //    }
    //
    //    private func numberOfCellsIn(section: Int) -> Int {
    //        let max = maxNumberOfCellsInSection()
    //
    //        if section * max + max < categories.count {
    //            return max
    //        } else {
    //            return categories.count - section*max
    //        }
    //    }
    //
    //    private func convertToIndex(indexPath: IndexPath) -> Int {
    //        return indexPath.section * maxNumberOfCellsInSection() + indexPath.row
    //    }
    
}

extension CreateRoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateRoomViewController: CategoryCollectionViewCellDelegate {
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
        
        doneButton.isEnabled = selectedCategories.count > 0
        doneButton.alpha = selectedCategories.count > 0 ? 1 : 0.3
    }
}
