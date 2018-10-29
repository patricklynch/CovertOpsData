import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    struct ViewData {
        let title: String
        let textColor: UIColor
        let subtitle: String?
    }
    
    var viewData: ViewData? {
        didSet {
            titleLabel.text = viewData?.title
            titleLabel.textColor = viewData?.textColor
            subtitleLabel.text = viewData?.subtitle
        }
    }
}
