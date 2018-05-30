/*
* RAScrollablePickerView.swift
* Copyright (c) 2015 Ryan Ackermann. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit

enum PickerType: Int {
    case hue
    case saturation
    case brightness
}

protocol RAScrollablePickerViewDelegate: class {
    func valueChanged(_ value: CGFloat, type: PickerType)
}

class RAScrollablePickerView: UIView {
    
    var type: PickerType = .hue
    var shouldDecelerate = true
    weak var delegate: RAScrollablePickerViewDelegate?
    
    var hueValueForPreview: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var lastTouchLocation: CGPoint?
    private var decelerateTimer: Timer?
    
    private var decelerationSpeed: CGFloat = 0.0 {
        didSet {
            if let timer = decelerateTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            decelerateTimer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(decelerate), userInfo: nil, repeats: true)
        }
    }
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    }()
    
    private(set) var value: CGFloat = 0.5 {
        didSet {
            if type != .hue {
                if self.value > 1 {
                    self.value = 1
                }
                else if self.value < 0 {
                    self.value = 0
                }
                else {
                    setNeedsDisplay()
                }
            }
            else {
                if self.value > 1 {
                    self.value -= 1
                }
                else if self.value < 0 {
                    self.value += 1
                }
                else {
                    setNeedsDisplay()
                }
            }
            delegate?.valueChanged(self.value, type: type)
        }
    }
    
    private func colors(for value: CGFloat) -> [CGColor] {
        var result = [CGColor]()
        var colors = [CGFloat]()
        var padding: CGFloat = 0.0
        
        if type != .hue {
            padding = 0.7
        }
        else {
            padding = 0.135
        }
        
        colors.append(value - padding)
        colors.append(value)
        colors.append(value + padding)
        
        for index in 0..<colors.count {
            let color = colors[index]
            var colorValue: CGFloat
            
            if type != .hue {
                if color < 0 {
                    colorValue = 0
                }
                else if color > 1 {
                    colorValue = 1
                }
                else {
                    colorValue = color
                }
            }
            else {
                if color < 0 {
                    colorValue = 1 + color
                }
                else if color > 1 {
                    colorValue = 1 - color
                }
                else {
                    colorValue = color
                }
            }
            
            switch(type) {
            case .hue:
                result.append(UIColor(hue: colorValue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor)
            case .saturation:
                result.append(UIColor(hue: hueValueForPreview, saturation: colorValue, brightness: 1.0, alpha: 1.0).cgColor)
            case .brightness:
                result.append(UIColor(hue: hueValueForPreview, saturation: 1.0, brightness: colorValue, alpha: 1.0).cgColor)
            }
        }
        
        return result
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            lastTouchLocation = gesture.location(in: self)
        }
        else if gesture.state == .changed {
            if let location = lastTouchLocation {
                value += (gesture.location(in: self).x - location.x) / frame.width
            }
            lastTouchLocation = gesture.location(in: self)
        }
        else if (gesture.state == .ended || gesture.state == .cancelled) && shouldDecelerate {
            decelerationSpeed = gesture.velocity(in: self).x
        }
    }
    
    @objc private func decelerate() {
        decelerationSpeed *= 0.7255
        
        if abs(decelerationSpeed) <= 0.001 {
            if let decelerateTimer = decelerateTimer {
                decelerateTimer.invalidate()
            }
            return
        }
        
        value += (decelerationSpeed * 0.025) / 100
    }
    
    private func commonInit() {
        addGestureRecognizer(panGesture)
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors(for: value) as CFArray, locations: [0, 0.5, 1]) {
            ctx?.drawLinearGradient(gradient, start: CGPoint(x: rect.size.width, y: 0), end: CGPoint.zero, options: .drawsBeforeStartLocation)
        }
        
        let selectionPath = CGMutablePath()
        let verticalPadding = rect.height * 0.4
        let horizontalPosition = rect.midX
        
        selectionPath.move(to: CGPoint(x: horizontalPosition, y: verticalPadding * 0.5))
        selectionPath.addLine(to: CGPoint(x: horizontalPosition, y: rect.height - (verticalPadding * 0.5)))
        
        ctx?.addPath(selectionPath)
        
        ctx?.setLineWidth(1.0)
        ctx?.setStrokeColor(UIColor(white: 0, alpha: 0.5).cgColor)
        
        ctx?.strokePath()
    }
}
