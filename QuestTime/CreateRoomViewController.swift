import UIKit

enum Difficulty {
    case easy, medium, hard
}

enum RoomType {
    case privateRoom, publicRoom
}

class CreateRoomViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var roomNameTextField: QTTextField!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    
    @IBOutlet weak var easyWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mediumWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hardWidthConstraint: NSLayoutConstraint!
    
    var selectedDifficulty: Difficulty = .medium
    var selectedRoomType: RoomType = .privateRoom
    
    let cellWidth: CGFloat = 25
    let cellInset: CGFloat = 20
    
    var categories: [String] = ["art", "sport", "physics", "movies", "music", "science", "maths", "general", "geography"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        
        easyButton.layer.cornerRadius = 6
        mediumButton.layer.cornerRadius = 6
        hardButton.layer.cornerRadius = 9
    }
    
    @IBAction func difficultyAction(_ sender: UIButton) {
        
        easyWidthConstraint.constant = 12
        mediumWidthConstraint.constant = 12
        hardWidthConstraint.constant = 12
        easyButton.layer.cornerRadius = 6
        mediumButton.layer.cornerRadius = 6
        hardButton.layer.cornerRadius = 6
        easyButton.alpha = 0.3
        mediumButton.alpha = 0.3
        hardButton.alpha = 0.3
        
        switch sender {
        case easyButton:
            easyWidthConstraint.constant = 18
            easyButton.layer.cornerRadius = 9
            selectedDifficulty = .easy
        case mediumButton:
            mediumWidthConstraint.constant = 18
            mediumButton.layer.cornerRadius = 9
            selectedDifficulty = .medium
        case hardButton:
            hardWidthConstraint.constant = 18
            hardButton.layer.cornerRadius = 9
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
        dismiss(animated: true, completion: nil)
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
        
        cell.categoryImageView.image = UIImage(named: categories[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else { return }

        cell.toggleSelection()
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
