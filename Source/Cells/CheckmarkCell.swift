// MIT license. Copyright (c) 2018 SwiftyFORM. All rights reserved.
import UIKit

public struct CheckmarkCellModel {
    var title: String = ""

    var valueDidChange: (Bool) -> Void = { (value: Bool) in
        SwiftyFormLog("value \(value)")
    }
    
}

public class CheckmarkCell: UITableViewCell {
    public let model: CheckmarkCellModel
    
    var checkmarkDisplaying = false {
        didSet {
            accessoryType = checkmarkDisplaying ? .checkmark : .none
        }
    }

    public init(model: CheckmarkCellModel) {
        self.model = model
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .gray
        textLabel?.text = model.title
        
        let tg = UITapGestureRecognizer(target: self, action: #selector(CheckmarkCell.valueChanged))
        addGestureRecognizer(tg)

        checkmarkDisplaying = false
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func valueChanged() {
        SwiftyFormLog("value did change")
        checkmarkDisplaying.toggle()
        model.valueDidChange(checkmarkDisplaying)
    }

    public func setValueWithoutSync(_ value: Bool, animated: Bool) {
        SwiftyFormLog("set value \(value), animated \(animated)")
        checkmarkDisplaying = value
    }

}
