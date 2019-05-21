// MIT license. Copyright (c) 2019 SwiftyFORM. All rights reserved.
import UIKit

@objc public protocol TextFieldAppearanceStrategy {
    /// Configure the initial `tintColor` and initial `textColor`.
    func willDisplay(_ textField: UITextField)
    
    /// Depending on what stategy that is active, then either do nothing.
    /// Or set the `textColor` to the same as the `tintColor`.
    func textFieldDidBeginEditing(_ textField: UITextField)
    
    /// Depending on what stategy that is active, then either do nothing.
    /// Or restore the `textColor` back to the original the `textColor`.
    func textFieldDidEndEditing(_ textField: UITextField)
}

public class TextFieldAppearanceStrategy_Default: TextFieldAppearanceStrategy {
    let tintColor: UIColor
    let textColor: UIColor
    
    public init(tintColor: UIColor, textColor: UIColor) {
        self.tintColor = tintColor
        self.textColor = textColor
    }
    
    public func willDisplay(_ textField: UITextField) {
        textField.textColor = self.textColor
        textField.tintColor = self.tintColor
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // do nothing
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        // do nothing
    }
}

/// When the textfield becomes first responder, then use the tintColor as the textColor.
/// When the textfield resigns first responder, then restore the original textColor.
public class TextFieldAppearanceStrategy_TintFirstResponder: TextFieldAppearanceStrategy {
    let tintColor: UIColor
    let textColor: UIColor
    
    public init(tintColor: UIColor, textColor: UIColor) {
        self.tintColor = tintColor
        self.textColor = textColor
    }
    
    public func willDisplay(_ textField: UITextField) {
        textField.textColor = self.textColor
        textField.tintColor = self.tintColor
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = self.tintColor
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = self.textColor
    }
}
