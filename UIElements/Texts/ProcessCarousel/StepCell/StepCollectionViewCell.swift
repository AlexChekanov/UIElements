import UIKit
import Styles

class StepCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Cell Elements
    // Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var serviceButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var serviceView: UIView!
    
    @IBOutlet private weak var labelFrameView: UIView!
    
    
    // Service button states
    private enum ServiceButtonState {
        
        case arrow
        case add
        case hidden
    }
    
    private let bundle = Bundle(for: StepCollectionViewCell.self)
    
    private var serviceButtonState: ServiceButtonState = .arrow {
        
        didSet {
            
            switch serviceButtonState {
                
            case .arrow:
                
                if isTheFirstCell {
                    
                    serviceButton.isHidden = true
                    
                } else {
                    
                    //serviceButton.fadeOut(duration: 0.4)
                    serviceButton.isHidden = false
                    
                    serviceButton.setImage(UIImage(named: "arrow", in: bundle, compatibleWith: nil), for: .normal)
                    serviceButton.tintColor = neutralColor.withAlphaComponent(0.8)
                    serviceButton.isUserInteractionEnabled = false
                    //serviceButton.fadeIn(duration: 0.4)
                }
                
            case .add:
                //serviceButton.fadeOut(duration: 0.4)
                serviceButton.setImage(UIImage(named: "add", in: bundle, compatibleWith: nil), for: .normal)
                serviceButton.tintColor = neutralColor.withAlphaComponent(0.8)
                serviceButton.isUserInteractionEnabled = true
                //serviceButton.fadeIn(duration: 0.4)
            case .hidden:
                //serviceButton.fadeOut(duration: 0.4)
                serviceButton.isHidden = true
            }
        }
    }
    
    // Remove button states
    private enum RemoveButtonState {
        
        case x
        case lock
        case hidden
    }
    
    private var removeButtonState: RemoveButtonState = .x {
        
        didSet {
            
            switch removeButtonState {
                
            case .x:
                removeButton.fadeOut(duration: 0.4)
                removeButton.setImage(UIImage(named: "cancel", in: bundle, compatibleWith: nil), for: .normal)
                removeButton.tintColor = neutralColor.withAlphaComponent(0.8)
                serviceButton.isUserInteractionEnabled = true
                removeButton.fadeIn(duration: 0.4)
            case .lock:
                removeButton.fadeOut(duration: 0.4)
                removeButton.setImage(UIImage(named: "lock", in: bundle, compatibleWith: nil), for: .normal)
                removeButton.tintColor = denialColor.withAlphaComponent(0.8)
                serviceButton.isUserInteractionEnabled = true
                removeButton.fadeIn(duration: 0.4)
            case .hidden:
                removeButton.fadeOut(duration: 0.4)
                removeButton.isHidden = true
            }
        }
    }
    
    // MARK: - CleanUp
    private func cleanUp(){
        
        
    }
    
    // MARK: - Controller
    var cellState: ProcessControl.CollectionState = .normal {
        didSet {
            updateCellState()
        }
    }
    
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
            removeButtonState = movable ? .hidden : .lock
        }
    }
    
    func updateCellState() {
        
        updateServiceButtonState()
        updateRemoveButtonState()
        updateTitle()
        
        cellState != .normal ? mainView.shakeOn() : mainView.shakeOff()
    }
    
    // Input
    func configure(title: String,
                   deselectedTextStyle: TextStyle,
                   selectedTextStyle: TextStyle,
                   movable: Bool,
                   removable: Bool,
                   isTheFirstCell: Bool){
        
        self.title = NSMutableAttributedString(string: title)
        self.deselectedTextStyle = deselectedTextStyle
        self.selectedTextStyle = selectedTextStyle
        self.movable = movable
        self.removable = removable
        self.isTheFirstCell = isTheFirstCell
        
        updateCellState()
    }
    
    var movable: Bool = true
    var removable: Bool = true
    var isTheFirstCell: Bool = false
    
    private var deselectedTextStyle: TextStyle = TextStyle.taskHeadline.running.deselected.style
    private var selectedTextStyle: TextStyle = TextStyle.taskHeadline.running.selected.style
    
    private var title: NSMutableAttributedString? = nil
    
    //MARK: - Overrides
    override internal func awakeFromNib() {
        super.awakeFromNib()
        
        configureServiceButton()
        configureRemoveButton()
        configureTitleLabel()
    }
    
    override internal func prepareForReuse() {
        //cleanUp()
    }
    
    override var isSelected: Bool {
        
        didSet {
            updateTitle()
        }
    }
    
    func updateTitle () {
        
        if isSelected {
            
            title?.applyAttributes(ofStyle: selectedTextStyle)
            
        } else {
            title?.applyAttributes(ofStyle: deselectedTextStyle)
        }
        titleLabel.attributedText = title
    }
        
    // MARK: - Elements view configuration
    private let constantElementsWidth: CGFloat = 68
    
    
    // Styles
    private let attentionColor = Colors.attention.withAlphaComponent(0.8)
    private let denialColor = Colors.denial.withAlphaComponent(0.8)
    private let neutralColor = Colors.neutral.withAlphaComponent(0.8)
    
    let textStyleForCalculations = TextStyle.taskHeadline.completed.selected.style
    let acceptableWidthForTextOfOneLine: CGFloat = 60.0
    
    
    func configureTitleLabel() {
        
        titleLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func configureServiceButton() {
        
        //serviceButton.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        serviceButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func configureRemoveButton() {
        
        removeButton.shadowStyle = Shadow.soft
        //removeButton.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        removeButton.imageView?.contentMode = .scaleAspectFit
    }
    
    
    //MARK: - Instruments
    
    func getCellSize (fromText text: String?, withHeight height: CGFloat) -> CGSize {
        
        var cellSize = CGSize(width: constantElementsWidth, height: height)
        
        if let text = text {
            
            let labelMaximumHeight = height - 36
            
            let labelFromTheTextWithOptimalWidth =
                UILabel(text: text, style: textStyleForCalculations, maximumHeight: labelMaximumHeight, constantElementsWidth: 0, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine)
            
            cellSize.width += labelFromTheTextWithOptimalWidth.bounds.width
        }
        
        return cellSize
    }
    
    
    //MARK: - Actions
    @IBAction private func serviceButtonPressed(_ sender: UIButton) {
        
        print("pressed service button for cell #\(tag) while in \(cellState) state")
    }
    
    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        
        print("pressed remove button for cell #\(tag) while in \(cellState) state")
    }
    
}
