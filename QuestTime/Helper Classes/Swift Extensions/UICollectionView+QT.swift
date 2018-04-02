import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(ofType: T.Type, withIdentifier: String? = nil, for indexPath: IndexPath) -> T {
        let identifier = withIdentifier ?? String(describing: ofType)
        
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Collection view \(self) can't dequeue a cell of type \(ofType) for identifier \(identifier)")

        }
        
        return cell
    }
}
