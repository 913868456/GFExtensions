//
//  Extension+Foundation.swift
//  GFExtensions
//
//  Created by 防神 on 2018/8/3.
//  Copyright © 2018年 吃面多放葱. All rights reserved.
//

import Foundation

extension GFCompat where Base == Data {
    var hexString: String { // 将Data转换为String
        return base.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension GFCompat where Base == String {}

extension GFCompat where Base == Date {
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

// MARK: - 正则校验

extension GFCompat where Base == String {
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

extension GFCompat where Base == String {
    func trimZero() -> String {
        if base == "0" {
            return base
        }
        var string = base.trimmingCharacters(in: ["0"])
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

    func dateFromISO8601() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return formatter.date(from: base)
    }
}

extension Collection { // 数组越界解决方案
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension GFCompat where Base: FileManager {
    static func docDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }

    static func cacheDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

extension GFCompat where Base: UserDefaults {
    enum UserDataKeys: String {
        case userid
        case userToken
        case telephone
        case appstoreVersion // 苹果商店版本号，用于启动页
        case serverVersion // 软件版本号，用于更新提示
        case netEnviroment
        case userAlias // 最后一次设置的别名
        case enablePush
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

    static var networkEnvIndex: Int? {
        set {
            Base.standard.set(newValue, forKey: UserDataKeys.netEnviroment.rawValue)
        }
        get {
            return Base.standard.integer(forKey: UserDataKeys.netEnviroment.rawValue)
        }
    }

    static func firstLaunch() -> Bool { // 应用第一次启动
        let hasBeenLaunched = "hasBeenLaunched"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }

    static func versionFirstLaunch() -> Bool { // 当前版本第一次启动
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
