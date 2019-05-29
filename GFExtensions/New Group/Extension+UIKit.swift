//
//  Extension+UIKit.swift
//  GFExtensions
//
//  Created by 防神 on 2018/8/3.
//  Copyright © 2018年 吃面多放葱. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CoreServices

extension PHAsset {
    var gf_isGif: Bool {
        let resource = PHAssetResource.assetResources(for: self).first!
        // 通过统一类型标识符(uniform type identifier) UTI 来判断
        let uti = resource.uniformTypeIdentifier as CFString
        return UTTypeConformsTo(uti, kUTTypeGIF)
    }
}

extension UIViewController {
    func gf_setStatusBarColor(color : UIColor) {
        if UIScreen.gf_isFullScreen {
            if let statusWin = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView {
                if let statusBar = statusWin.value(forKey: "statusBar") as? UIView {
                    statusBar.backgroundColor = color;
                }
            }
        }
    }
    
    @objc func gf_popAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func gf_dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UINavigationController{
    
    func gf_backgroundAlpha(alpha:CGFloat){
        if let barBackgroundView = navigationBar.subviews.first{
            if #available(iOS 11.0, *){
                if navigationBar.isTranslucent{
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

extension UIScreen {
    //Size
    static var gf_isFullScreen: Bool {
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
    
    static var gf_screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var gf_screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var gf_navigationBarHeight: CGFloat {
        return gf_statusBarHeight + UINavigationBar.appearance().gf_height
    }
    
    static var gf_statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    static var gf_bottomSafeHeight: CGFloat {
        return gf_isFullScreen ? (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) : 0
    }
    
    static var gf_bottomBarHeight: CGFloat {
        return gf_isFullScreen ? 83 : 49
    }
}

extension UIView {
    
    var gf_x: CGFloat {
        set{
            self.frame.origin.x = newValue
        }
        get{
            return self.frame.origin.x
        }
    }
    
    var gf_y: CGFloat {
        set{
            self.frame.origin.y = newValue
        }
        get{
            return self.frame.origin.y
        }
    }
    
    var gf_width: CGFloat {
        set{
            self.frame.size.width = newValue
        }
        get{
            return self.frame.size.width
        }
    }
    
    var gf_height: CGFloat {
        set{
            self.frame.size.height = newValue
        }
        get{
            return self.frame.size.height
        }
    }
    
    var gf_center: CGPoint {
        set{
            self.center = newValue
        }
        get{
            return self.center
        }
    }
    
    var gf_centerX: CGFloat {
        set{
            self.center.x = newValue
        }
        get{
            return self.center.x
        }
    }
    
    var gf_centerY: CGFloat {
        set{
            self.center.y = newValue
        }
        get{
            return self.center.y
        }
    }
    
    var gf_top: CGFloat{
        get{
            return self.frame.minY
        }
    }
    
    var gf_bottom: CGFloat {
        get{
            return self.frame.maxY
        }
    }
    
    var gf_left: CGFloat {
        get{
            return self.frame.minX
        }
    }
    
    var gf_right: CGFloat {
        get{
            return self.frame.maxX
        }
    }
    
    //MARK: View 画圆角
    func gf_roundCorners(radius: CGFloat, _ corners: UIRectCorner = UIRectCorner.allCorners ) {
        let rect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        if radius == 0 {
            self.layer.mask = nil;
        }else{
            let mask = CAShapeLayer();
            mask.path = path.cgPath;
            mask.frame = rect;
            self.layer.mask = mask
        }
    }
    
    //MARK: 过渡色
    @discardableResult func addGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map({$0.cgColor})
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    //MARK: 获取View的第一响应者
    var gf_firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.gf_firstResponder {
                return firstResponder
            }
        }
        return nil
    }
    
    //MARK: - 截屏
    func gf_screenShot() -> UIImage? {
        var image: UIImage?
        
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = isOpaque
            let renderer = UIGraphicsImageRenderer(size: frame.size, format: format)
            image = renderer.image { context in
                drawHierarchy(in: frame, afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, UIScreen.main.scale)
            drawHierarchy(in: frame, afterScreenUpdates: true)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    //MARK: 获取当前控制器
    func gf_ownerController() -> UIViewController? {
        var n = self.next
        while n != nil {
            if (n is UIViewController) {
                return n as? UIViewController
            }
            n = n?.next
        }
        return nil
    }
    
    //MARK: 阴影
    func gf_addShadow(color: UIColor = UIColor.black.withAlphaComponent(0.05), offset: CGSize = .zero, opacity: Float = 1, shadowRadius: CGFloat = 11) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
    }
    
    func gf_removeShadow() {
        self.layer.shadowColor = nil
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
    }
    
    // MARK:  UIViewAnimation
    class  func gf_transformRotate(view: UIView, duration: TimeInterval, rotationAngle angle: CGFloat){
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.init(rotationAngle: angle)
        }
    }
    
    class func gf_transformTranslate(view: UIView, duration: TimeInterval, translationX tx: CGFloat, y ty: CGFloat){
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.init(translationX: tx, y: ty)
        }
    }
    
    class func gf_transformScale(view: UIView, duration: TimeInterval, scaleX sx: CGFloat, y sy: CGFloat){
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform.init(scaleX: sx, y: sy)
        }
    }
}

extension UILabel {
    func gf_setTextColor(textColor: UIColor, font: UIFont, _ alignment: NSTextAlignment = .center) {
        self.textColor = textColor
        self.font = font
        self.textAlignment = alignment
    }
    func gf_setText(text: String, textColor: UIColor, font: UIFont, _ alignment: NSTextAlignment = .center) {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = alignment
    }
}

extension UIButton {
    
    func gf_setBackgroundColor(color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let c = UIGraphicsGetCurrentContext() {
            c.setFillColor(color.cgColor)
            c.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
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
    
    public func gf_roundCorners(_ cornerRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        context?.beginPath()
        context?.addPath(path.cgPath)
        context?.closePath()
        context?.clip()
        
        draw(at: CGPoint.zero)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    convenience init(view: UIView, scale : CGFloat) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        defer {UIGraphicsEndImageContext()};
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
    
    /// Add WaterMarkingImage
    ///
    /// - Parameters:
    ///   - image: the image that painted on
    ///   - waterImageName: waterImage
    /// - Returns: the warterMarked image
    static func gf_waterMarkingImage(image : UIImage, with waterImage: UIImage) -> UIImage?{
        
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
    static func gf_waterMarkingImage(image : UIImage, with text: String) -> UIImage?{
        
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
}

extension UIColor {
    
    convenience init(gf_hex: String) {
        var cString:String = gf_hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
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
    
    static func gf_randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0 ... 255)/255.0, green: CGFloat.random(in: 0 ... 255)/255.0, blue: CGFloat.random(in: 0 ... 255)/255.0, alpha: 1.0)
    }
}

extension CGFloat {
    ///视图中所有水平值都是宽度为375时设定的逻辑值，这里返回实际的水平方向上的值
    var real: CGFloat {
        return (self * UIScreen.gf_screenWidth) / 375.0
    }
    ///返回该数值在刘海影响下的数值
    var realTopOffset: CGFloat {
        if #available(iOS 11.0, *), let top = UIApplication.shared.keyWindow?.safeAreaInsets.top, top != 0 {
            return (self + top - UIScreen.gf_statusBarHeight).real
        } else {
            // Fallback on earlier versions
            return self.real
        }
    }
}

extension UIImage {
    
    func gf_crop(ratio: CGFloat) -> UIImage { //将图片裁剪成指定比例（多余部分自动删除）
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func gf_scale(to newSize: CGSize) -> UIImage {//将图片缩放成指定尺寸（多余部分自动删除）
        //计算比例
        let aspectWidth  = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        //图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIScrollView {
    
    func gf_scrollToTop() {
        self.gf_scrollToTopAnimated(true)
    }
    
    func gf_scrollToBottom() {
        self.gf_scrollToBottomAnimated(true)
    }
    
    func gf_scrollToLeft() {
        self.gf_scrollToLeftAnimated(true)
    }
    
    func gf_scrollToRight() {
        self.gf_scrollToRightAnimated(true)
    }
    
    func gf_scrollToTopAnimated(_ animated: Bool) {
        var off = self.contentOffset
        off.y = 0 - self.contentInset.top
        self.setContentOffset(off, animated: animated)
    }
    
    func gf_scrollToBottomAnimated(_ animated: Bool) {
        var off = self.contentOffset
        off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom
        self.setContentOffset(off, animated: animated)
    }
    
    func gf_scrollToLeftAnimated(_ animated: Bool) {
        var off = self.contentOffset
        off.x = 0 - self.contentInset.left
        self.setContentOffset(off, animated: animated)
    }
    
    func gf_scrollToRightAnimated(_ animated: Bool) {
        var off = self.contentOffset
        off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right
        self.setContentOffset(off, animated: animated)
    }
}

extension UITableView {
    
    func gf_scrollToRow(_ row: Int, in section: Int, atScrollPosition position: UITableView.ScrollPosition, _ animated: Bool) {
        let indexpath = IndexPath(row: row, section: section)
        self.scrollToRow(at: indexpath, at: position, animated: animated)
    }
    
    func gf_insertRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        self.insertRows(at: [indexPath], with: animation)
    }
    
    func gf_insertRow(_ row: Int, in section: Int, withRowAnimation animation: UITableView.RowAnimation) {
        let toInsert = IndexPath(row: row, section: section)
        self.gf_insertRow(at: toInsert, withRowAnimation: animation)
    }
    
    func gf_reloadRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        self.reloadRows(at: [indexPath], with: animation)
    }
    
    func gf_reloadRow(_ row: Int, in section: Int, withRowAnimation animation: UITableView.RowAnimation) {
        let toReload = IndexPath(row: row, section: section)
        self.gf_reloadRow(at: toReload, withRowAnimation: animation)
    }
    
    func gf_deleteRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        
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

extension UIDevice {
    var gf_modelName: String {
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
}


