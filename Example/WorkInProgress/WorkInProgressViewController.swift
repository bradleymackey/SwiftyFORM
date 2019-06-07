// MIT license. Copyright (c) 2018 SwiftyFORM. All rights reserved.
import UIKit
import SwiftyFORM

class WorkInProgressViewController: RFFormViewController {
	override func populate(_ builder: RFFormBuilder) {
		builder.navigationTitle = "Work In Progress"
		builder += RFViewControllerFormItem().title("Scientific slider experimental").viewController(ScientificSliderViewController.self)
	}
}
