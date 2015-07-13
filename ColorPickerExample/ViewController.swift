//
//  Created by Ryan Ackermann on 7/10/15.
//  Copyright (c) 2015 Ryan Ackermann. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RAScrollablePickerViewDelegate
{
    @IBOutlet weak var colorPreView: UIView!
    @IBOutlet weak var huePicker: RAScrollablePickerView!
    @IBOutlet weak var saturationPicker: RAScrollablePickerView!
    @IBOutlet weak var brightnessPicker: RAScrollablePickerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        huePicker.delegate = self
        
        saturationPicker.delegate = self
        saturationPicker.type = .Saturation
        saturationPicker.hueValueForPreview = huePicker.value
        
        brightnessPicker.delegate = self
        brightnessPicker.type = .Brightness
        brightnessPicker.hueValueForPreview = huePicker.value
        
        colorPreView.backgroundColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
    }
    
    func valueChanged(value: CGFloat, type: PickerType)
    {
        switch(type) {
        case .Hue:
            colorPreView.backgroundColor = UIColor(hue: value, saturation: saturationPicker.value, brightness: brightnessPicker.value, alpha: 1)
            saturationPicker.hueValueForPreview = value
            brightnessPicker.hueValueForPreview = value
        case .Saturation:
            colorPreView.backgroundColor = UIColor(hue: huePicker.value, saturation: value, brightness: brightnessPicker.value, alpha: 1)
        case .Brightness:
            colorPreView.backgroundColor = UIColor(hue: huePicker.value, saturation: saturationPicker.value, brightness: value, alpha: 1)
        }
    }
}

