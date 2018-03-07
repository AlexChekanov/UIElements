import UIKit
import UIExtensions

@IBDesignable
public final class TwoStateButton: UIControl {
    
    @IBOutlet weak var button: UIButton!
    
    @IBInspectable public var background: UIColor? {
        
        didSet {
            backgroundColor = background
        }
    }
    
    public enum State {
        
        case one
        case two
        
        mutating func toggle() {
            switch self {
            case .one:
                self = .two
            case .two:
                self = .one
            }
        }
    }
    
    public var currentState: State = .one {
        
        didSet {
            
            update()
        }
    }
    
    @IBInspectable var title: String? {
        
        get {
            return button.title(for: .normal)
        }
        
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
    
    @IBInspectable var imageForState1: UIImage? = nil {
        
        didSet {
            update()
        }
    }
    
    @IBInspectable var imageForState2: UIImage? = nil {
        
        didSet {
            update()
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    
        update()
    }
    
    private func update() {
        switch currentState {
        case .one:
            button.setImage(imageForState1, for: .normal)
        case .two:
            button.setImage(imageForState2, for: .normal)
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        
        currentState.toggle()
        sendActions(for: UIControlEvents.touchUpInside)
    }
}


