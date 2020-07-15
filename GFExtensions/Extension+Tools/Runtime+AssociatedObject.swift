//
//  Runtime+AssociatedObject.swift
//  GFExtensions
//
//  Created by 防神 on 2019/11/14.
//  Copyright © 2019 吃面多放葱. All rights reserved.
//

import ObjectiveC

public protocol AssociatedObjectStore {}

extension AssociatedObjectStore {
    
    /// 设置关联属性
    /// - Parameters:
    ///   - object: 关联值
    ///   - key: 关联值指针定义
    public func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 获取关联属性
    /// - Parameter key: 关联值指针定义
    public func getAssociatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }
    
    /// 获取关联值
    /// - Parameters:
    ///   - key: 关联值指针定义
    ///   - default: 默认关联值
    public func getAssociatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T) -> T {
        if let object: T = self.getAssociatedObject(forKey: key) {
            return object
        }
        let object = `default`()
        setAssociatedObject(object, forKey: key)
        return object
    }
}
    
