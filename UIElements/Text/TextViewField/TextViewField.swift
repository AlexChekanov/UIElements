import Foundation
import UIKit

@IBDesignable
public class TextViewField: UIControl {
    
    @IBInspectable
    public var placeholderText: String? {
        
        didSet {
            placeholderView.text = placeholderText
        }
    }
    
    @IBOutlet weak var placeholderView: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var clearButton: UIButton!
    
    private var textViewHeight: CGFloat?
    private var placeholderViewHeight: CGFloat?
    
    public var sizeUpdateAddressee: [String]?
    public var scrollUpdateAddressee: [String]?
    
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
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        textView.text = nil
        textViewDidChange(textView)
    }
}

// Text Fields management
extension TextViewField: UITextViewDelegate {
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        // We need this delay as a partial fix to a long standing bug: to keep the caret inside the `UITextView` always visible
        guard textViewIsInEditingMode == true else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {[weak self] in
            textView.sendScrollRequest(animated: false, identifiers: self?.scrollUpdateAddressee)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        // Main textView should have tag = 1, placeholder = 0
        // Placeholder view sholdn't be editable
        guard textView.tag == 1 else { return }
        
        textViewIsInEditingMode = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(640)) { [weak self] in
            textView.sendScrollRequest(animated: false, identifiers: self?.scrollUpdateAddressee)
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
        //guard textView.tag == 1 else { return }
        
        // Check placeholder visibility
        //placeholderView.isHidden = textView.text.count > 0
        
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
        
        informSizeWasUpdated(object: nil, receivers: nil, identifiers: sizeUpdateAddressee)
        
        textViewHeight = textView.intrinsicContentSize.height
        placeholderViewHeight = placeholderView.intrinsicContentSize.height
    }
}
