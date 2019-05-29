//
//  Extension+Foundation.swift
//  GFExtensions
//
//  Created by 防神 on 2018/8/3.
//  Copyright © 2018年 吃面多放葱. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static func gf_launchFirst() -> Bool {//应用第一次启动
        let hasBeenLaunched = "hasBeenLaunched"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunched)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
    
    static func gf_versionLaunchFirst() -> Bool {//当前版本第一次启动
        //主程序版本号
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as! String
        
        //上次启动的版本号
        let hasBeenLaunchedOfNewVersion = "hasBeenLaunchedOfNewVersion"
        let lastLaunchVersion = UserDefaults.standard.string(forKey:
            hasBeenLaunchedOfNewVersion)
        
        //版本号比较
        let isFirstLaunchOfNewVersion = majorVersion != lastLaunchVersion
        if isFirstLaunchOfNewVersion {
            UserDefaults.standard.set(majorVersion, forKey:
                hasBeenLaunchedOfNewVersion)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunchOfNewVersion
    }
}

extension Data {
    var gf_hexString: String {//将Data转换为String
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Date {
    func gf_string(with formatter: String) -> String {
        let df = DateFormatter()
        df.dateFormat = formatter
        return df.string(from: self)
    }
}

//MARK: - 正则校验
extension String {
    //电话号码
    var gf_isPhoneNumber: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^(\\+86){0,1}1[3|4|5|6|7|8|9](\\d){9}$");
        return predicate.evaluate(with: self)
    }
    //企业名称
    var gf_isEnterprise: Bool {
        let regex = "^[A-Za-z0-9\\u4e00-\\u9fa5]{2,20}$";
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex);
        return predicate.evaluate(with: self)
    }
    //统一社会信用代码
    var gf_isEnterpriseCardID: Bool {
        
        let regex = "[0-9A-HJ-NPQRTUWXY]{2}\\d{6}[0-9A-HJ-NPQRTUWXY]{10}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex);
        return predicate.evaluate(with: self)
    }
    //邮箱
    var gf_isEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    //身份证
    var gf_isUserID: Bool {
        let regex = "(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)";
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    //IP地址
    var gf_isIP: Bool {
        let regex = "((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))";
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    //车牌号
    var gf_isCarID: Bool {
        let regex = "^[\\u4e00-\\u9fa5]{1}[a-hj-zA-HJ-Z]{1}[a-hj-zA-HJ-Z_0-9]{4}[a-hj-zA-HJ-Z_0-9_\\u4e00-\\u9fa5]$";
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    //企业注册号
    var gf_isRegisterCode: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9\\u4e00-\\u9fa5]{0,7}[0-9]{6,13}[u4e00-\\u9fa5]{0,1}$");
        return predicate.evaluate(with: self)
    }
}

//MARK: String 格式处理
extension String {
    func gf_trimZero() -> String {
        
        if self == "0" {
            return self;
        }
        var string = self.trimmingCharacters(in: ["0"]);
        //第一个字符如果是".",则补"0"
        if string.first == "." {
            string.insert("0", at: string.startIndex)
        }
        
        if string.hasSuffix("."){
            let i = string.index(of: ".")!;
            string.remove(at: i);
        }
        return string;
    }
    
    func gf_formatAttributeString(_ leftAttrs: [NSAttributedString.Key: Any]? = nil,_ rightAttrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString{
        
        if self.contains(".") {
            let strArr = self.components(separatedBy: ["."]);
            let str = NSMutableAttributedString();
            let leftAttrStr = NSMutableAttributedString.init(string: strArr[0], attributes: leftAttrs);
            let rightAttrStr = NSMutableAttributedString.init(string: strArr[1], attributes: rightAttrs);
            let dotAttrStr = NSMutableAttributedString.init(string: ".", attributes: leftAttrs);
            str.append(leftAttrStr);
            str.append(dotAttrStr);
            str.append(rightAttrStr);
            return str;
        }else{
            return NSAttributedString.init(string: self, attributes: leftAttrs);
        }
    }
    
    func gf_dateFromISO8601() -> Date? {
        let formatter = DateFormatter() ;
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'";
        return formatter.date(from: self);
    }
}

extension Collection {//数组越界解决方案
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension FileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}
