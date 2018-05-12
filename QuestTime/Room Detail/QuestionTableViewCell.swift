import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var unansweredView: UIView!
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd. MMM yyyy. HH:mm"
        return df
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        cellView.backgroundColor = .white
        
        selectionStyle = .none
        
        cellView.layer.cornerRadius = 15
        cellView.layer.masksToBounds = true
        
        unansweredView.backgroundColor = .qtRed
    }
    
    func showUnansweredView() {
        unansweredView.isHidden = false
        pointsLabel.isHidden = true
    }
    
    func hideUnansweredView() {
        unansweredView.isHidden = true
        pointsLabel.isHidden = false
    }
    
    func setup(with question: Question) {
        questionTextLabel.text = question.question
        dateLabel.text = dateFormatter.string(from: question.date)
        
        if let points = question.myPoints {
            pointsLabel.text = String(points)
            hideUnansweredView()
        } else {
            showUnansweredView()
        }
    
    }
    
}
