//
//  Created by Ryan Ackermann on 7/8/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

enum PickerType: Int
{
    case Hue,
         Saturation,
         Brightness
}

protocol RAScrollablePickerViewDelegate
{
    func valueChanged(value: CGFloat, type: PickerType)
}

class RAScrollablePickerView: UIView
{
    var type: PickerType = .Hue
    var delegate: RAScrollablePickerViewDelegate?
    
    var hueValueForPreview: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var lastTouchLocation: CGPoint?
    private var decelerateTimer: NSTimer?
    
    private var decelerationSpeed: CGFloat = 0.0 {
        didSet {
            if let timer = decelerateTimer {
                if timer.valid {
                    timer.invalidate()
                }
            }
            decelerateTimer = NSTimer.scheduledTimerWithTimeInterval(0.025, target: self, selector: "decelerate", userInfo: nil, repeats: true)
        }
    }
    
    lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: "handlePan:")
    }()
    
    private(set) var value: CGFloat = 0.5 {
        didSet {
            if type != .Hue {
                if self.value > 1 {
                    self.value = 1
                } else if self.value < 0 {
                    self.value = 0
                } else {
                    setNeedsDisplay()
                }
            } else {
                if self.value > 1 {
                    self.value -= 1
                } else if self.value < 0 {
                    self.value += 1
                } else {
                    setNeedsDisplay()
                }
            }
            delegate?.valueChanged(self.value, type: type)
        }
    }
    
    private func colorsForValue(#value: CGFloat) -> [CGColor]
    {
        var result = [CGColor]()
        var colors = [CGFloat]()
        var padding: CGFloat = 0.0
        
        if type != .Hue {
            padding = 0.7
        } else {
            padding = 0.135
        }
        
        colors.append(value - padding)
        colors.append(value)
        colors.append(value + padding)
        
        for index in 0..<colors.count {
            var color = colors[index]
            var colorValue: CGFloat
            
            if type != .Hue {
                if color < 0 {
                    colorValue = 0
                } else if color > 1 {
                    colorValue = 1
                } else {
                    colorValue = color
                }
            } else {
                if color < 0 {
                    colorValue = 1 + color
                } else if color > 1 {
                    colorValue = 1 - color
                } else {
                    colorValue = color
                }
            }
            
            switch(type) {
            case .Hue:
                result.append(UIColor(hue: colorValue, saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor)
            case .Saturation:
                result.append(UIColor(hue: hueValueForPreview, saturation: colorValue, brightness: 1.0, alpha: 1.0).CGColor)
            case .Brightness:
                result.append(UIColor(hue: hueValueForPreview, saturation: 1.0, brightness: colorValue, alpha: 1.0).CGColor)
            }
        }
        
        return result
    }
    
    internal func handlePan(gesture: UIPanGestureRecognizer)
    {
        if gesture.state == .Began {
            lastTouchLocation = gesture.locationInView(self)
        }
        else if gesture.state == .Changed {
            if let location = lastTouchLocation {
                value += (gesture.locationInView(self).x - location.x) / CGRectGetWidth(frame)
            }
            lastTouchLocation = gesture.locationInView(self)
        }
        else if gesture.state == .Ended || gesture.state == .Cancelled {
            decelerationSpeed = gesture.velocityInView(self).x
        }
    }
    
    internal func decelerate()
    {
        decelerationSpeed *= 0.7255
        
        if abs(decelerationSpeed) <= 0.001 {
            if let decelerateTimer = decelerateTimer {
                decelerateTimer.invalidate()
            }
            return
        }
        
        value += (decelerationSpeed * 0.025) / 100
    }
    
    private func commonInit()
    {
        addGestureRecognizer(panGesture)
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext()
        
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colorsForValue(value: value), [0, 0.5, 1])
        
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: rect.size.width, y: 0), CGPointZero, 0)
        
        let selectionPath = CGPathCreateMutable()
        let verticalPadding = CGRectGetHeight(rect) * 0.4
        let horizontalPosition = CGRectGetMidX(rect)
        
        CGPathMoveToPoint(selectionPath, nil, horizontalPosition, verticalPadding * 0.5)
        CGPathAddLineToPoint(selectionPath, nil, horizontalPosition, CGRectGetHeight(rect) - (verticalPadding * 0.5))
        
        CGContextAddPath(ctx, selectionPath)
        
        CGContextSetLineWidth(ctx, 1.0)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        CGContextStrokePath(ctx)
    }
}
