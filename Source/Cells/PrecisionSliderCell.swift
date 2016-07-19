// MIT license. Copyright (c) 2016 SwiftyFORM. All rights reserved.
import UIKit

class PrecisionSlider_InnerModel {
	var minimumValue: Double = 0.0
	var maximumValue: Double = 100.0

	var hasPartialItemBefore = false
	var sizeOfPartialItemBefore: Double = 0.0
	
	var numberOfItems = 100

	var hasPartialItemAfter = false
	var sizeOfPartialItemAfter: Double = 0.0
	
	var scale: Double = 60.0
	
	var scaleRounded: Double {
		let result = floor(scale + 0.5)
		if result < 0.1 {
			return 0.1
		}
		return result
	}
	
	static let height: CGFloat = 130
}

class PrecisionSlider_InnerCollectionViewFlowLayout: UICollectionViewFlowLayout {
	weak var model: PrecisionSlider_InnerModel?
	
	override func collectionViewContentSize() -> CGSize {
		guard let model = self.model else {
			print("no model")
			return CGSizeZero
		}

		var length: Double = Double(model.numberOfItems)
		if model.hasPartialItemBefore {
			length += model.sizeOfPartialItemBefore
		}
		if model.hasPartialItemAfter {
			length += model.sizeOfPartialItemAfter
		}
		
		return CGSize(width: CGFloat(model.scaleRounded * length), height: PrecisionSlider_InnerModel.height)
	}
}

class PrecisionSlider_InnerCollectionViewCell: UICollectionViewCell {
	static let identifier = "cell"
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		backgroundColor = UIColor.whiteColor()
		addSubview(leftBorder)
		addSubview(label)
	}
	
	lazy var leftBorder: UIView = {
		let instance = UIView()
		instance.backgroundColor = UIColor.blackColor()
		return instance
	}()
	
	lazy var label: UILabel = {
		let instance = UILabel()
		instance.text = "0"
		return instance
	}()
	
	override func layoutSubviews() {
		super.layoutSubviews()
		leftBorder.frame = CGRect(x: 0, y: 0, width: 1, height: bounds.height)
		
		let labelHidden = self.bounds.width < 30
		label.hidden = labelHidden
		
		label.sizeToFit()
		let labelFrame = label.frame
		label.frame = CGRect(x: 7, y: 5, width: bounds.width - 10, height: labelFrame.height)
	}
}

/*
 1 finger pan to adjust slider
 2 finger pinch to zoom slider precision
 */
class PrecisionSliderView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate {
	var originalScale: Double = 1.0
	var originalValue: Double?
	
	var model = PrecisionSlider_InnerModel()
	
	typealias ValueDidChange = Void -> Void
	var valueDidChange: ValueDidChange?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		addSubview(collectionView)
		addSubview(leftCoverView)
		addSubview(rightCoverView)
		addGestureRecognizer(pinchGestureRecognizer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		collectionView.frame = bounds
		
		let halfWidth = round(bounds.width/2)-1
		collectionView.contentInset = UIEdgeInsets(top: 0, left: halfWidth, bottom: 0, right: halfWidth)
		
		let (leftFrame, rightFrame) = bounds.divide(round(bounds.width/2), fromEdge: .MinXEdge)
		leftCoverView.frame = CGRect(x: leftFrame.origin.x, y: leftFrame.origin.y, width: leftFrame.size.width - 1, height: leftFrame.size.height)
		rightCoverView.frame = rightFrame
	}
	
	lazy var leftCoverView: UIView = {
		let instance = UIView()
		instance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
		instance.userInteractionEnabled = false
		return instance
	}()
	
	lazy var rightCoverView: UIView = {
		let instance = UIView()
		instance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
		instance.userInteractionEnabled = false
		return instance
	}()
	
	var value: Double? {
		let scale = model.scaleRounded
		if scale < 0.1 {
			return nil
		}
		
		let contentInset = collectionView.contentInset
		let left = contentInset.left
		let right = contentInset.right
		
		let minimumValue = model.minimumValue
		let width = collectionView.bounds.width
		let halfWidth: CGFloat = width / 2
		let contentOffset = collectionView.contentOffset.x
//		let midX: CGFloat = contentOffset + halfWidth
		let midX: CGFloat = contentOffset + left
		let result = Double(midX) / scale + minimumValue
//		print("\(result) = \(midX) / \(scale) + \(minimumValue)   where midx = \(contentOffset) + \(width) / 2")
		print("\(result) = \(midX) / \(scale) + \(minimumValue)   where midx = \(contentOffset) + \(left)")
		return result
	}
	
	func scrollToValue(value: Double) {
		let scale = model.scaleRounded
		if scale < 0.1 {
			return
		}
		
		let valueAdjusted = value - model.minimumValue
		
		let halfWidth = Double(collectionView.bounds.width / 2)
		let offsetX = CGFloat(round((scale * valueAdjusted) - halfWidth))
		//print("offsetX: \(offsetX)    [ \(scale) * \(value) - \(halfWidth) ]")
		collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
	}
	
	lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = {
		let instance = UIPinchGestureRecognizer(target: self, action: #selector(PrecisionSliderView.handlePinch))
		instance.delegate = self
		return instance
	}()
	
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	func handlePinch(gesture: UIPinchGestureRecognizer) {
		if gesture.state == .Began {
			originalScale = model.scale
			originalValue = self.value
		}
		if gesture.state == .Changed {
			var scale = originalScale * Double(gesture.scale)
			if scale < 0.0 {
				scale = 0.01
			}
			model.scale = scale
			
			layout.itemSize = computeItemSize()
			layout.invalidateLayout()
			
			if let value = originalValue {
				scrollToValue(value)
			}
			
			valueDidChange?()
		}
	}
	
	func computeItemSize() -> CGSize {
		return CGSize(width: CGFloat(model.scaleRounded), height: PrecisionSlider_InnerModel.height)
	}
	
	lazy var layout: PrecisionSlider_InnerCollectionViewFlowLayout = {
		let instance = PrecisionSlider_InnerCollectionViewFlowLayout()
		instance.scrollDirection = .Horizontal
		instance.minimumInteritemSpacing = 0
		instance.minimumLineSpacing = 0
		instance.sectionInset = UIEdgeInsetsZero
		instance.headerReferenceSize = CGSizeZero
		instance.footerReferenceSize = CGSizeZero
		instance.itemSize = self.computeItemSize()
		instance.model = self.model
		return instance
	}()
	
	lazy var collectionView: UICollectionView = {
		let instance = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
		instance.showsHorizontalScrollIndicator = false
		instance.showsVerticalScrollIndicator = false
		instance.backgroundColor = UIColor.blackColor()
		instance.bounces = false
		instance.alwaysBounceHorizontal = true
		instance.alwaysBounceVertical = false
		instance.registerClass(PrecisionSlider_InnerCollectionViewCell.self, forCellWithReuseIdentifier: PrecisionSlider_InnerCollectionViewCell.identifier)
		instance.contentInset = UIEdgeInsetsZero
		instance.delegate = self
		instance.dataSource = self
		return instance
	}()
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		valueDidChange?()
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var count = model.numberOfItems
		if model.hasPartialItemBefore {
			count += 1
		}
		if model.hasPartialItemAfter {
			count += 1
		}
		return count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PrecisionSlider_InnerCollectionViewCell.identifier, forIndexPath: indexPath) as! PrecisionSlider_InnerCollectionViewCell
		
		let index = Int(floor(model.minimumValue)) + indexPath.row
		var displayValue = index % 10
		if displayValue < 0 {
			displayValue += 10
		}
		cell.label.text = String(displayValue)
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		var row = indexPath.row
		if model.hasPartialItemBefore {
			if row == 0 {
				return CGSize(
					width: CGFloat(model.scaleRounded * model.sizeOfPartialItemBefore),
					height: PrecisionSlider_InnerModel.height
				)
			}
			row -= 1
		}
		if row >= model.numberOfItems {
			if model.hasPartialItemAfter {
				return CGSize(
					width: CGFloat(model.scaleRounded * model.sizeOfPartialItemAfter),
					height: PrecisionSlider_InnerModel.height
				)
			}
		}
		return CGSize(
			width: CGFloat(model.scaleRounded),
			height: PrecisionSlider_InnerModel.height
		)
	}

}


public class PrecisionSliderCellModel {
	var title: String?
	var value: Double = 0.0
	var minimumValue: Double = 0.0
	var maximumValue: Double = 1.0
	
	var valueDidChange: Double -> Void = { (value: Double) in
		SwiftyFormLog("value \(value)")
	}
	
	typealias ExpandCollapseAction = (indexPath: NSIndexPath, tableView: UITableView) -> Void
	var expandCollapseAction: ExpandCollapseAction?
}


public class PrecisionSliderCell: UITableViewCell, CellHeightProvider, SelectRowDelegate {
	weak var expandedCell: PrecisionSliderCellExpanded?
	public let model: PrecisionSliderCellModel

	public init(model: PrecisionSliderCellModel) {
		self.model = model
		super.init(style: .Value1, reuseIdentifier: nil)
		selectionStyle = .None
		clipsToBounds = true
		textLabel?.text = model.title
		reloadValueLabel()
	}
	
	public required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func form_cellHeight(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
		return 60
	}
	
	public func form_didSelectRow(indexPath: NSIndexPath, tableView: UITableView) {
		model.expandCollapseAction?(indexPath: indexPath, tableView: tableView)
	}
	
	func reloadValueLabel() {
		detailTextLabel?.text = String(format: "%.3f", model.value)
	}
	
	func sliderDidChange(newValue: Double?) {
		let newValueOrZero = newValue ?? 0.0
		if model.value == newValue {
			return
		}
		model.value = newValueOrZero
		model.valueDidChange(newValueOrZero)
		reloadValueLabel()
	}
}

extension PrecisionSliderCellModel {
	func sliderViewModel() -> PrecisionSlider_InnerModel {
		let instance = PrecisionSlider_InnerModel()
		var count = Int(floor(maximumValue) - ceil(minimumValue))
		if count < 0 {
			print("WARNING: count is negative. maximumValue=\(maximumValue)  minimumValue=\(minimumValue)")
			count = 0
		}
		instance.numberOfItems = count

		let sizeBefore = ceil(minimumValue) - minimumValue
		//print("size before: \(sizeBefore)    \(minimumValue)")
		if sizeBefore > 0.0000001 {
			//print("partial item before. size: \(sizeBefore)   minimumValue: \(minimumValue)")
			instance.hasPartialItemBefore = true
			instance.sizeOfPartialItemBefore = sizeBefore
		}

		let sizeAfter = maximumValue - floor(maximumValue)
		//print("size after: \(sizeAfter)    \(maximumValue)")
		if sizeAfter > 0.0000001 {
			//print("partial item after. size: \(sizeAfter)   minimumValue: \(maximumValue)")
			instance.hasPartialItemAfter = true
			instance.sizeOfPartialItemAfter = sizeAfter
		}
		
		instance.minimumValue = minimumValue
		instance.maximumValue = maximumValue
		
		return instance
	}
}

public class PrecisionSliderCellExpanded: UITableViewCell, CellHeightProvider {
	weak var collapsedCell: PrecisionSliderCell?

	public func form_cellHeight(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
		return PrecisionSlider_InnerModel.height
	}
	
	func sliderDidChange() {
		collapsedCell?.sliderDidChange(sliderView.value)
	}
	
	lazy var sliderView: PrecisionSliderView = {
		let instance = PrecisionSliderView()
		instance.valueDidChange = nil
		return instance
	}()
	
	public init() {
		super.init(style: .Default, reuseIdentifier: nil)
		addSubview(sliderView)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		sliderView.frame = bounds
		
		let tinyDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.001 * Float(NSEC_PER_SEC)))
		dispatch_after(tinyDelay, dispatch_get_main_queue()) {
			self.assignInitialValue()
		}
	}
	
	func assignInitialValue() {
		if sliderView.valueDidChange != nil {
			return
		}
		guard let model = collapsedCell?.model else {
			return
		}
		
		let sliderViewModel = model.sliderViewModel()
		sliderView.model = sliderViewModel
		sliderView.layout.model = sliderViewModel
		sliderView.setNeedsLayout()
		sliderView.setNeedsDisplay()
		sliderView.collectionView.reloadData()
		
		/*
		First we scroll to the right offset
		Next establish two way binding
		*/
		sliderView.scrollToValue(model.value)

		sliderView.valueDidChange = { [weak self] in
			self?.sliderDidChange()
		}
	}
}
