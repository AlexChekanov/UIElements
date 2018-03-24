import UIKit
import Styles
import UIExtensions

protocol ProcessCollectionReusableViewDelegate {
    
    func serviceButtonPressed()
}

class ProcessCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Setup
    // Constants
    private let bundle = Bundle(for: StepCollectionViewCell.self)
    static private let constantElementsWidth: CGFloat = 76 + 1
    static private let constantElementsHeight: CGFloat = 56 + 1
    
    // Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var serviceButton: UIButton!
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var serviceView: UIView!
    
    // Input
    var removable: Bool = true
    
    private var title: NSMutableAttributedString? = nil
    private var arrowTintColor: UIColor = .lightGray
    private var addTintColor: UIColor = .lightGray
    private var removeTintColor: UIColor = .lightGray
    private var lockTintColor: UIColor = .darkRed
    private var isEmpty: Bool { return title == nil }
    private var isTheOnlyElement: Bool = false
    private var delegate: ProcessCollectionReusableViewDelegate! = nil
    
    // Styles
    private var acceptableWidthForTextOfOneLine: CGFloat = 60.0
    private var textStyle: TextStyle!
    
    
    // Configuration
    func configure(title: String?,
                   textStyle: TextStyle,
                   arrowTintColor: UIColor,
                   addTintColor: UIColor,
                   lockTintColor: UIColor,
                   delegate: ProcessCollectionReusableViewDelegate,
                   isTheOnlyElement: Bool
        ){
        
        if let title = title { self.title = NSMutableAttributedString(string: title) }
        self.textStyle = textStyle
        self.arrowTintColor = arrowTintColor
        self.addTintColor = addTintColor
        self.delegate = delegate
        self.isTheOnlyElement = isTheOnlyElement
        
        updateViewState()
    }
    
    private func configureTitleLabel() {
        titleLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func configureServiceButton() {
        
        //serviceButton.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        serviceButton.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - Controller
    var viewState: ProcessControl.CollectionState = .normal {
        didSet {
            updateViewState()
        }
    }
    
    // MARK: - CleanUp
    private func cleanUp(){
        serviceButtonState = .hidden
    }
    
    
    // MARK: - States
    // Service button states
    private enum ServiceButtonState {
        
        case arrow
        case add
        case hidden
    }
    
    private var serviceButtonState: ServiceButtonState = .arrow {
        
        didSet {
            
            switch serviceButtonState {
                
            case .arrow:
                serviceButton.setImage(UIImage(named: "arrow", in: bundle, compatibleWith: nil), for: .normal)
                
                switch (isEmpty, isTheOnlyElement) {
                case (false, false): serviceButton.isHidden = false
                default: serviceButton.isHidden = true
                }
                
                serviceButton.tintColor = arrowTintColor
                serviceButton.isUserInteractionEnabled = false
                
            case .add:
                serviceButton.setImage(UIImage(named: "add", in: bundle, compatibleWith: nil), for: .normal)
                serviceButton.isHidden = false
                serviceButton.tintColor = addTintColor
                serviceButton.isUserInteractionEnabled = true
                
            case .hidden:
                serviceButton.setImage(nil, for: .normal)
                serviceButton.isHidden = true
            }
        }
    }
    
    // MARK: - Update
    private func updateServiceButtonState() {
        
        switch viewState {
            
        case .normal:
            serviceButtonState = .arrow
        case .editing:
            serviceButtonState = .add
        case .rearrangement:
            serviceButtonState = .hidden
        }
    }
    
    private func updateTitle () {
        
        title?.applyAttributes(ofStyle: textStyle)
        titleLabel.attributedText = title
    }
    
    private func updateViewState() {
        
        updateServiceButtonState()
        updateTitle()
    }
    
    
    // MARK: - Lifesycle
    override internal func awakeFromNib() {
        super.awakeFromNib()
        
        configureServiceButton()
        configureTitleLabel()
    }
    
    override internal func prepareForReuse() {
        cleanUp()
    }
    
    // MARK: - Instruments
    
    static func getViewSize(for text: String?, height: CGFloat, style: TextStyle, acceptableWidthForTextOfOneLine: CGFloat) -> CGSize {
        
        var viewSize = CGSize(width: constantElementsWidth, height: height)
        
        if let text = text {
            
            let labelMaximumHeight = height - constantElementsHeight
            
            let labelFromTheTextWithOptimalWidth =
                UILabel(text: text, style: style, maximumHeight: labelMaximumHeight, constantElementsWidth: 0, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine)
            
            viewSize.width += labelFromTheTextWithOptimalWidth.bounds.width
        } else { viewSize.width -= 20.0 }
        
        return viewSize
    }
    
    // MARK: - Actions
    @IBAction private func serviceButtonPressed(_ sender: UIButton) {
        
        sender.blink(duration: 0.2)
        delegate.serviceButtonPressed()
    }
}
