// MIT license. Copyright (c) 2019 SwiftyFORM. All rights reserved.
import UIKit

public class KeyboardCompatibility {
    public class var keyboardWillShowNotification: NSNotification.Name {
        #if swift(>=4.2)
            // 'keyboardWillShowNotification' was introduced in Swift 4.2
            return UIResponder.keyboardWillShowNotification
        #else
            // Swift 4.0 and earlier
            return NSNotification.Name.UIKeyboardWillShow
        #endif
    }

    public class var keyboardWillHideNotification: NSNotification.Name {
        #if swift(>=4.2)
            // 'keyboardWillHideNotification' was introduced in Swift 4.2
            return UIResponder.keyboardWillHideNotification
        #else
            // Swift 4.0 and earlier
            return NSNotification.Name.UIKeyboardWillHide
        #endif
    }
}
