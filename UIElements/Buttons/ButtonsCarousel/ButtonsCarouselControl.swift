import UIKit

public struct ButtonElement {
    
    var title: String?
    var image: UIImage?
    
    public init(title: String?, image: UIImage?) {
        self.title = title
        self.image = image
    }
}

@IBDesignable
public final class ButtonsCarouselControl: UIControl {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    @IBInspectable var style: Int = 5

    private var elementsMarginInCarousel: CGFloat = 2
    
    private var buttonCellIdentifier = "cell"
    
    public var buttonElements: [ButtonElement] = [] {
        
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: buttonCellIdentifier)
    }
    
    private var buttons: [VerticalButtonControl] {
        
        var buttons: [VerticalButtonControl] = []
        
        buttonElements.forEach {
            
            let buttonControl = VerticalButtonControl(frame: CGRect.zero)
            
            if let title = $0.title {
                buttonControl.button.setTitle(title, for: .normal)
                buttonControl.button.titleLabel?.font = UIFont.Prebuilt.getFont(rawValue: style)
            }
            
            if let image = $0.image {
                buttonControl.button.setImage(image, for: .normal)
                buttonControl.button.adjustsImageWhenHighlighted = true
            }
            buttonControl.tintColor = self.tintColor
            
            buttons.append(buttonControl)
         }
        
        return buttons
    }
    
    private func getBiggestButtonSize() -> CGSize {
        
        let maximumWidthts = buttons.flatMap {$0.intrinsicContentSize.width}.sorted(by: >).first
        let maximumHeight = buttons.flatMap {$0.intrinsicContentSize.height}.sorted(by: >).first
        
        return CGSize(width: maximumWidthts ?? 50, height: maximumHeight ?? 50)
    }
    
    override public func layoutSubviews() {
        
        layoutCollectionView()
        super.layoutSubviews()
    }
    
    private func layoutCollectionView() {
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let biggestButtonSize = getBiggestButtonSize()
        
        layout.itemSize = CGSize(width: biggestButtonSize.width + elementsMarginInCarousel*2, height: biggestButtonSize.height + elementsMarginInCarousel*2)
        
        collectionViewHeight.constant = getBiggestButtonSize().height + elementsMarginInCarousel*2
    }
}

extension ButtonsCarouselControl: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return buttonElements.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonCellIdentifier, for: indexPath) as! ButtonCollectionViewCell
        
        // Configure the cell
        let button = buttons[indexPath.row]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: UIControlEvents.touchUpInside)
        cell.contentView.addSubview(button)
        button.layoutAttachAll(margin: elementsMarginInCarousel)

        return cell
    }
    
    @objc private func buttonPressed(sender: UIButton) {
        print(sender.tag)
    }
}

