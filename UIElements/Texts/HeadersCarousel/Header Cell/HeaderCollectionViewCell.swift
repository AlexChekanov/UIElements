import UIKit
import Styles

class HeaderCollectionViewCell: UICollectionViewCell {
    
    // MARK: - @IBOutlets
    //@IBOutlet weak var theTitle: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var titleStackViewTop: NSLayoutConstraint!
    @IBOutlet weak var titleStackViewBottom: NSLayoutConstraint!
    @IBOutlet weak var titleStackViewWidth: NSLayoutConstraint!
    
    @IBOutlet private weak var x: UIButton!
    @IBOutlet private weak var lock: UIButton!
    
    @IBOutlet private weak var plus: UIButton!
    @IBOutlet private weak var arrow: UIButton!
    
    @IBOutlet private weak var main: UIView!
    @IBOutlet private weak var service: UIView!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    var delegate: HeadersCarouselControlDelegate!
    
    // MARK: - CleanUp
    func cleanUp(){
        
        title = nil
        titleStackView.subviews.forEach {$0.removeFromSuperview()}
        isSelected = false
        x.alpha = 0
        plus.alpha = 0
        lock.alpha = 0
        arrow.alpha = 0
    }

    // MARK: - Controller
    var cellState: HeadersCarouselControl.CollectionState = .normal {
        didSet {
            switch self.cellState {
            case .normal: setCellToNormalMode()
            case .editing: setCellToEditingMode()
            case .rearrangement: setCellToRearrangementMode()
            }
        }
    }
    
    func setCellToNormalMode() {
        
        updateTitle()
        lock.alpha == 0 ? () : (lockIsHidden = true)
        x.alpha == 0 ? () : (xIsHidden = true)
        plus.alpha == 0 ? () : (plusIsHidden = true)
        isTheFirstCell ? (arrow.alpha = 0) : (
            arrow.alpha == 0 ? (arrowIsHidden = false) : ()
        )
        
        guard main.layer.animation(forKey: "bounce") != nil else { return }
        self.main.shakeOff()
    }
    
    func setCellToEditingMode() {
        
        updateTitle()
        lockIsHidden = removable
        xIsHidden = !removable
        plus.alpha == 0  ? (plusIsHidden = false) : ()
        arrow.alpha == 0 ? () : (arrowIsHidden = true)
        
        guard main.layer.animation(forKey: "bounce") == nil else { return }
        self.main.shakeOn()
    }
    
    func setCellToRearrangementMode() {
        
        updateTitle()
        lockIsHidden = movable
        x.alpha == 0 ? () : (xIsHidden = true)
        plus.alpha == 0 ? () : (plusIsHidden = true)
        arrow.alpha == 0 ? () : (arrowIsHidden = true)
        
        guard main.layer.animation(forKey: "bounce") == nil else { return }
        self.main.shakeOn()
    }
    
    //    var taskState: Task.State = .running {
    //
    //        didSet {
    //
    //            switch self.taskState {
    //            case .planned:
    //                deselectedTextStyle = TextStyle.taskHeadline.planned.deselected.style
    //                selectedTextStyle = TextStyle.taskHeadline.planned.selected.style
    //            case .running:
    //                deselectedTextStyle = TextStyle.taskHeadline.running.deselected.style
    //                selectedTextStyle = TextStyle.taskHeadline.running.selected.style
    //            case .suspended:
    //                deselectedTextStyle = TextStyle.taskHeadline.suspended.deselected.style
    //                selectedTextStyle = TextStyle.taskHeadline.suspended.selected.style
    //            case .completed:
    //                deselectedTextStyle = TextStyle.taskHeadline.completed.deselected.style
    //                selectedTextStyle = TextStyle.taskHeadline.completed.selected.style
    //            case .canceled:
    //                deselectedTextStyle = TextStyle.taskHeadline.canceled.deselected.style
    //                selectedTextStyle = TextStyle.taskHeadline.canceled.selected.style
    //            }
    //        }
    //    }
    //
    //    var deselectedTextStyle: TextStyle = TextStyle.taskHeadline.running.deselected.style
    //    var selectedTextStyle: TextStyle = TextStyle.taskHeadline.running.selected.style
    //
    
    // Input
    var title: String?
    var movable: Bool = true
    var removable: Bool = true
    
    var deselectedTextStyle: TextStyle = .normal
    var selectedTextStyle: TextStyle = .normal
    
    var constantElementsWidth: CGFloat = 0
    var acceptableWidthForTextOfOneLine: CGFloat = 100
    var maximumHeight: CGFloat = 50 {
        didSet {
            height.constant = maximumHeight
            //setNeedsLayout()
        }
    }
    
    var isTheFirstCell: Bool = false
    
    // Styles
    var attentionColor = UIColor.orange
    var denialColor = UIColor.red
    var neutralAction = UIColor.gray
    
    func configure(title: String,
                   movable: Bool,
                   removable: Bool,
                   deselectedTextStyle: TextStyle,
                   selectedTextStyle: TextStyle,
                   constantElementsWidth: CGFloat,
                   acceptableWidthForTextOfOneLine: CGFloat,
                   maximumHeight: CGFloat,
                   isTheFirstCell: Bool,
                   attentionColor: UIColor,
                   denialColor: UIColor,
                   neutralAction: UIColor
        ) {
        
        self.title = title
        self.movable = movable
        self.removable = removable
        self.deselectedTextStyle = deselectedTextStyle
        self.selectedTextStyle = selectedTextStyle
        self.constantElementsWidth = constantElementsWidth
        self.acceptableWidthForTextOfOneLine =  acceptableWidthForTextOfOneLine
        self.maximumHeight = maximumHeight
        self.isTheFirstCell = isTheFirstCell
        self.attentionColor = attentionColor
        self.denialColor = denialColor
        self.neutralAction = neutralAction
        
        configureTitleView()
        configureXView()
        configureLockView()
        configurePlusView()
        configureArrowView()
        
    }
    
    // MARK: - Initialization
    var arrowIsHidden: Bool = false {
        didSet {
            arrowIsHidden ? arrow.fadeOutResized(duration: 0.2) : arrow.fadeInResized(duration: 0.2)
        }
    }
    
    var xIsHidden: Bool = true {
        didSet {
            xIsHidden ? x.fadeOutResized(duration: 0.2) : x.fadeInResized(duration: 0.2)
        }
    }
    
    var lockIsHidden: Bool = true {
        didSet {
            lockIsHidden ? lock.fadeOutResized(duration: 0.2) : lock.fadeInResized(duration: 0.2)
        }
    }
    
    var plusIsHidden: Bool = true {
        didSet {
            plusIsHidden ? plus.fadeOutResized(duration: 0.2) : plus.fadeInResized(duration: 0.2)
        }
    }
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        cleanUp()
        
        arrow.imageView?.contentMode = .scaleAspectFit
        arrow.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        
        plus.imageView?.contentMode = .scaleAspectFit
        plus.imageEdgeInsets = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
    }
    
    override func prepareForReuse() {
        cleanUp()
        setNeedsLayout()
    }
    
//    override func layoutSubviews() {
//
//        super.layoutSubviews()
//    }
    
    //    override var isSelected: Bool {
    //
    //        didSet {
    //            updateTitle()
    //        }
    //
    //
    //        //ToDo: - send delegate!
    //    }
    
    func updateTitle () {
        
        titleStackView.arrangedSubviews.forEach {$0.removeFromSuperview()}
        
        guard let title = title else { return }
        
        let style = isSelected && (cellState == .normal) ? selectedTextStyle : deselectedTextStyle
        
        let labelMaximumHeight = maximumHeight - titleStackViewTop.constant - titleStackViewBottom.constant - 2
        
        let label = UILabel(text: title, style: style, maximumHeight: labelMaximumHeight, constantElementsWidth: constantElementsWidth, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine)
        
        label.isAccessibilityElement = true
        label.adjustsFontSizeToFitWidth = true
        
        
        label.heightAnchor.constraint(equalToConstant: label.bounds.height).isActive = true
        label.widthAnchor.constraint(equalToConstant: label.bounds.width).isActive = true
        
        titleStackView.addArrangedSubview(label)
    }
    
    
    func configureTitleView() {
        
        updateTitle()
        
        //theTitle.adjustsFontForContentSizeCategory = true
    }
    
    func configureArrowView() {
    
        isTheFirstCell ? (arrow.alpha = 0) : (arrowIsHidden = false)
        arrow.tintColor = neutralAction
    }
    
    func configureXView() {
        
        x.tintColor = neutralAction.withAlphaComponent(0.8)
        //x.shadowStyle = Shadow.soft
    }
    
    func configureLockView() {
        
        lock.tintColor = denialColor.withAlphaComponent(0.8)
        //lock.shadowStyle = Shadow.soft
    }
    
    func configurePlusView() {
        
        plus.tintColor = neutralAction
    }
    
    
    //MARK: - Instruments
    //
    //    func getCellSize (fromText text: String?, withHeight height: CGFloat) -> CGSize {
    //
    //        var cellSize = CGSize(width: constantElementsWidth, height: height)
    //
    //        if text != nil {
    //
    //            let labelFromTheTextWithOptimalWidth = UILabel(text: text!, font: textStyleForCalculations.font!, maximumHeight: height, lineBreakMode: textStyleForCalculations.lineBreakMode!, constantElementsWidth: 0.0, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine, foregroundColor: .black, backgroundColor: .white, textAlignment: textStyleForCalculations.alignment!, userInteractionEnabled: nil)
    //
    //            cellSize.width += labelFromTheTextWithOptimalWidth.bounds.width
    //        }
    //
    //        return cellSize
    //    }
    //
    
    //MARK: - Actions
    @IBAction func xButtonPressed(_ sender: UIButton) {
        
        delegate.xButtonPressed(at: self.tag)
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        
        delegate.plusButtonPressed(at: self.tag)
    }
    
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        
        delegate.lockButtonPressed(at: self.tag)
    }
    
}
