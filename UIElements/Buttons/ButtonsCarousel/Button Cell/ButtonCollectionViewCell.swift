import UIKit

class ButtonCollectionViewCell: UICollectionViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.subviews.forEach {$0.removeFromSuperview()}
    }
}
