import UIKit
import Styles
import UIExtensions

protocol StepCollectionViewCellDelegate {
    
    func serviceButtonPressed(at index: Int)
    func removeButtonPressed(at index: Int, removable: Bool)
    func labelDoubleTapped(at index: Int, with gestureRecognizer: UIGestureRecognizer)
}

class StepCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Setup
    // Constants
    private let bundle = Bundle(for: StepCollectionViewCell.self)
    static private let constantElementsWidth: CGFloat = 72 + 1
    
    // Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var serviceButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var serviceView: UIView!
    
    @IBOutlet private weak var labelFrameView: UIView!
    
    // Input
    var movable: Bool = true
    var removable: Bool = true
    var isTheFirstCell: Bool = false
    
    private var title: NSMutableAttributedString? = nil
    private var arrowTintColor: UIColor = .lightGray
    private var addTintColor: UIColor = .lightGray
    private var removeTintColor: UIColor = .lightGray
    private var lockTintColor: UIColor = .darkRed
    private var delegate: StepCollectionViewCellDelegate! = nil
    
    // Styles
    private var acceptableWidthForTextOfOneLine: CGFloat = 60.0
    private var deselectedTextStyle: TextStyle!
    private var selectedTextStyle: TextStyle!
    
    // Configuration
    func configure(title: String,
                   deselectedTextStyle: TextStyle,
                   selectedTextStyle: TextStyle,
                   movable: Bool,
                   removable: Bool,
                   isTheFirstCell: Bool,
                   arrowTintColor: UIColor,
                   addTintColor: UIColor,
                   removeTintColor: UIColor,
                   lockTintColor: UIColor,
                   delegate: StepCollectionViewCellDelegate
        ){
        
        self.title = NSMutableAttributedString(string: title)
        self.deselectedTextStyle = deselectedTextStyle
        self.selectedTextStyle = selectedTextStyle
        self.movable = movable
        self.removable = removable
        self.isTheFirstCell = isTheFirstCell
        self.arrowTintColor = arrowTintColor
        self.addTintColor = addTintColor
        self.removeTintColor = removeTintColor
        self.lockTintColor = lockTintColor
        self.delegate = delegate
        
        updateCellState()
    }
    
    override var isSelected: Bool {
        didSet { updateTitle() }
    }
    
    private func configureTitleLabel() {
        titleLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func configureTitleFrame() {
    }
    
    private func configureServiceButton() {
        
        //serviceButton.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        serviceButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func configureRemoveButton() {
        
        //removeButton.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        removeButton.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - Controller
    var cellState: ProcessControl.CollectionState = .normal {
        didSet {
            updateCellState()
        }
    }
    
    // MARK: - CleanUp
    private func cleanUp(){
        
        serviceButtonState = .hidden
        removeButtonState = .hidden
        labelFrameState = .hidden
        self.isSelected = false
        self.isTheFirstCell = false
    }
    
    // MARK: - Gestures
    private func configureDoubleTap() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        tap.cancelsTouchesInView = true
        tap.numberOfTapsRequired = 2
        tap.requiresExclusiveTouchType = true
        titleLabel.addGestureRecognizer(tap)
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
                // Hide if is the first cell
                serviceButton.isHidden = isTheFirstCell
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
    
    // Remove button states
    private enum RemoveButtonState {
        
        case x
        case lock
        case anchor
        case hidden
    }
    
    private var removeButtonState: RemoveButtonState = .x {
        
        didSet {
            
            switch removeButtonState {
                
            case .x:
                removeButton.setImage(UIImage(named: "cancel", in: bundle, compatibleWith: nil), for: .normal)
                removeButton.isHidden = false
                removeButton.tintColor = removeTintColor
                removeButton.isUserInteractionEnabled = true
                
            case .anchor:
                removeButton.setImage(UIImage(named: "anchor", in: bundle, compatibleWith: nil), for: .normal)
                removeButton.isHidden = false
                removeButton.tintColor = lockTintColor
                removeButton.isUserInteractionEnabled = false
                
            case .lock:
                removeButton.setImage(UIImage(named: "lock", in: bundle, compatibleWith: nil), for: .normal)
                removeButton.isHidden = false
                removeButton.tintColor = lockTintColor
                removeButton.isUserInteractionEnabled = true
                
            case .hidden:
                removeButton.isHidden = true
                removeButton.setImage(nil, for: .normal)
            }
        }
    }
    
    // Label Frame State
    private enum LabelFrameState {
        case visible
        case hidden
    }
    
    private var labelFrameState: LabelFrameState = .hidden {
        
        didSet {
            
            switch labelFrameState {
                
            case .visible:
                labelFrameView.isHidden = false
                
            case .hidden:
                labelFrameView.isHidden = true
            }
        }
    }
    
    // MARK: - Update
    private func updateServiceButtonState() {
        
        switch cellState {
            
        case .normal:
            serviceButtonState = .arrow
        case .editing:
            serviceButtonState = .add
        case .rearrangement:
            serviceButtonState = .hidden
        }
    }
    
    private func updateRemoveButtonState() {
        
        switch cellState {
            
        case .normal:
            removeButtonState = .hidden
        case .editing:
            removeButtonState = removable ? .x : .lock
        case .rearrangement:
            removeButtonState = movable ? .hidden : .anchor
        }
    }
    
    private func updateLabelFrameState() {
        
        switch cellState {
            
        case .normal:
            labelFrameState = .hidden
        case .editing:
            labelFrameState = .visible
        case .rearrangement:
            labelFrameState = .visible
        }
    }
    
    private func updateTitle () {
        
        title?.applyAttributes(ofStyle: isSelected ? selectedTextStyle : deselectedTextStyle)
        titleLabel.attributedText = title
    }
    
    private func updateCellState() {
        
        updateServiceButtonState()
        updateRemoveButtonState()
        updateLabelFrameState()
        updateTitle()
        
        cellState != .normal ? mainView.shakeOn() : mainView.shakeOff()
    }
    
    
    //MARK: - Lifesycle
    override internal func awakeFromNib() {
        super.awakeFromNib()
        
        configureDoubleTap()
        
        configureServiceButton()
        configureRemoveButton()
        configureTitleLabel()
        configureTitleFrame()
    }
    
    override internal func prepareForReuse() {
        cleanUp()
    }
    
    //MARK: - Instruments
    // Size
    static func getCellSize(for text: String?, style: TextStyle, height: CGFloat, acceptableWidthForTextOfOneLine: CGFloat) -> CGSize {
        
        var cellSize = CGSize(width: constantElementsWidth, height: height)
        
        if let text = text {
            
            let labelMaximumHeight = height - 1 - 44
            
            let labelFromTheTextWithOptimalWidth =
                UILabel(text: text, style: style, maximumHeight: labelMaximumHeight, constantElementsWidth: 0, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine)
            
            cellSize.width += labelFromTheTextWithOptimalWidth.bounds.width
        }
        
        return cellSize
    }
}

extension StepCollectionViewCell {
    //MARK: - Actions
    @IBAction private func serviceButtonPressed(_ sender: UIButton) {
        
        sender.blink(duration: 0.2)
        delegate.serviceButtonPressed(at: tag)
    }
    
    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        
        sender.blink(duration: 0.2)
        delegate.removeButtonPressed(at: tag, removable: removable)
    }
    
    // Double Tap
    @objc private func doubleTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            delegate.labelDoubleTapped(at: tag, with: sender)
        }
    }
}


