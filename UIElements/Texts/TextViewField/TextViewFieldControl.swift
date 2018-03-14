import Foundation
import UIKit
import UIExtensions

@IBDesignable
public class TextViewFieldControl: UIControl {
    
    @IBOutlet weak var placeholderView: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBInspectable var placeholderText: String? = nil {
        didSet { setup() }
    }
    @IBInspectable var style: Int = 5 {
        didSet { setup() }
    }
    @IBInspectable var textColor: UIColor = .black  {
        didSet { setup() }
    }
    @IBInspectable var serviceColor: UIColor = .lightGray {
        didSet { setup() }
    }
    
    public var textUpdateDelegate: UITextUpdateDelegate?
    
    public var host: UIView?
    
    private var textViewHeight: CGFloat?
    private var placeholderViewHeight: CGFloat?
    
    public var resizeRequestAddresseeIdentifiers: [String]?
    public var resizeRequestAddresseeViews: [UIView]?
    
    public var scrollRequestAddresseeIdentifiers: [String]?
    public var scrollRequestAddresseeViews: [UIView]?
    
    private var textViewIsInEditingMode: Bool = false
    
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
        setup()
    }
    
    private func setup() {
        
        textView.textColor = textColor
        placeholderView.textColor = serviceColor
        clearButton.tintColor = serviceColor
        textView.font = UIFont.Prebuilt.getFont(rawValue: style)
        placeholderView.font = UIFont.Prebuilt.getFont(rawValue: style)
        placeholderView.text = placeholderText
        
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        textView.text = nil
        textViewDidChange(textView)
    }
}

// Text Fields management
extension TextViewFieldControl: UITextViewDelegate {
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        // We need this delay as a partial fix to a long standing bug: to keep the caret inside the `UITextView` always visible
        guard textViewIsInEditingMode == true else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {[weak self] in
            textView.sendScrollRequest(animated: false, receivers: self?.scrollRequestAddresseeViews, identifiers: self?.scrollRequestAddresseeIdentifiers)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        // Main textView should have tag = 1, placeholder = 0
        // Placeholder view sholdn't be editable
        guard textView.tag == 1 else { return }
        
        textViewIsInEditingMode = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(640)) { [weak self] in
            textView.sendScrollRequest(animated: false, receivers: self?.scrollRequestAddresseeViews, identifiers: self?.scrollRequestAddresseeIdentifiers)
        }
        
        clearButton.isHidden = textView.text.count == 0
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
        textViewIsInEditingMode = true
        clearButton.isHidden = true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        
        // Main textView should have tag = 1, placeholder = 0
        // Placeholder view sholdn't be editable
        guard textView.tag == 1 else { return }
        
        // Inform the delegate text was changed
        if let textUpdateDelegate = textUpdateDelegate {
            textUpdateDelegate.update(text: textView.text)
        }
        
        // Check placeholder visibility
        // placeholderView.isHidden = textView.text.count > 0
        if textView.text.count > 0 {
            placeholderView.text = nil
        } else { placeholderView.text = placeholderText }
        
        // Check clearButton visibility
        clearButton.isHidden = textView.text.count == 0
        
        // Check the textViewHeight was changed
        // Do nothing if the height wasn't change
        guard
            textViewHeight != textView.intrinsicContentSize.height ||
                placeholderViewHeight != placeholderView.intrinsicContentSize.height
            
            else { return }
        
        textView.setNeedsLayout()
        placeholderView.setNeedsLayout()
        
        sendResizeRequest(object: nil, receivers: resizeRequestAddresseeViews, identifiers: resizeRequestAddresseeIdentifiers)
        
        textViewHeight = textView.intrinsicContentSize.height
        placeholderViewHeight = placeholderView.intrinsicContentSize.height
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Send scroll request on paste
        if let pasteString = UIPasteboard.general.string, text.contains(pasteString) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(640)) {[weak self] in
                self?.textView.sendScrollRequest(animated: false, receivers: self?.scrollRequestAddresseeViews, identifiers: self?.scrollRequestAddresseeIdentifiers)
            }
        }
        
        return true
    }
}
