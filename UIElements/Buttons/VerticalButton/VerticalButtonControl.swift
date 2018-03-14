import UIKit

@IBDesignable
class VerticalButtonControl: UIControl {
    
    @IBOutlet weak var button: UIButton!
    
    override var tintColor: UIColor! {
        
        didSet {
            button.tintColor = tintColor
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadFromNib()
        button.setTitle(nil, for: UIControlState.normal)
        button.setImage(nil, for: UIControlState.normal)
    }
    
    var padding: CGFloat = 4.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        if let titleSize = button.titleLabel?.sizeThatFits(maxSize), let imageSize = button.imageView?.sizeThatFits(maxSize) {
            let width = ceil(max(imageSize.width, titleSize.width))
            let height = ceil(imageSize.height + titleSize.height + padding)
            
            return CGSize(width: width, height: height)
        }
        
        return super.intrinsicContentSize
    }
    
    override func layoutSubviews() {
        if let image = button.imageView?.image, let title = button.titleLabel?.attributedText {
            let imageSize = image.size
            let titleSize = title.size()
            
            button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + padding), 0.0)
            button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + padding), 0.0, 0.0, -titleSize.width)
        }
        
        super.layoutSubviews()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
    
        sendActions(for: UIControlEvents.touchUpInside)
    }
}
