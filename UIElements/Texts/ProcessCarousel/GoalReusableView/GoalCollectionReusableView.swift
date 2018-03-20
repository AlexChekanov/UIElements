import UIKit
import Styles

class GoalCollectionReusableView: UICollectionReusableView {
    
    //Mark: - @IBOutlets
    
    @IBOutlet private weak var theTitle: UILabel!
    @IBOutlet private weak var arrow: UILabel!
    @IBOutlet private weak var x: UIButton!
    @IBOutlet private weak var plus: UIButton!
    
    @IBOutlet private weak var main: UIView!
    @IBOutlet private weak var service: UIView!
    
    // MARK: - CleanUp
    
    func cleanUp(){
        
        x.alpha = 0
        plus.alpha = 0
        arrow.alpha = 0
        self.main.shakeOff()
    }
    
    // MARK: - Controller
    
    var viewState: ProcessControl.CollectionState = .normal {
        didSet {
            switch self.viewState {
            case .normal: setViewToNormalMode()
            case .editing: setViewToEditingMode()
            case .rearrangement: setViewToRearrangementMode()
            }
        }
    }
    
    func setViewToNormalMode() {
        
        xIsHidden = true
        plusIsHidden = true
        hasAnyTask ? (arrowIsHidden = false) : (arrow.alpha = 0)
        
        guard main.layer.animation(forKey: "bounce") != nil else { return }
        self.main.shakeOff()
        
    }
    
    func setViewToEditingMode() {
        
        xIsHidden = false
        plusIsHidden = false
        arrowIsHidden = true
        
        guard main.layer.animation(forKey: "bounce") == nil else { return }
        self.main.shakeOn()
    }
    
    func setViewToRearrangementMode() {
        
        xIsHidden = true
        plusIsHidden = true
        arrowIsHidden = true
        
        guard main.layer.animation(forKey: "bounce") == nil else { return }
        self.main.shakeOn()
    }
    
    var goalState: Goal.State = .running {
        
        didSet {
            
            switch self.goalState {
            case .planned:
                textStyle = TextStyle.goalHeadline.planned.style
            case .running:
                textStyle = TextStyle.goalHeadline.running.style
            case .suspended:
                textStyle = TextStyle.goalHeadline.suspended.style
            case .completed:
                textStyle = TextStyle.goalHeadline.completed.style
            case .canceled:
                textStyle = TextStyle.goalHeadline.canceled.style
            }
        }
    }
    
    var textStyle: TextStyle = TextStyle.goalHeadline.running.style
    
    
    //MARK: - Inputs
    
    var object: Goal? = nil {
        
        didSet {
            
            if object != nil {
                
                
                goalState = object?.state ?? .running
                title = NSMutableAttributedString(string: (object?.title ?? "")!)
                
                if let taskCount = object?.tasks?.count {
                    
                    taskCount>0 ? (hasAnyTask = true) : (hasAnyTask = false)
                } else { hasAnyTask = false }
                
            } else {
                hasAnyTask = false
            }
        }
        
    }
    
    var title: NSMutableAttributedString? = nil {
        didSet {
            
            title?.applyAttributes(ofStyle: textStyle)
            theTitle.attributedText = title
        }
    }
    
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
    
    var plusIsHidden: Bool = true {
        didSet {
            plusIsHidden ? plus.fadeOutResized(duration: 0.2) : plus.fadeInResized(duration: 0.2)
        }
    }
    
    var hasAnyTask: Bool = false {
        
        didSet {
            arrowIsHidden = !hasAnyTask
        }
    }
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        cleanUp()
        configureTitleView()
        configureArrowView()
        configureXView()
        configurePlusView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }
    
    
    //MARK: - Elements view configuration
    
    let constantElementsWidth: CGFloat = 103
    
    // Styles
    
    //let attentionColor = UIColor.orange.withAlphaComponent(0.8)
    let denialColor = UIColor.red.withAlphaComponent(0.8)
    let neutralAction = UIColor.white.withAlphaComponent(0.8)
    
    let textStyleForCalculations = TextStyle.goalHeadline.completed.style
    let acceptableWidthForTextOfOneLine: CGFloat = 60.0
    
    
    func configureTitleView() {
        
        //theTitle.adjustsFontForContentSizeCategory = true
        self.sendSubview(toBack: theTitle)
    }
    
    
    func configureArrowView() {
        
        arrow.text = "❭"
        arrow.font = TextStyle.taskHeadline.running.deselected.style.font!
        arrow.textColor = TextStyle.taskHeadline.running.deselected.style.foregroundColor!
    }
    
    
    func configureXView() {
        
        x.tintColor = neutralAction.withAlphaComponent(0.8)
        x.shadowStyle = Shadow.soft
    }
    
    
    func configurePlusView() {
        
        plus.tintColor = neutralAction
        
    }
    
    //MARK: - Instruments
    
    func getFooterSize (fromText text: String?, withHeight height: CGFloat) -> CGSize {
        
        var footerSize = CGSize(width: constantElementsWidth, height: height)
        
        if let text = text {
            
            let labelFromTheTextWithOptimalWidth = UILabel(text: text, maximumHeight: height)
            
            footerSize.width += labelFromTheTextWithOptimalWidth.bounds.width
        }
        
        return footerSize
    }
    
    
    //MARK: - Actions
    
    @IBAction func xButtonPressed(_ sender: Any) {
        
        print ("The Goal should be deleted")
    }
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        
        print ("Insert task before the completiom")
    }
    
}
