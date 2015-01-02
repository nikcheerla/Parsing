
import UIKit

class BackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let space: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let colors: CFArray = [
            UIColor(red: 0.031, green: 0.314, blue: 0.471, alpha: 1).CGColor,
            UIColor(red: 0.522, green: 0.847, blue: 0.808, alpha: 1).CGColor
        ]
        let locations: [CGFloat] = [0, 1]
        
        let gradient = CGGradientCreateWithColors(space, colors, locations)
        
        let currentContext = UIGraphicsGetCurrentContext()
        let startPoint = CGPointZero
        let endPoint = CGPointMake(frame.width, frame.height)
        
        CGContextDrawLinearGradient(currentContext, gradient, startPoint, endPoint, 0)
    }
    
}
