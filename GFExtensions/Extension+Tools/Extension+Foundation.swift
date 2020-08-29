//
//  Extension+Foundation.swift
//  GFExtensions
//
//  Created by 防神 on 2018/8/3.
//  Copyright © 2018年 吃面多放葱. All rights reserved.
//

import Foundation

// MARK: - Data
public extension GFCompat where Base == Data {
    var hexString: String { // 将Data转换为String
        return base.map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - Date
public extension GFCompat where Base == Date {
    /// 返回指定格式的日期字符串
    ///
    /// - Parameter formatter: e.g. "yyyy-MM-dd HH:ss"
    /// - Returns: e.g. "2019-05-01 13:23"
    func string(with formatter: String) -> String {
        let df = DateFormatter()
        df.dateFormat = formatter
        return df.string(from: base)
    }

    /// 获取系统时间戳
    ///
    /// - Returns: timeStamp since 1970
    static func getSystimeStamp() -> String {
        let timeStamp = Date().timeIntervalSince1970
        return "\(timeStamp)"
    }
}

// MARK: - String
public extension String {
    func startIndex(offsetBy n: Int) -> String.Index {
        guard n >= 0 else { return startIndex }
        guard n < count else { return endIndex }
        return index(startIndex, offsetBy: n)
    }
}
public extension GFCompat where Base == String {}
// MARK: 正则校验
public extension GFCompat where Base == String {
    // 电话号码
    var isPhoneNumber: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^(\\+86){0,1}1[3|4|5|6|7|8|9](\\d){9}$")
        return predicate.evaluate(with: base)
    }

    // 企业名称
    var isEnterprise: Bool {
        let regex = "^[A-Za-z0-9\\u4e00-\\u9fa5]{2,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: base)
    }

    // 统一社会信用代码
    var isEnterpriseCardID: Bool {
        let regex = "[0-9A-HJ-NPQRTUWXY]{2}\\d{6}[0-9A-HJ-NPQRTUWXY]{10}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: base)
    }

    // 邮箱
    var isEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: base)
    }

    // 身份证
    var isUserID: Bool {
        let regex = "(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: base)
    }

    // IP地址
    var isIP: Bool {
        let regex = "((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: base)
    }

    // 车牌号
    var isCarID: Bool {
        let regex = "^[\\u4e00-\\u9fa5]{1}[a-hj-zA-HJ-Z]{1}[a-hj-zA-HJ-Z_0-9]{4}[a-hj-zA-HJ-Z_0-9_\\u4e00-\\u9fa5]$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: base)
    }

    // 企业注册号
    var isRegisterCode: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9\\u4e00-\\u9fa5]{0,7}[0-9]{6,13}[u4e00-\\u9fa5]{0,1}$")
        return predicate.evaluate(with: base)
    }
}

// MARK: String 格式处理
public extension GFCompat where Base == String {
    
    /// 过滤数字字符串中的0
    func trimZero() -> String {
        if base == "0" {
            return base
        }
        var string = base.trimmingCharacters(in: ["0"])//去掉字符串两边的0
        // 第一个字符如果是".",则补"0"
        if string.first == "." {
            string.insert("0", at: string.startIndex)
        }

        if string.hasSuffix(".") {
            let i = string.firstIndex(of: ".")!
            string.remove(at: i)
        }
        return string
    }
    
    /// 格式化包含小数点的数字字符串(常用场景: 商品价格显示)
    /// - Parameters:
    ///   - leftAttrs: 小数点之前(包含小数点)的格式
    ///   - rightAttrs: 小数点之后格式
    func formatAttributeString(_ leftAttrs: [NSAttributedString.Key: Any]? = nil, _ rightAttrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString {
        if base.contains(".") {
            let strArr = base.components(separatedBy: ["."])
            let str = NSMutableAttributedString()
            let leftAttrStr = NSMutableAttributedString(string: strArr[0], attributes: leftAttrs)
            let rightAttrStr = NSMutableAttributedString(string: strArr[1], attributes: rightAttrs)
            let dotAttrStr = NSMutableAttributedString(string: ".", attributes: leftAttrs)
            str.append(leftAttrStr)
            str.append(dotAttrStr)
            str.append(rightAttrStr)
            return str
        } else {
            return NSAttributedString(string: base, attributes: leftAttrs)
        }
    }
    
    /// ISO8601字符串日期转date
    func dateFromISO8601() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return formatter.date(from: base)
    }
}

// MARK: - Sequence, Array
public extension Sequence {
    ///
    /// 返回一个数组，其中包含将给定闭包映射到序列元素上的结果。
    ///
    ///     let articleIDs = articles.map { $0.id }
    ///     let articleIDs = articles.map(\.id)
    ///     let articleSources = articles.map(\.source)
    ///
    /// - Parameter keyPath: 特定类型T拥有的 KeyPath
    /// - Returns: 包含此序列的已转换元素的数组。
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    /// 通过指定 KeyPath 为排序依据，进行排序
    ///
    ///     playlist.songs.sorted(by: \.name)
    ///     playlist.songs.sorted(by: \.dateAdded)
    ///     playlist.songs.sorted(by: \.ratings.worldWide)
    ///
    ///  - Parameter keyPath: 排序依据 KeyPath
    ///  - Returns: 排序好的数组
    ///
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

public extension Array {
    /// 数组越界处理,返回nil
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element: Equatable {
    /// 过滤重复元素,Element 满足 Equatable协议
     func filterDuplicated() -> [Element] {
         var result = [Element]()
         for item in self {
             if !self.contains(item) {
                 result.append(item)
             }
         }
         return result
     }
 }

// MARK: - FileManager
public extension GFCompat where Base: FileManager {
    
    /// 文档目录
    static func docDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }

    /// 缓存目录
    static func cacheDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

// MARK: - UserDefault
public extension GFCompat where Base: UserDefaults {
    enum UserDataKeys: String {
        case userid
        case userToken
        case telephone
        case appstoreVersion // 苹果商店版本号，用于启动页
        case serverVersion // 本地软件版本号，用于更新提示
        case netEnviroment //当前接口环境
        case userAlias // 最后一次设置的别名
        case enablePush // 开启推送
    }

    static var enablePush: Bool? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.enablePush.rawValue)
        }
        get {
            return Base.standard.bool(forKey: UserDataKeys.enablePush.rawValue)
        }
    }

    static var telephone: String? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.telephone.rawValue)
        }
        get {
            return Base.standard.string(forKey: UserDataKeys.telephone.rawValue)
        }
    }

    /// 别名,用来设置推送相关信息
    static var userAlias: String? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.userAlias.rawValue)
        }
        get {
            return Base.standard.string(forKey: UserDataKeys.userAlias.rawValue)
        }
    }

    static var userId: Int? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.userid.rawValue)
        }
        get {
            return Base.standard.integer(forKey: UserDataKeys.userid.rawValue)
        }
    }

    static var userToken: String? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.userToken.rawValue)
        }
        get {
            return Base.standard.string(forKey: UserDataKeys.userToken.rawValue)
        }
    }

    static var appstoreVersion: String? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.appstoreVersion.rawValue)
        }
        get {
            return Base.standard.string(forKey: UserDataKeys.appstoreVersion.rawValue)
        }
    }

    static var serverVersion: String? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.serverVersion.rawValue)
        }
        get {
            return Base.standard.string(forKey: UserDataKeys.serverVersion.rawValue)
        }
    }

    /// 接口环境
    static var networkEnvIndex: Int? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.netEnviroment.rawValue)
        }
        get {
            return Base.standard.integer(forKey: UserDataKeys.netEnviroment.rawValue)
        }
    }

    /// 应用第一次启动
    static func firstLaunch() -> Bool {
        let hasBeenLaunched = "hasBeenLaunched"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }

    /// 当前版本第一次启动
    static func versionFirstLaunch() -> Bool {
        // 主程序版本号
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as! String

        // 上次启动的版本号
        let hasBeenLaunchedOfNewVersion = "hasBeenLaunchedOfNewVersion"
        let lastLaunchVersion = UserDefaults.standard.string(forKey:
            hasBeenLaunchedOfNewVersion)

        // 版本号比较
        let isFirstLaunchOfNewVersion = majorVersion != lastLaunchVersion
        if isFirstLaunchOfNewVersion {
            UserDefaults.standard.set(majorVersion, forKey:
                hasBeenLaunchedOfNewVersion)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunchOfNewVersion
    }
}

// MARK: - DispatchQueue
public extension DispatchQueue {
    /// SwifterSwift: A Boolean value indicating whether the current
    /// dispatch queue is the main queue.
    static var isMainQueue: Bool {
        enum Static {
            static var key: DispatchSpecificKey<Void> = {
                let key = DispatchSpecificKey<Void>()
                DispatchQueue.main.setSpecific(key: key, value: ())
                return key
            }()
        }
        return DispatchQueue.getSpecific(key: Static.key) != nil
    }
}

public extension DispatchQueue {
    /// SwifterSwift: Returns a Boolean value indicating whether the current
    /// dispatch queue is the specified queue.
    ///
    /// - Parameter queue: The queue to compare against.
    /// - Returns: `true` if the current queue is the specified queue, otherwise `false`.
    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<Void>()

        queue.setSpecific(key: key, value: ())

        defer { queue.setSpecific(key: key, value: nil) }

        return DispatchQueue.getSpecific(key: key) != nil
    }
}

public extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->()) {
        if DispatchQueue.isMainQueue {
            block()
        } else {
            async { block() }
        }
    }
    
    static func safeMainAsync(work: @escaping @convention(block) () -> Swift.Void) {
        if isMainQueue { work() }
        else { DispatchQueue.main.async(execute: work) }
    }
}

// MARK: - Lock
//
// Usage:
//   func myMethodLocked(anObj: AnyObject!) {
//       synchronized(anObj) {
//        // 在括号内持有 anObj 锁
//       }
//   }

public func synchronized(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/// 日志输出
/// - Parameters:
///   - message: 输出信息
///   - file: 文件名
///   - method: 方法名
///   - line: 行数
public func printLog<T>(_ message: T,
                    file: String = #file,
                  method: String = #function,
                    line: Int = #line)
{
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
