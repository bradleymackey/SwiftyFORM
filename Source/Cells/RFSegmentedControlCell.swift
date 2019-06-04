// MIT license. Copyright (c) 2018 SwiftyFORM. All rights reserved.
import UIKit

public struct RFSegmentedControlCellModel {
	var title: String = ""

	var items: [String] = ["a", "b", "c"]
	var value = 0

	var valueDidChange: (Int) -> Void = { (value: Int) in
		SwiftyFormLog("value \(value)")
	}
}

public class RFSegmentedControlCell: UITableViewCell {
	public let model: RFSegmentedControlCellModel
	public let segmentedControl: UISegmentedControl

	public init(model: RFSegmentedControlCellModel) {
		self.model = model
		self.segmentedControl = UISegmentedControl(items: model.items)
		super.init(style: .default, reuseIdentifier: nil)
		selectionStyle = .none
        textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textLabel?.text = model.title
        segmentedControl.selectedSegmentIndex = model.value
		segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        accessoryView = segmentedControl
	}

	public required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIAppearance
    
    @objc public dynamic var textLabel_textColor: UIColor?
    @objc public dynamic var segmentedControl_tintColor: UIColor?
    
    public static func configureAppearance(whenContainedInInstancesOf containerTypes: [UIAppearanceContainer.Type], theme: RFTheme) {
        let appearanceProxy: RFSegmentedControlCell = RFSegmentedControlCell.appearance(whenContainedInInstancesOf: containerTypes)
        appearanceProxy.textLabel_textColor = theme.segmentedControlCell.textLabel_textColor
        appearanceProxy.segmentedControl_tintColor = theme.segmentedControlCell.segmentedControl_tintColor
    }

    @objc public func valueChanged() {
		SwiftyFormLog("value did change")
		model.valueDidChange(segmentedControl.selectedSegmentIndex)
	}

	public func setValueWithoutSync(_ value: Int) {
		SwiftyFormLog("set value \(value)")
		segmentedControl.selectedSegmentIndex = value
	}
}

extension RFSegmentedControlCell: WillDisplayCellDelegate {
    public func form_willDisplay(tableView: UITableView, forRowAtIndexPath indexPath: IndexPath) {
        self.textLabel?.textColor = self.textLabel_textColor
        self.segmentedControl.tintColor = self.segmentedControl_tintColor
    }
}


@available(*, unavailable, renamed: "RFSegmentedControlCell")
typealias SegmentedControlCell = RFSegmentedControlCell

@available(*, unavailable, renamed: "RFSegmentedControlCellModel")
typealias SegmentedControlCellModel = RFSegmentedControlCellModel