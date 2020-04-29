//
//  Created by Ryan Ackermann on 7/10/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RAScrollablePickerViewDelegate {
    
    @IBOutlet weak var colorPreView: UIView!
    @IBOutlet weak var huePicker: RAScrollablePickerView!
    @IBOutlet weak var saturationPicker: RAScrollablePickerView!
    @IBOutlet weak var brightnessPicker: RAScrollablePickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors: [UIColor] = [.systemBlue, .systemOrange, .systemYellow]
        let startColor = colors.randomElement() ?? .systemPink
        
        huePicker.delegate = self
        huePicker.set(color: startColor)
        
        saturationPicker.delegate = self
        saturationPicker.type = .saturation
        saturationPicker.hueValueForPreview = huePicker.value
        saturationPicker.set(color: startColor)
        
        brightnessPicker.delegate = self
        brightnessPicker.type = .brightness
        brightnessPicker.hueValueForPreview = huePicker.value
        brightnessPicker.set(color: startColor)
        
        colorPreView.backgroundColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
    }
    
    func valueChanged(_ value: CGFloat, type: PickerType) {
        switch type {
        case .hue:
            colorPreView.backgroundColor = UIColor(hue: value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
            saturationPicker.hueValueForPreview = value
            brightnessPicker.hueValueForPreview = value
        case .saturation:
            colorPreView.backgroundColor = UIColor(hue: huePicker.value, saturation: value, brightness: brightnessPicker.value, alpha: 1)
        case .brightness:
            colorPreView.backgroundColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: value, alpha: 1)
        }
    }
}

