import UIKit

class CreateRoomViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var roomNameTextField: QTTextField!
    @IBOutlet weak var publicButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    
    var categories: [String] = ["art", "sport", "physics", "movies", "music", "science", "maths", "general", "geography"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        
        easyButton.layer.cornerRadius = 6
        normalButton.layer.cornerRadius = 6
        hardButton.layer.cornerRadius = 9
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: CategoryCollectionViewCell.self, for: indexPath)
        
        cell.categoryImageView.image = UIImage(named: categories[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 30, height: 30)
    }
    
}
