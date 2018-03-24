import UIKit

@IBDesignable
class DashedView: UIView {

    @IBInspectable var borderColor: UIColor = .black
    @IBInspectable var fillColor: UIColor = .clear
    @IBInspectable var lineWidth: CGFloat = 1
    @IBInspectable var dash: NSNumber = 6
    @IBInspectable var space: NSNumber = 3
    @IBInspectable var cornerRadius: CGFloat = 4
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addDashedBorder(color: borderColor, fillColor: fillColor, lineWidth: lineWidth, dashPattern: [dash, space], cornerRadius: cornerRadius)
    }
}
