//
//  UIBtton+touchEnlarge.swift
//  GFExtensions
//
//  Created by 防神 on 2019/11/14.
//  Copyright © 2019 吃面多放葱. All rights reserved.
//

import Foundation
import UIKit

private var topKey: UInt8 = 0
private var bottomKey: UInt8 = 0
private var leftKey: UInt8 = 0
private var rightKey: UInt8 = 0

protocol UIViewEnlarge: UIView {}
extension UIViewEnlarge {
    var top: NSNumber {
        get { return associatedObject(base: self, key: &topKey) { 0 } }
        set { associateObject(base: self, key: &topKey, value: newValue) }
    }

    var bottom: NSNumber {
        get { return associatedObject(base: self, key: &bottomKey) { 0 } }
        set { associateObject(base: self, key: &bottomKey, value: newValue) }
    }

    var left: NSNumber {
        get { return associatedObject(base: self, key: &leftKey) { 0 } }
        set { associateObject(base: self, key: &leftKey, value: newValue) }
    }

    var right: NSNumber {
        get { return associatedObject(base: self, key: &rightKey) { 0 } }
        set { associateObject(base: self, key: &rightKey, value: newValue) }
    }

    func setEnlargeEdge(_ inset: UIEdgeInsets) {
        setEnlargeEdge(top: Float(inset.top), bottom: Float(inset.bottom), left: Float(inset.left), right: Float(inset.right))
    }

    func setEnlargeEdge(top: Float, bottom: Float, left: Float, right: Float) {
        self.top = NSNumber(value: top)
        self.left = NSNumber(value: left)
        self.right = NSNumber(value: right)
        self.bottom = NSNumber(value: bottom)
    }

    func setEnlargeEdge(_ surround: Float) {
        top = NSNumber(value: surround)
        left = NSNumber(value: surround)
        right = NSNumber(value: surround)
        bottom = NSNumber(value: surround)
    }

    func enlargedRect() -> CGRect {
        let top = self.top
        let bottom = self.bottom
        let left = self.left
        let right = self.right

        if top.floatValue >= 0, bottom.floatValue >= 0, left.floatValue >= 0, right.floatValue >= 0 {
            return CGRect(
                x: bounds.origin.x - CGFloat(left.floatValue),
                y: bounds.origin.y - CGFloat(top.floatValue),
                width: bounds.size.width + CGFloat(left.floatValue) + CGFloat(right.floatValue),
                height: bounds.size.height + CGFloat(top.floatValue) + CGFloat(bottom.floatValue)
            )
        } else {
            return bounds
        }
    }
}

private func associatedObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, initialiser: () -> ValueType) -> ValueType {
    if let associated = objc_getAssociatedObject(base, key) as? ValueType { return associated }

    let associated = initialiser()

    objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)

    return associated
}

private func associateObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}

private func shtSwizzleMethod(cls: AnyClass?, ori: Selector, new: Selector) {
    guard let oriMethod = class_getInstanceMethod(cls, ori) else { return }
    guard let newMethod = class_getInstanceMethod(cls, new) else { return }
    if class_addMethod(cls, ori, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
        class_replaceMethod(cls, new, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod))
    } else {
        method_exchangeImplementations(oriMethod, newMethod)
    }
}

extension UIButton: UIViewEnlarge {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = enlargedRect()

        if rect.equalTo(bounds) { return super.point(inside: point, with: event) }

        return rect.contains(point) ? true : false
    }
}

extension UIImageView: UIViewEnlarge {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = enlargedRect()

        if rect.equalTo(bounds) { return super.point(inside: point, with: event) }

        return rect.contains(point) ? true : false
    }
}
