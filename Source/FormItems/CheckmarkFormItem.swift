// MIT license. Copyright (c) 2018 SwiftyFORM. All rights reserved.
import Foundation

public class CheckmarkFormItem: FormItem {
    override func accept(visitor: FormItemVisitor) {
        visitor.visit(object: self)
    }

    public var title: String = ""

    @discardableResult
    public func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    public typealias SyncBlock = (_ value: Bool, _ animated: Bool) -> Void
    public var syncCellWithValue: SyncBlock = { (value: Bool, animated: Bool) in
        SwiftyFormLog("sync is not overridden")
    }

    internal var innerValue: Bool = false
    public var value: Bool {
        get {
            self.innerValue
        }
        set {
            self.setValue(newValue, animated: false)
        }
    }

    public typealias ValueDidChangeBlock = (_ value: Bool) -> Void
    public var valueDidChangeBlock: ValueDidChangeBlock = { (value: Bool) in
        SwiftyFormLog("not overridden")
    }

    public func valueDidChange(_ value: Bool) {
        innerValue = value
        valueDidChangeBlock(value)
    }

    public func setValue(_ value: Bool, animated: Bool) {
        innerValue = value
        syncCellWithValue(value, animated)
    }
    
}

