//
//  Extension+UIKit.swift
//  GFExtensions
//
//  Created by 防神 on 2018/8/3.
//  Copyright © 2018年 吃面多放葱. All rights reserved.
//

import Foundation
import UIKit


// iOS scrollview 带有导航栏时自动调整内边距问题
func adjustScrollContentInset(_ controller: UIViewController, _ scrollView: UIScrollView?) {
    if #available(iOS 11.0, *) {
        scrollView?.contentInsetAdjustmentBehavior = .never
    }else{
        controller.automaticallyAdjustsScrollViewInsets = false
    }
}

extension GFCompat where Base: UIViewController {
    func setStatusBarColor(color : UIColor) {
        if UIScreen.gf.isFullScreen {
            if let statusWin = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView {
                if let statusBar = statusWin.value(forKey: "statusBar") as? UIView {
                    statusBar.backgroundColor = color;
                }
            }
        }
    }
    
    func popAction() {
        base.navigationController?.popViewController(animated: true)
    }
    func dismissAction() {
        base.dismiss(animated: true, completion: nil)
    }
}

extension GFCompat where Base: UINavigationController{
    
    func backgroundAlpha(alpha:CGFloat){
        if let barBackgroundView = base.navigationBar.subviews.first{
            if #available(iOS 11.0, *){
                if base.navigationBar.isTranslucent{
                    for view in barBackgroundView.subviews {
                        view.alpha = alpha
                    }
                }else{
                    barBackgroundView.alpha = alpha
                }
            } else {
                barBackgroundView.alpha = alpha
            }
        }
    }
}

extension GFCompat where Base: UIScreen {
    //Size
    static var isFullScreen: Bool {
        if #available(iOS 11, *) {
            guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                return false
            }
            
            if  unwrapedWindow.safeAreaInsets.bottom > 0 {
                print(unwrapedWindow.safeAreaInsets)
                return true
            }
        }
        return false
    }
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var navigationBarHeight: CGFloat {
        return statusBarHeight + UINavigationBar.appearance().gf.height
    }
    
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    static var bottomBarHeight: CGFloat {
        return isFullScreen ? 83 : 49
    }
}

extension CGFloat {
    var appendBottomOffset: CGFloat {
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                return window.safeAreaInsets.bottom
            }
            return 0
        }else{
            return 0
        }
    }
}

extension GFCompat where Base: UIView {
    
    var x: CGFloat {
        set{
            self.base.frame.origin.x = newValue
        }
        get{
            return self.base.frame.origin.x
        }
    }
    
    var y: CGFloat {
        set{
            self.base.frame.origin.y = newValue
        }
        get{
            return self.base.frame.origin.y
        }
    }
    
    var width: CGFloat {
        set{
            self.base.frame.size.width = newValue
        }
        get{
            return self.base.frame.size.width
        }
    }
    
    var height: CGFloat {
        set{
            self.base.frame.size.height = newValue
        }
        get{
            return self.base.frame.size.height
        }
    }
    
    var center: CGPoint {
        set{
            self.base.center = newValue
        }
        get{
            return self.base.center
        }
    }
    
    var centerX: CGFloat {
        set{
            self.base.center.x = newValue
        }
        get{
            return self.base.center.x
        }
    }
    
    var centerY: CGFloat {
        set{
            self.base.center.y = newValue
        }
        get{
            return self.base.center.y
        }
    }
    
    var top: CGFloat{
        get{
            return self.base.frame.minY
        }
    }
    
    var bottom: CGFloat {
        get{
            return self.base.frame.maxY
        }
    }
    
    var left: CGFloat {
        get{
            return self.base.frame.minX
        }
    }
    
    var right: CGFloat {
        get{
            return self.base.frame.maxX
        }
    }
    
    //MARK: View 画圆角
    func roundCorners(radius: CGFloat, _ corners: UIRectCorner = UIRectCorner.allCorners ) {
        let rect = CGRect(x: 0, y: 0, width: self.base.bounds.width, height: self.base.bounds.height);
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        if radius == 0 {
            self.base.layer.mask = nil;
        }else{
            let mask = CAShapeLayer();
            mask.path = path.cgPath;
            mask.frame = rect;
            self.base.layer.mask = mask
        }
    }
    
    //MARK: 过渡色
    @discardableResult func addGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = base.bounds
        gradient.colors = colors.map({$0.cgColor})
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        base.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    //MARK: 获取View的第一响应者
    var firstResponder: UIView? {
        guard !base.isFirstResponder else { return self.base }
        for subview in base.subviews {
            if let firstResponder = subview.gf.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
    
    //MARK: - 截屏
    func screenShot() -> UIImage? {
        var image: UIImage?
        
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = base.isOpaque
            let renderer = UIGraphicsImageRenderer(size: base.frame.size, format: format)
            image = renderer.image { context in
                base.drawHierarchy(in: base.frame, afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(base.frame.size, base.isOpaque, UIScreen.main.scale)
            base.drawHierarchy(in: base.frame, afterScreenUpdates: true)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    //MARK: 获取当前控制器
    func ownerController() -> UIViewController? {
        var n = base.next
        while n != nil {
            if (n is UIViewController) {
                return n as? UIViewController
            }
            n = n?.next
        }
        return nil
    }
    
    //MARK: 阴影
    func addShadow(color: UIColor = UIColor.black.withAlphaComponent(0.05), offset: CGSize = .zero, opacity: Float = 1, shadowRadius: CGFloat = 11) {
        base.layer.shadowColor = color.cgColor
        base.layer.shadowOffset = offset
        base.layer.shadowOpacity = opacity
        base.layer.shadowRadius = shadowRadius
    }
    
    func removeShadow() {
        base.layer.shadowColor = nil
        base.layer.shadowOffset = .zero
        base.layer.shadowOpacity = 0
        base.layer.shadowRadius = 0
    }
    
    // MARK:  UIViewAnimation
    static  func transformRotate(view: UIView, duration: TimeInterval, rotationAngle angle: CGFloat){
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.init(rotationAngle: angle)
        }
    }
    
    static func transformTranslate(view: UIView, duration: TimeInterval, translationX tx: CGFloat, y ty: CGFloat){
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.init(translationX: tx, y: ty)
        }
    }
    
    static func transformScale(view: UIView, duration: TimeInterval, scaleX sx: CGFloat, y sy: CGFloat){
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.init(scaleX: sx, y: sy)
        }
    }
}

extension GFCompat where Base: UILabel {
    func setTextColor(textColor: UIColor, font: UIFont, _ alignment: NSTextAlignment = .center) {
        base.textColor = textColor
        base.font = font
        base.textAlignment = alignment
    }
    func setText(text: String, textColor: UIColor, font: UIFont, _ alignment: NSTextAlignment = .center) {
        base.text = text
        base.textColor = textColor
        base.font = font
        base.textAlignment = alignment
    }
}

extension GFCompat where Base: UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let c = UIGraphicsGetCurrentContext() {
            c.setFillColor(color.cgColor)
            c.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        base.setBackgroundImage(colorImage, for: forState)
    }
}

/// 水印添加
extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    convenience init(view: UIView, scale : CGFloat) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        defer {UIGraphicsEndImageContext()};
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}

extension GFCompat where Base: UIImage {
    /// Add WaterMarkingImage
    ///
    /// - Parameters:
    ///   - image: the image that painted on
    ///   - waterImageName: waterImage
    /// - Returns: the warterMarked image
    static func waterMarkingImage(image : UIImage, with waterImage: UIImage) -> UIImage?{
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let waterImageX = image.size.width * 0.78
        let waterImageY = image.size.height - image.size.width / 5.4
        let waterImageW = image.size.width * 0.2
        let waterImageH = image.size.width * 0.075
        waterImage.draw(in: CGRect(x: waterImageX, y: waterImageY, width: waterImageW, height: waterImageH))
        
        let waterMarkingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return waterMarkingImage
    }
    
    /// Add WaterMarking Text
    ///
    /// - Parameters:
    ///   - image: the image that painted on
    ///   - text: the text that needs painted
    /// - Returns: the waterMarked image
    static func waterMarkingImage(image : UIImage, with text: String) -> UIImage?{
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let str = text as NSString
        let pointY = image.size.height - image.size.width * 0.1
        let point = CGPoint(x: image.size.width * 0.78, y: pointY)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8),
                          NSAttributedString.Key.font           : UIFont.systemFont(ofSize: image.size.width / 25.0)
            ] as [NSAttributedString.Key : Any]
        str.draw(at: point, withAttributes: attributes)
        
        let waterMarkingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return waterMarkingImage
    }
    
    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: base.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height)
        context.clip(to: rect, mask: base.cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func roundCorners(_ cornerRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        let rect = CGRect(origin: CGPoint.zero, size: base.size)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        context?.beginPath()
        context?.addPath(path.cgPath)
        context?.closePath()
        context?.clip()
        
        base.draw(at: CGPoint.zero)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image;
    }
    func crop(ratio: CGFloat) -> UIImage { //将图片裁剪成指定比例（多余部分自动删除）
        //计算最终尺寸
        var newSize:CGSize!
        if base.size.width/base.size.height > ratio {
            newSize = CGSize(width: base.size.height * ratio, height: base.size.height)
        }else{
            newSize = CGSize(width: base.size.width, height: base.size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = base.size.width
        rect.size.height = base.size.height
        rect.origin.x    = (newSize.width - base.size.width ) / 2.0
        rect.origin.y    = (newSize.height - base.size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        base.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func scale(to newSize: CGSize) -> UIImage {//将图片缩放成指定尺寸（多余部分自动删除）
        //计算比例
        let aspectWidth  = newSize.width/base.size.width
        let aspectHeight = newSize.height/base.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        //图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = base.size.width * aspectRatio
        scaledImageRect.size.height = base.size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - base.size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - base.size.height * aspectRatio) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        base.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIColor {
    
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.hasPrefix("0x") {
            cString.removeFirst(2)
        }
        
        if ((cString.count) != 6) {
            self.init(white: 1, alpha: 1)
            return
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension GFCompat where Base: UIColor {
    static func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0 ... 255)/255.0, green: CGFloat.random(in: 0 ... 255)/255.0, blue: CGFloat.random(in: 0 ... 255)/255.0, alpha: 1.0)
    }
}

extension CGFloat {
    ///视图中所有水平值都是宽度为375时设定的逻辑值，这里返回实际的水平方向上的值
    var real: CGFloat {
        return (self * UIScreen.gf.screenWidth) / 375.0
    }
    ///返回该数值在刘海影响下的数值
    var realTopOffset: CGFloat {
        if #available(iOS 11.0, *), let top = UIApplication.shared.keyWindow?.safeAreaInsets.top, top != 0 {
            return (self + top - UIScreen.gf.statusBarHeight).real
        } else {
            // Fallback on earlier versions
            return self.real
        }
    }
}

extension GFCompat where Base: UIScrollView {
    
    func scrollToTop() {
        base.gf.scrollToTopAnimated(true)
    }
    
    func scrollToBottom() {
        base.gf.scrollToBottomAnimated(true)
    }
    
    func scrollToLeft() {
        base.gf.scrollToLeftAnimated(true)
    }
    
    func scrollToRight() {
        base.gf.scrollToRightAnimated(true)
    }
    
    func scrollToTopAnimated(_ animated: Bool) {
        var off = base.contentOffset
        off.y = 0 - base.contentInset.top
        base.setContentOffset(off, animated: animated)
    }
    
    func scrollToBottomAnimated(_ animated: Bool) {
        var off = base.contentOffset
        off.y = base.contentSize.height - base.bounds.size.height + base.contentInset.bottom
        base.setContentOffset(off, animated: animated)
    }
    
    func scrollToLeftAnimated(_ animated: Bool) {
        var off = base.contentOffset
        off.x = 0 - base.contentInset.left
        base.setContentOffset(off, animated: animated)
    }
    
    func scrollToRightAnimated(_ animated: Bool) {
        var off = base.contentOffset
        off.x = base.contentSize.width - base.bounds.size.width + base.contentInset.right
        base.setContentOffset(off, animated: animated)
    }
}

extension GFCompat where Base: UITableView {
    
    func scrollToRow(_ row: Int, in section: Int, atScrollPosition position: UITableView.ScrollPosition, _ animated: Bool) {
        let indexpath = IndexPath(row: row, section: section)
        base.scrollToRow(at: indexpath, at: position, animated: animated)
    }
    
    func insertRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        base.insertRows(at: [indexPath], with: animation)
    }
    
    func insertRow(_ row: Int, in section: Int, withRowAnimation animation: UITableView.RowAnimation) {
        let toInsert = IndexPath(row: row, section: section)
        base.gf.insertRow(at: toInsert, withRowAnimation: animation)
    }
    
    func reloadRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        base.reloadRows(at: [indexPath], with: animation)
    }
    
    func reloadRow(_ row: Int, in section: Int, withRowAnimation animation: UITableView.RowAnimation) {
        let toReload = IndexPath(row: row, section: section)
        base.gf.reloadRow(at: toReload, withRowAnimation: animation)
    }
    
    func deleteRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        
    }
}

//MARK: - UIGestureRecognizer
extension UIGestureRecognizer {
    @discardableResult convenience init(addToView targetView: UIView,
                                        closure: @escaping (UIGestureRecognizer) -> Void) {
        self.init()
        
        GestureTarget.add(gesture: self,
                          closure: closure,
                          toView: targetView)
    }
}

fileprivate class GestureTarget: UIView {
    class ClosureContainer {
        weak var gesture: UIGestureRecognizer?
        let closure: ((UIGestureRecognizer) -> Void)
        
        init(closure: @escaping (UIGestureRecognizer) -> Void) {
            self.closure = closure
        }
    }
    
    var containers = [ClosureContainer]()
    
    convenience init() {
        self.init(frame: .zero)
        isHidden = true
    }
    
    class func add(gesture: UIGestureRecognizer, closure: @escaping (UIGestureRecognizer) -> Void,
                   toView targetView: UIView) {
        let target: GestureTarget
        if let existingTarget = existingTarget(inTargetView: targetView) {
            target = existingTarget
        } else {
            target = GestureTarget()
            targetView.addSubview(target)
        }
        let container = ClosureContainer(closure: closure)
        container.gesture = gesture
        target.containers.append(container)
        
        gesture.addTarget(target, action: #selector(GestureTarget.target(gesture:)))
        targetView.addGestureRecognizer(gesture)
    }
    
    class func existingTarget(inTargetView targetView: UIView) -> GestureTarget? {
        for subview in targetView.subviews {
            if let target = subview as? GestureTarget {
                return target
            }
        }
        return nil
    }
    
    func cleanUpContainers() {
        containers = containers.filter({ $0.gesture != nil })
    }
    
    @objc func target(gesture: UIGestureRecognizer) {
        cleanUpContainers()
        
        for container in containers {
            guard let containerGesture = container.gesture else {
                continue
            }
            
            if gesture === containerGesture {
                container.closure(gesture)
            }
        }
    }
}

extension GFCompat where Base: UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1":                               return "iPhone 7 (CDMA)"
        case "iPhone9,3":                               return "iPhone 7 (GSM)"
        case "iPhone9,2":                               return "iPhone 7 Plus (CDMA)"
        case "iPhone9,4":                               return "iPhone 7 Plus (GSM)"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus (GSM)"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    /// 检查系统语言是否变动
    ///
    /// - Returns: ture 变动,false 未变动
    func langChanged() -> Bool {
        guard let currentLanguage = NSLocale.preferredLanguages.first else {
            return false;
        }
        if let preLanguage = UserDefaults.standard.object(forKey: "localLanguage") as? String {
            if preLanguage != currentLanguage {
                UserDefaults.standard.set(currentLanguage, forKey: "localLanguage");
                return true;
            }else{
                return false;
            }
        }else{
            UserDefaults.standard.set(currentLanguage, forKey: "localLanguage");
            return false;
        }
    }

}

///环境参数，影响上传和服务器连接
class NetEnviroment: NSObject {
    let baseUrl: String
    let bucket: String
    let replacementUrl: String?
    let name: String
    let h5Url: String
    
    init(baseUrlString: String, bucket: String, replacementUrl:String?,
         name: String, emchatKey: String, h5Url: String, emchatApnName: String) {
        self.baseUrl = baseUrlString
        self.bucket = bucket
        self.replacementUrl = replacementUrl
        self.name = name
        self.h5Url = h5Url
    }
    
    var isProductEnvironment: Bool {
        return bucket == "hltravel"
    }
    
    
    static var testServer: NetEnviroment {
        return NetEnviroment(baseUrlString: "http://218.247.21.4:8084",
                          bucket: "hltext", replacementUrl: nil, name: "测试环境（外）", emchatKey: "1125181127181795#hllx-test", h5Url: "http://testwap.honglelx.com", emchatApnName: "开发证书")
    }
    
    
    static var productServer: NetEnviroment {
        return NetEnviroment(baseUrlString: "http://app.honglelx.com",
                          bucket: "hltravel",
                          replacementUrl: "img.honglelx.com/", name: "正式环境", emchatKey: "1125181127181795#hllx-travelshop", h5Url: "http://wap.honglelx.com", emchatApnName: "正式证书")
    }
    
    static var enviroments = [NetEnviroment.productServer,
                              NetEnviroment.testServer]
    
}

let currentEnv = NetEnviroment.enviroments[UserDefaults.gf.networkEnvIndex ?? 0]

