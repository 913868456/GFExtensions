//
//  Extension+UIKit.swift
//  GFExtensions
//
//  Created by 防神 on 2018/8/3.
//  Copyright © 2018年 吃面多放葱. All rights reserved.
//

import CoreGraphics
import Foundation
import ImageIO
import UIKit
import Photos

// MARK: UIEdgeInsets

public extension GFCompat where Base == UIEdgeInsets {
    static func all(_ side: CGFloat) -> UIEdgeInsets {
        return .init(top: side, left: side, bottom: side, right: side)
    }

    static func margin(horizon: CGFloat = 0, vertical: CGFloat = 0) -> UIEdgeInsets {
        return Base(top: vertical, left: horizon, bottom: vertical, right: horizon)
    }

    static func left(_ value: CGFloat) -> UIEdgeInsets {
        return Base(top: 0, left: value, bottom: 0, right: 0)
    }

    static func right(_ value: CGFloat) -> UIEdgeInsets {
        return Base(top: 0, left: 0, bottom: 0, right: value)
    }

    static func top(_ value: CGFloat) -> UIEdgeInsets {
        return Base(top: value, left: 0, bottom: 0, right: 0)
    }

    static func bottom(_ value: CGFloat) -> UIEdgeInsets {
        return Base(top: 0, left: 0, bottom: value, right: 0)
    }
}

// MARK: - UIViewController

public extension GFCompat where Base: UIViewController {
    // 适配scrollview边距
    func adjustScrollContentInset(_ scroll: UIScrollView?) {
        if #available(iOS 11.0, *) {
            scroll?.contentInsetAdjustmentBehavior = .never
        } else {
            base.automaticallyAdjustsScrollViewInsets = false
        }
    }

    func setStatusBarColor(color: UIColor) {
        if UIScreen.gf.isFullScreen {
            if let statusWin = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView {
                if let statusBar = statusWin.value(forKey: "statusBar") as? UIView {
                    statusBar.backgroundColor = color
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

// MARK: - UINavigationController

public extension GFCompat where Base: UINavigationController {
    /// 设置导航栏背景透明度
    func backgroundAlpha(alpha: CGFloat) {
        if let barBackgroundView = base.navigationBar.subviews.first {
            if #available(iOS 11.0, *) {
                if base.navigationBar.isTranslucent {
                    for view in barBackgroundView.subviews {
                        view.alpha = alpha
                    }
                } else {
                    barBackgroundView.alpha = alpha
                }
            } else {
                barBackgroundView.alpha = alpha
            }
        }
    }
}

// MARK: - UIScreen

public extension GFCompat where Base: UIScreen {
    /// Size
    static var isFullScreen: Bool {
        if #available(iOS 11, *) {
            guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                return false
            }

            if unwrapedWindow.safeAreaInsets.bottom > 0 {
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

// MARK: - UIView

public extension GFCompat where Base: UIView {
    var x: CGFloat {
        set {
            base.frame.origin.x = newValue
        }
        get {
            return base.frame.origin.x
        }
    }

    var y: CGFloat {
        set {
            base.frame.origin.y = newValue
        }
        get {
            return base.frame.origin.y
        }
    }

    var width: CGFloat {
        set {
            base.frame.size.width = newValue
        }
        get {
            return base.frame.size.width
        }
    }

    var height: CGFloat {
        set {
            base.frame.size.height = newValue
        }
        get {
            return base.frame.size.height
        }
    }

    var center: CGPoint {
        set {
            base.center = newValue
        }
        get {
            return base.center
        }
    }

    var centerX: CGFloat {
        set {
            base.center.x = newValue
        }
        get {
            return base.center.x
        }
    }

    var centerY: CGFloat {
        set {
            base.center.y = newValue
        }
        get {
            return base.center.y
        }
    }

    var top: CGFloat {
        return base.frame.minY
    }

    var bottom: CGFloat {
        return base.frame.maxY
    }

    var left: CGFloat {
        return base.frame.minX
    }

    var right: CGFloat {
        return base.frame.maxX
    }

    /// 画圆角
    func roundCorners(radius: CGFloat, _ corners: UIRectCorner = UIRectCorner.allCorners) {
        let rect = CGRect(x: 0, y: 0, width: base.bounds.width, height: base.bounds.height)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))

        if radius == 0 {
            base.layer.mask = nil
        } else {
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            mask.frame = rect
            base.layer.mask = mask
        }
    }

    /// 渐变色
    @discardableResult
    func addGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = base.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        base.layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    /// 获取View的第一响应者
    var firstResponder: UIView? {
        guard !base.isFirstResponder else { return base }
        for subview in base.subviews {
            if let firstResponder = subview.gf.firstResponder {
                return firstResponder
            }
        }
        return nil
    }

    /// 截屏
    func screenShot() -> UIImage? {
        var image: UIImage?

        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = base.isOpaque
            let renderer = UIGraphicsImageRenderer(size: base.frame.size, format: format)
            image = renderer.image { _ in
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

    /// 获取当前控制器
    func ownerController() -> UIViewController? {
        var n = base.next
        while n != nil {
            if n is UIViewController {
                return n as? UIViewController
            }
            n = n?.next
        }
        return nil
    }

    /// 阴影
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

    /// UIViewAnimation 旋转
    static func transformRotate(view: UIView, duration: TimeInterval, rotationAngle angle: CGFloat) {
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    /// 平移
    static func transformTranslate(view: UIView, duration: TimeInterval, translationX tx: CGFloat, y ty: CGFloat) {
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform(translationX: tx, y: ty)
        }
    }
    /// 缩放
    static func transformScale(view: UIView, duration: TimeInterval, scaleX sx: CGFloat, y sy: CGFloat) {
        UIView.animate(withDuration: duration) {
            view.transform = CGAffineTransform(scaleX: sx, y: sy)
        }
    }
}

// MARK: - UILabel

public extension GFCompat where Base: UILabel {
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

// MARK: - UIButton

public extension GFCompat where Base: UIButton {
    enum ButtonLayoutPosition {
        case `default` // image left, title right
        case imageRight
        case imageTop
        case imageBottom
    }
    
    /// 布局位置
    /// - Parameters:
    ///   - position: 默认左图右文
    ///   - space: 图文间距
    func layoutWithPosiziton(_ position: ButtonLayoutPosition = .default, space: CGFloat = 0) {
        base.layoutIfNeeded()
        let imageSize = base.imageView?.intrinsicContentSize ?? CGSize.zero
        let titleSize = base.titleLabel?.intrinsicContentSize ?? CGSize.zero

        var titleEdgeInset = UIEdgeInsets.zero
        var imageEdgeInset = UIEdgeInsets.zero
        switch position {
        case .imageTop:
            imageEdgeInset = UIEdgeInsets(top: -titleSize.height - space / 2.0, left: 0, bottom: 0, right: -titleSize.width)
            titleEdgeInset = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -imageSize.height - space / 2.0, right: 0)
        case .imageBottom:
            imageEdgeInset = UIEdgeInsets(top: 0, left: 0, bottom: -titleSize.height - space / 2.0, right: -titleSize.width)
            titleEdgeInset = UIEdgeInsets(top: -imageSize.height - space / 2.0, left: -imageSize.width, bottom: 0, right: 0)
        case .imageRight:
            imageEdgeInset = UIEdgeInsets(top: 0, left: titleSize.width + space / 2.0, bottom: 0, right: -titleSize.width - space / 2.0)
            titleEdgeInset = UIEdgeInsets(top: 0, left: -imageSize.width - space / 2.0, bottom: 0, right: imageSize.width + space / 2.0)
        default:
            imageEdgeInset = UIEdgeInsets(top: 0, left: -space / 2.0, bottom: 0, right: space / 2.0)
            titleEdgeInset = UIEdgeInsets(top: 0, left: space / 2.0, bottom: 0, right: -space / 2.0)
        }
        base.titleEdgeInsets = titleEdgeInset
        base.imageEdgeInsets = imageEdgeInset
    }
    
    /// Button背景色
    /// - Parameters:
    ///   - color: 颜色
    ///   - state: 状态
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = UIImage.init(color: color)
        base.setBackgroundImage(image, for: state)
    }
}

// MARK: - UIImage
extension UIImage {
    
    /// 生成指定颜色和尺寸的图片, 尺寸默认为 CGSize(width:1, height:1)
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
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
    
    /// view生成图片
    /// - Parameters:
    ///   - view: 需要生成图片的view
    ///   - scale: 缩放倍率
    convenience init(view: UIView, scale: CGFloat) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        defer { UIGraphicsEndImageContext() }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
    
    /// 画圆
    /// - Parameters:
    ///   - size: 圆的大小
    ///   - color: 圆的颜色
    class func setArc(size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.move(to: .zero)
        context?.addArc(center: CGPoint(x: size.width/2.0, y: size.height/2.0), radius: size.width/2.0, startAngle: CGFloat.pi * 0, endAngle: CGFloat.pi * 2.0, clockwise: true)
        context?.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    /// 画线
    /// - Parameters:
    ///   - size: 线的大小
    ///   - lineColor: 线颜色
    ///   - length: 线长
    ///   - lineCap: 线头的形状
    ///   - phrase: dash间距
    class func setLine(size: CGSize, lineColor: UIColor, length: [CGFloat] = [10,10], lineCap: CGLineCap = .square, phrase: CGFloat = 0) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(lineCap)
        context?.setLineWidth(size.height)
        context?.setStrokeColor(lineColor.cgColor)
        context?.setLineDash(phase: phrase, lengths: length)
        context?.move(to: .zero)
        context?.addLine(to: CGPoint(x: size.width, y: 0))
        context?.stroke(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    /// 画线
    /// - Parameters:
    ///   - size: 线的大小
    ///   - lineColor: 线颜色
    ///   - lineWidth: 线宽
    class func lineImage(size: CGSize, lineColor: UIColor, lineWidth: CGFloat) -> UIImage? {
       return self.setLine(size: size, lineColor: lineColor, length: [lineWidth, lineWidth])
    }
}

public extension GFCompat where Base: UIImage {
    /// Add WaterMarkingImage
    ///
    /// - Parameters:
    ///   - image: the image that painted on
    ///   - waterImageName: waterImage
    /// - Returns: the warterMarked image
    static func waterMarkingImage(image: UIImage, with waterImage: UIImage) -> UIImage? {
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
    static func waterMarkingImage(image: UIImage, with text: String) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        let str = text as NSString
        let pointY = image.size.height - image.size.width * 0.1
        let point = CGPoint(x: image.size.width * 0.78, y: pointY)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8),
                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: image.size.width / 25.0)] as [NSAttributedString.Key: Any]
        str.draw(at: point, withAttributes: attributes)

        let waterMarkingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return waterMarkingImage
    }

    /// 修改图片填充色
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
    
    /// 保存图片
    func savedPhotos(_ completionHandler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAsset(from: self.base) }, completionHandler: { isSuccess, error in
            DispatchQueue.main.async { completionHandler?(isSuccess, error) }
        })
    }

    
    /// 旋转图片
    /// - Parameter angle: 旋转角度
    func rotate(_ angle: Double) -> UIImage? {
        if angle.truncatingRemainder(dividingBy: 360) == 0 { return base }

        let imageRect = CGRect(origin: .zero, size: base.size)

        let radian = CGFloat(angle) / CGFloat(180) * CGFloat.pi

        var rotatedRect = imageRect.applying(CGAffineTransform.identity.rotated(by: radian))
        rotatedRect.origin.x = 0
        rotatedRect.origin.y = 0

        UIGraphicsBeginImageContextWithOptions(rotatedRect.size, false, base.scale)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)
        context.rotate(by: radian)
        context.translateBy(x: -base.size.width / 2, y: -base.size.height / 2)
        
        base.draw(at: CGPoint.zero)

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        defer { UIGraphicsEndImageContext() }
        return rotatedImage
    }

    /// 图片裁圆角
    /// - Parameter cornerRadius: 圆角
    func roundCorners(_ cornerRadius: CGFloat) -> UIImage? {
        return image(withRoundRadius: cornerRadius, fit: base.size, roundingCorners: .allCorners, backgroundColor: nil)
    }

    func draw(cgImage _: CGImage?, to size: CGSize, draw: () -> Void) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, base.scale)
        defer { UIGraphicsEndImageContext() }
        draw()
        return UIGraphicsGetImageFromCurrentImageContext() ?? base
    }

    func image(withRoundRadius radius: CGFloat,
                      fit size: CGSize,
                      roundingCorners corners: UIRectCorner = .allCorners,
                      backgroundColor: UIColor? = nil) -> UIImage? {
        guard let cgImage = base.cgImage else {
            assertionFailure("[Kingfisher] Round corner image only works for CG-based image.")
            return base
        }

        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        return draw(cgImage: cgImage, to: size) {
            guard let context = UIGraphicsGetCurrentContext() else {
                assertionFailure("[Kingfisher] Failed to create CG context for image.")
                return
            }

            if let backgroundColor = backgroundColor {
                let rectPath = UIBezierPath(rect: rect)
                backgroundColor.setFill()
                rectPath.fill()
            }

            let path = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius)).cgPath
            context.addPath(path)
            context.clip()
            base.draw(in: rect)
        }
    }

    /// 将图片裁剪成指定比例（多余部分自动删除）
    func crop(ratio: CGFloat) -> UIImage {
        // 计算最终尺寸
        var newSize: CGSize!
        if base.size.width / base.size.height > ratio {
            newSize = CGSize(width: base.size.height * ratio, height: base.size.height)
        } else {
            newSize = CGSize(width: base.size.width, height: base.size.width / ratio)
        }

        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width = base.size.width
        rect.size.height = base.size.height
        rect.origin.x = (newSize.width - base.size.width) / 2.0
        rect.origin.y = (newSize.height - base.size.height) / 2.0

        // 绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        base.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }

    /// 将图片缩放成指定尺寸（多余部分自动删除）
    func scale(to newSize: CGSize) -> UIImage {
        // 计算比例
        let aspectWidth = newSize.width / base.size.width
        let aspectHeight = newSize.height / base.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)

        // 图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width = base.size.width * aspectRatio
        scaledImageRect.size.height = base.size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - base.size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y = (newSize.height - base.size.height * aspectRatio) / 2.0

        // 绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        base.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }
}

// MARK: - UIColor
public extension UIColor {
    
    /// HEX色值转换
    /// - Parameters:
    ///   - hex: hex
    ///   - alpha: 透明度
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.hasPrefix("0x") {
            cString.removeFirst(2)
        }

        if cString.count != 6 {
            self.init(white: 1, alpha: 1)
            return
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

public extension GFCompat where Base: UIColor {
    /// 随机色
    static func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0 ... 255) / 255.0, green: CGFloat.random(in: 0 ... 255) / 255.0, blue: CGFloat.random(in: 0 ... 255) / 255.0, alpha: 1.0)
    }
}

// MARK: - CGFloat
protocol CGFloatConvertble {
    var f: CGFloat { get }
}

extension Int: CGFloatConvertble {
      var f: CGFloat {
          return CGFloat(self)
      }
}

extension Float: CGFloatConvertble {
    var f: CGFloat {
        return CGFloat(self)
    }
}

extension Double: CGFloatConvertble {
    var f: CGFloat {
        return CGFloat(self)
    }
}

// MARK: - 适配
///尺寸适配
public extension CGFloat {
    /// 视图中所有水平值都是宽度为375时设定的逻辑值，这里返回实际的水平方向上的值
    var scale: CGFloat {
        return (self * UIScreen.gf.screenWidth) / 375.0
    }

    /// 屏幕顶部该数值在刘海影响下的数值
    var safeAreaTopOffset: CGFloat {
        if #available(iOS 11.0, *), let top = UIApplication.shared.keyWindow?.safeAreaInsets.top, top != 0 {
            return top + scale
        } else {
            // Fallback on earlier versions
            return scale
        }
    }
    /// 屏幕底部该数值在刘海屏影响下的数值
    var safeAreaBottomOffset: CGFloat {
        if #available(iOS 11.0, *), let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, bottom != 0 {
            return bottom + scale
        } else {
            return scale
        }
    }
}

enum CompatibleFontWeight: String, CaseIterable {
    case ultraLight = "HelveticaNeue-UltraLight"
    case thin = "HelveticaNeue-Thin"
    case light = "HelveticaNeue-Light"
    case regular = "HelveticaNeue"
    case medium = "HelveticaNeue-Medium"
    case semibold = "Helvetica-Bold"
    case bold = "HelveticaNeue-Bold"
    case heavy = "HelveticaNeue-CondensedBold"
    case black = "HelveticaNeue-CondensedBlack"

    @available(iOS 8.2, *)
    var systemWeight: UIFont.Weight {
        switch self {
        case .ultraLight:
            return UIFont.Weight.ultraLight
        case .thin:
            return UIFont.Weight.thin
        case .light:
            return UIFont.Weight.light
        case .regular:
            return UIFont.Weight.regular
        case .medium:
            return UIFont.Weight.medium
        case .semibold:
            return UIFont.Weight.semibold
        case .bold:
            return UIFont.Weight.bold
        case .heavy:
            return UIFont.Weight.heavy
        case .black:
            return .black
        }
    }
}

/// 字体适配
extension UIFont {
    static func appFont(ofSize size: CGFloat, weight: CompatibleFontWeight = .regular) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: weight.systemWeight)
        } else if let font = UIFont(name: weight.rawValue, size: size) {
            return font
        } else {
            return .systemFont(ofSize: size)
        }
    }
}

// MARK:  - UISCcrollView
public extension GFCompat where Base: UIScrollView {
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
        base.insertRows(at: [toInsert], with: animation)
    }

    func reloadRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        base.reloadRows(at: [indexPath], with: animation)
    }

    func reloadRow(_ row: Int, in section: Int, withRowAnimation animation: UITableView.RowAnimation) {
        let toReload = IndexPath(row: row, section: section)
        base.reloadRows(at: [toReload], with: animation)
    }

    func deleteRow(at indexPath: IndexPath, withRowAnimation animation: UITableView.RowAnimation) {
        base.deleteRows(at: [indexPath], with: animation)
    }
}

// MARK: - UITextView
@IBDesignable
class GFTextView: UITextView {
    let changeAnimationDuration = 0.25
    let placeholerLabel = UILabel()

    override var text: String! {
        didSet {
            self.textChange(nil)
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        placeholerLabel.textColor = .lightGray
        placeholerLabel.numberOfLines = 0
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(_:)), name: UITextView.textDidChangeNotification, object: self)
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func textChange(_: NSNotification?) {
        guard let txt = placeholerLabel.text, txt.isEmpty == false else { return }
        UIView.animate(withDuration: changeAnimationDuration) {
            if self.text.count == 0 {
                self.placeholerLabel.alpha = 1
            } else {
                self.placeholerLabel.alpha = 0
            }
        }
    }

    override func draw(_ rect: CGRect) {
        if placeholerLabel.frame == .zero {
            let size = bounds.size
            placeholerLabel.frame = CGRect(x: 8, y: 8, width: size.width - 16, height: size.height - 16)
            placeholerLabel.sizeToFit()
            addSubview(placeholerLabel)
        }

        if let txt = self.text, txt.isEmpty, let placeholder = self.placeholerLabel.text, !placeholder.isEmpty {
            placeholerLabel.alpha = 1
        }
        super.draw(rect)
    }
}

// MARK: - UIGestureRecognizer

public extension UIGestureRecognizer {
    @discardableResult
    convenience init(addToView targetView: UIView, closure: @escaping (UIGestureRecognizer) -> Void) {
        self.init()
        GestureTarget.add(gesture: self, closure: closure, toView: targetView)
    }
}

private class GestureTarget: UIView {
    class ClosureContainer {
        weak var gesture: UIGestureRecognizer?
        let closure: (UIGestureRecognizer) -> Void

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
        containers = containers.filter { $0.gesture != nil }
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

// MARK: - UIApplication

public extension GFCompat where Base: UIApplication {
    static func openUrl(_ string: String?, _ complete: ((Bool) -> Void)? = nil) {
        guard let string = string, let url = URL(string: string), UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: complete)
        } else {
            let res = UIApplication.shared.openURL(url)
            complete?(res)
        }
    }

    /// 打开设置
    static func openSetting() {
        openUrl(UIApplication.openSettingsURLString)
    }

    /// 拨打电话
    /// - Parameter tel: telephone number
    static func openTelUrl(_ tel: String?) {
        if let tel = tel {
            openUrl("tel:" + tel)
        }
    }
}

// MARK: - UIDevice

public extension GFCompat where Base: UIDevice {
    /// 检查系统语言是否变动
    ///
    /// - Returns: ture 变动,false 未变动
    func langChanged() -> Bool {
        guard let currentLanguage = NSLocale.preferredLanguages.first else {
            return false
        }
        if let preLanguage = UserDefaults.standard.object(forKey: "localLanguage") as? String {
            if preLanguage != currentLanguage {
                UserDefaults.standard.set(currentLanguage, forKey: "localLanguage")
                return true
            } else {
                return false
            }
        } else {
            UserDefaults.standard.set(currentLanguage, forKey: "localLanguage")
            return false
        }
    }
}

// MARK: - String
public extension GFCompat where Base == String {
    /// 返回Int
    var int: Int? {
        return Int(base)
    }

    /// 返回URL
    var url: URL? {
        return URL(string: base)
    }

    /// 返回Float
    var float: Float? {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        return formatter.number(from: base)?.floatValue
    }

    /// 返回Double
    var double: Double? {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        return formatter.number(from: base)?.doubleValue
    }

    /// 过滤空格
    var trim: String {
        return base.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 文字尺寸计算相关
    func boundingRect(with size: CGSize, attributes: [NSAttributedString.Key: Any]) -> CGRect {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let rect = base.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return rect
    }

    
    /// 文字的尺寸
    /// - Parameters:
    ///   - size: 文字的约束尺寸
    ///   - font: 字号
    ///   - maximumNumberOfLines: 最大行数
    func size(thatFits size: CGSize, font: UIFont, maximumNumberOfLines: Int = 0) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        var size = boundingRect(with: size, attributes: attributes).size
        if maximumNumberOfLines > 0 {
            size.height = max(size.height, CGFloat(maximumNumberOfLines) * font.lineHeight)
        }
        return size
    }
    
    /// 单行文字的宽度
    /// - Parameters:
    ///   - font: 字号
    func width(with font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.size(thatFits: size, font: font).width
    }
    
    /// 指定宽度的文字高度
    /// - Parameters:
    ///   - width: 宽度
    ///   - font: 字号
    ///   - maximumNumberOfLines: 最大行数
    func height(thatFitsWidth width: CGFloat, font: UIFont, maximumNumberOfLines: Int = 0) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.size(thatFits: size, font: font, maximumNumberOfLines: maximumNumberOfLines).height
    }
}
