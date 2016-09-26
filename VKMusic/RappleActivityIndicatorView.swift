/* **
 RappleActivityIndicatorView.swift
 Custom Activity Indicator with swift 2.0
 
 Created by Rajeev Prasad on 15/11/15.
 
 The MIT License (MIT)
 
 Copyright (c) 2016 Rajeev Prasad <rjeprasad@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ** */

import UIKit

/**
 Rapple progress attribute dictionary keys
 - RappleTintColorKey               Color of the progrss circle and text
 - RappleScreenBGColorKey           Background color (full screen background)
 - RappleProgressBGColorKey         Background color around the progress indicator (Only applicable for Apple Style)
 - RappleIndicatorStyleKey          Style of the ActivityIndicator
 - RappleProgressBarColorKey        Progress bar bg color
 - RappleProgressBarFillColorKey    Progress bar filling color with progression
 */
public let RappleTintColorKey               = "TintColorKey"
public let RappleScreenBGColorKey           = "ScreenBGColorKey"
public let RappleProgressBGColorKey         = "ProgressBGColorKey"
public let RappleIndicatorStyleKey          = "IndicatorStyleKey"
public let RappleProgressBarColorKey        = "ProgressBarColorKey"
public let RappleProgressBarFillColorKey    = "ProgressBarFillColorKey"


/**
 Available Styles
 - RappleStyleApple              Default Apple ActivityIndicator
 - RappleStyleCircle             Custom Rapple Circle ActivityIndicator
 */
public let RappleStyleApple     = "Apple"
public let RappleStyleCircle    = "Circle"

/**
 Predefined attribute dictionary to match default apple look & feel
 - RappleTintColorKey               UIColor.whiteColor()
 - RappleScreenBGColorKey           UIColor(white: 0.0, alpha: 0.2)
 - RappleProgressBGColorKey         UIColor(white: 0.0, alpha: 0.7)
 - RappleIndicatorStyleKey          RappleStyleApple
 - RappleProgressBarColorKey        lightGray
 - RappleProgressBarFillColorKey    white
 */
public let RappleAppleAttributes : [String:AnyObject] = [RappleTintColorKey:UIColor.white, RappleIndicatorStyleKey:RappleStyleApple as AnyObject, RappleScreenBGColorKey:UIColor(white: 0.0, alpha: 0.2),RappleProgressBGColorKey:UIColor(white: 0.0, alpha: 0.7), RappleProgressBarColorKey: UIColor.lightGray, RappleProgressBarFillColorKey: UIColor.white]

/**
 Predefined attribute dictionary to match modern look & feel
 - RappleTintColorKey               UIColor.whiteColor()
 - RappleScreenBGColorKey           UIColor(white: 0.0, alpha: 0.5)
 - RappleProgressBGColorKey         N/A
 - RappleIndicatorStyleKey          RappleStyleCircle
 - RappleProgressBarColorKey        lightGray
 - RappleProgressBarFillColorKey    white
 */
public let RappleModernAttributes : [String:AnyObject] = [RappleTintColorKey:UIColor.white, RappleIndicatorStyleKey:RappleStyleCircle as AnyObject, RappleScreenBGColorKey:UIColor(white: 0.0, alpha: 0.2), RappleProgressBarColorKey: UIColor.lightGray, RappleProgressBarFillColorKey: UIColor.white]

/**
 RappleActivityIndicatorView is a shared controller and calling multipel times will overide the previouse activity indicator view.
 So closing it once at the end of process will close shared activity indicator completely
 */
extension RappleActivityIndicatorView {
    
    /**
     Start Rapple progress indicator without any text message, using RappleModernAttributes
     */
    public class func startAnimating() {
        DispatchQueue.main.async {
            RappleActivityIndicatorView.loacClearUp()
            RappleActivityIndicatorView.startPrivateAnimating()
        }
    }
    
    /**
     Start Rapple progress indicator without any text message
     - parameter attributes: dictionary with custom attributes
     */
    public class func startAnimating(attributes:[String:AnyObject]) {
        DispatchQueue.main.async {
            RappleActivityIndicatorView.loacClearUp()
            RappleActivityIndicatorView.startPrivateAnimating(attributes: attributes)
        }
    }
    
    /**
     Start Rapple progress indicator & text message, using RappleModernAttributes
     - parameter label: text value to display with activity indicator
     */
    public class func startAnimatingWithLabel(_ label : String) {
        DispatchQueue.main.async {
            RappleActivityIndicatorView.loacClearUp()
            RappleActivityIndicatorView.startPrivateAnimatingWithLabel(label)
        }
    }
    
    /**
     Start Rapple progress indicator & text message
     - parameter label: text value to display with activity indicator
     - parameter attributes: dictionary with custom attributes
     */
    public class func startAnimatingWithLabel(_ label : String, attributes:[String:AnyObject]) {
        DispatchQueue.main.async {
            RappleActivityIndicatorView.loacClearUp()
            RappleActivityIndicatorView.startPrivateAnimatingWithLabel(label, attributes: attributes)
        }
    }
    
    /**
     Start Rapple progress value indicator
     - parameter progress: progress amount 0<= x <= 1.0
     - parameter textValue: texual progress amount value (e.g. "3/8" or "3 of 10") - only limited space avaibale
     - Note: textValue -> nil for percentage value (e.g. 78%)
     - Note: textValue -> "" to hide texual progress amount
     - Note: normal progress bar will display for 'RappleStyleApple' and circular progress bar will display for 'RappleStyleCircle'
     */
    public class func setProgress(_ progress: CGFloat, textValue: String? = nil) {
        DispatchQueue.main.async {
            RappleActivityIndicatorView.setPrivateProgress(Float(progress), textValue: textValue)
        }
    }
    
    /**
     Start Rapple progress value indicator
     - parameter showCompletion: show completion indicator Default false
     - parameter completionLabel: string label for completion indicator Default nil
     - parameter completionTimeout: hide completion indicator after timeout time Defailt = 2.0
     */
    public class func stopAnimating(showCompletion: Bool = false, completionLabel: String? = nil, completionTimeout: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            RappleActivityIndicatorView.stopPrivateAnimating(showCompletion: showCompletion, completionLabel: completionLabel, completionTimeout: completionTimeout)
        }
    }
    
    /** Check wheather RappleActivityIndicatorView is visible */
    public class func isVisible() -> Bool {
        return RappleActivityIndicatorView.isPrivateVisible()
    }
    
    /** Cleanup text & attribute values*/
    private class func loacClearUp() {
        RappleActivityIndicatorView.sharedInstance.textLabel = nil
        RappleActivityIndicatorView.sharedInstance.attributes.removeAll()
    }
}

/**
 RappleActivityIndicatorView is a shared controller and calling multipel times will overide the previouse activity indicator view.
 So closing it once at the end of process will close shared activity indicator completely
 */
open class RappleActivityIndicatorView: NSObject {
    
    fileprivate static let sharedInstance = RappleActivityIndicatorView()
    
    fileprivate var backgroundView : UIView?
    fileprivate var contentSqure : UIView?
    
    fileprivate var activityIndicator : UIActivityIndicatorView? // apple activity indicator
    fileprivate var circularActivity1 : CAShapeLayer? // circular activity indicator
    fileprivate var circularActivity2 : CAShapeLayer? // circular activity indicator
    fileprivate var completionPoint : CGPoint = .zero // activity indicator center point
    fileprivate var completionRadius : CGFloat = 18 // activity indicator complete circle
    fileprivate var completionWidth : CGFloat = 4 // activity indicator complete circle
    
    fileprivate var progressBar : UIProgressView? // apple style bar
    fileprivate var progressLayer : CAShapeLayer? // circular bar
    fileprivate var progressLayerBG : CAShapeLayer? // circular bar
    fileprivate var progressLabel : UILabel? // percentage value
    fileprivate var activityLable : UILabel? // text value
    
    fileprivate var textLabel : String?
    fileprivate var attributes : [String:AnyObject] = RappleModernAttributes
    fileprivate var currentProgress: Float = 0
    fileprivate var showProgress: Bool = false
    
    /** isVisible */
    fileprivate class func isPrivateVisible() -> Bool {
        let progress = RappleActivityIndicatorView.sharedInstance
        return progress.backgroundView?.superview != nil
    }
    
    /** create & start */
    fileprivate class func startPrivateAnimating() {
        
        sharedInstance.keyWindow.endEditing(true)
        sharedInstance.keyWindow.isUserInteractionEnabled = false
        
        let progress = RappleActivityIndicatorView.sharedInstance
        
        NotificationCenter.default.addObserver(progress, selector: #selector(RappleActivityIndicatorView.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        sharedInstance.showProgress = false
        
        progress.createProgressBG()
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            
            progress.backgroundView?.alpha = 1.0
            
            }, completion: { (finished) -> Void in
                progress.createActivityIndicator()
        })
    }
    
    /** create & start */
    fileprivate class func startPrivateAnimating(attributes:[String:AnyObject]) {
        RappleActivityIndicatorView.sharedInstance.attributes = attributes
        RappleActivityIndicatorView.startPrivateAnimating()
    }
    
    /** create & start */
    fileprivate class func startPrivateAnimatingWithLabel(_ label : String) {
        RappleActivityIndicatorView.sharedInstance.textLabel = label
        RappleActivityIndicatorView.startPrivateAnimating()
    }
    
    /** create & start */
    fileprivate class func startPrivateAnimatingWithLabel(_ label : String, attributes:[String:AnyObject]) {
        RappleActivityIndicatorView.sharedInstance.attributes = attributes
        RappleActivityIndicatorView.sharedInstance.textLabel = label
        RappleActivityIndicatorView.startPrivateAnimating()
    }
    
    /** stop & clear */
    fileprivate class func stopPrivateAnimating(showCompletion: Bool, completionLabel: String?, completionTimeout: TimeInterval) {
        
        if showCompletion == false {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                sharedInstance.backgroundView?.alpha = 0.0
                sharedInstance.keyWindow.tintAdjustmentMode = .automatic
                sharedInstance.keyWindow.tintColorDidChange()
                }, completion: { (finished) -> Void in
                    sharedInstance.clearUIs()
                    sharedInstance.backgroundView?.removeFromSuperview()
                    sharedInstance.backgroundView = nil
                    sharedInstance.keyWindow.isUserInteractionEnabled = true
            })
        } else {
            if sharedInstance.attributes[RappleIndicatorStyleKey] as? String == RappleStyleApple {
                sharedInstance.progressBar?.removeFromSuperview()
                sharedInstance.activityIndicator?.removeFromSuperview()
                
                if sharedInstance.contentSqure != nil {
                    var sqWidth: CGFloat = 55
                    // calc center values
                    var comLabel = completionLabel
                    if RappleActivityIndicatorView.sharedInstance.textLabel == nil {
                        comLabel = nil
                    }
                    let size = sharedInstance.calcTextSize(comLabel)
                    sqWidth = size.width + 20
                    if sqWidth < 55 { sqWidth = 55; }
                    let c = sharedInstance.contentSqure?.center
                    var rect = sharedInstance.contentSqure?.frame
                    rect?.size.width = sqWidth
                    sharedInstance.contentSqure?.frame = rect!
                    sharedInstance.contentSqure?.center = c!
                }
                
            } else {
                sharedInstance.circularActivity1?.removeFromSuperlayer()
                sharedInstance.circularActivity2?.removeFromSuperlayer()
                sharedInstance.progressLayer?.removeFromSuperlayer()
                sharedInstance.progressLayerBG?.removeFromSuperlayer()
            }
            sharedInstance.progressLabel?.removeFromSuperview()
            
            sharedInstance.activityLable?.text = completionLabel
            sharedInstance.drawCheckMark()
            
            Timer.scheduledTimer(timeInterval: completionTimeout, target: sharedInstance, selector: #selector(RappleActivityIndicatorView.closePrivateActivityCompletion), userInfo: nil, repeats: false)
        }
        NotificationCenter.default.removeObserver(sharedInstance)
    }
    
    /** draw completion check mark */
    fileprivate func drawCheckMark() {
        let x = completionPoint.x - 10
        let y = completionPoint.y + 4
        
        let circle = UIBezierPath(arcCenter: completionPoint, radius: completionRadius, startAngle: CGFloat(-M_PI_2), endAngle:CGFloat(2 * M_PI - M_PI_2), clockwise: true)
        let pgrsBg = CAShapeLayer()
        pgrsBg.path = circle.cgPath
        pgrsBg.fillColor = nil
        pgrsBg.strokeColor = getColor(key: RappleProgressBarFillColorKey).cgColor
        pgrsBg.lineWidth = completionWidth
        backgroundView?.layer.addSublayer(pgrsBg)
        
        let checkPath = UIBezierPath()
        checkPath.move(to: CGPoint(x: x, y: y))
        checkPath.addLine(to: CGPoint(x: x + 7, y: y + 5))
        checkPath.addLine(to: CGPoint(x: x + 18, y: y - 12))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = checkPath
            .cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = getColor(key: RappleProgressBarFillColorKey).cgColor
        shapeLayer.lineWidth = completionWidth
        backgroundView?.layer.addSublayer(shapeLayer)
    }
    
    /** close completion UIs */
    internal func closePrivateActivityCompletion() {
        RappleActivityIndicatorView.stopPrivateAnimating(showCompletion: false, completionLabel: nil, completionTimeout: 0)
    }
    
    /** set progress values */
    fileprivate class func setPrivateProgress(_ progress: Float, textValue: String? = nil) {
        if progress >= 0 && progress <= 1.0 {
            sharedInstance.currentProgress = progress
            if sharedInstance.showProgress == false {
                sharedInstance.showProgress = true
                sharedInstance.createActivityIndicator()
            }
            
            let style = sharedInstance.attributes[RappleIndicatorStyleKey] as? String ?? RappleStyleCircle
            if style == RappleStyleApple {
                sharedInstance.setBarProgressValue(progress, pgText: textValue)
            } else {
                sharedInstance.addProgresCircle(progress, pgText: textValue)
            }
            
        } else {
            print("Error RappleActivityIndicatorView: Invalid progress value")
        }
    }
    
    /** create background view */
    fileprivate func createProgressBG() {
        if (backgroundView == nil){
            backgroundView = UIView(frame: CGRect.zero)
            backgroundView?.translatesAutoresizingMaskIntoConstraints = false
            backgroundView?.backgroundColor = getColor(key: RappleScreenBGColorKey).withAlphaComponent(0.4)
            backgroundView?.alpha = 1.0
            backgroundView?.isUserInteractionEnabled = false
            keyWindow.addSubview(backgroundView!)
            
            let dic = ["BG": backgroundView!]
            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[BG]|", options: .alignAllCenterY, metrics: nil, views: dic))
            keyWindow.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[BG]|", options: .alignAllCenterX, metrics: nil, views: dic))
        }
    }
    
    /** create all UIs */
    fileprivate func createActivityIndicator(){
        if backgroundView == nil { createProgressBG() }
        clearUIs() // clear all before restart
        let style = attributes[RappleIndicatorStyleKey] as? String ?? RappleStyleCircle
        if style == RappleStyleApple {
            createAppleUIs()
        } else {
            createCircleUIs()
        }
    }
    
    /** create Apple style UIs */
    fileprivate func createAppleUIs() {
        var sqWidth: CGFloat = 55
        // calc center values
        let size = calcTextSize(textLabel)
        let h = 45 + size.height
        let sqHeight: CGFloat = h + 20
        let cd = 24 + size.height - (h / 2)
        var c = keyWindow.center; c.y -= cd
        
        // add activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator?.color = getColor(key: RappleTintColorKey)
        activityIndicator?.startAnimating()
        backgroundView?.addSubview(activityIndicator!)
        if showProgress == false {
            activityIndicator?.center = c
            sqWidth = size.width + 20
            if sqWidth < 55 { sqWidth = 55; }
        } else {
            var newc = c; newc.x -= 100
            activityIndicator?.center = newc
            sqWidth = 260
            
            progressBar = UIProgressView(progressViewStyle: .bar)
            progressBar?.frame = CGRect(x: 0, y: 0, width: 180, height: 4)
            progressBar?.center = CGPoint(x: c.x + 22, y: newc.y + 10)
            progressBar?.trackTintColor = getColor(key: RappleProgressBarColorKey)
            progressBar?.progressTintColor = getColor(key: RappleProgressBarFillColorKey)
            backgroundView?.addSubview(progressBar!)
            
            var rect = progressBar!.frame
            rect.origin.y -= 24
            rect.size.height = 21
            progressLabel = UILabel(frame: rect)
            progressLabel?.textColor = getColor(key: RappleTintColorKey)
            progressLabel?.textAlignment = .right
            backgroundView?.addSubview(progressLabel!)
            progressLabel?.text = ""
        }
        
        // add label and size
        activityLable = UILabel(frame: CGRect(x: 0, y: 0, width: size.width+1, height: size.height+1))
        let x = keyWindow.center.x
        let y = keyWindow.center.y - (size.height / 2) + (h / 2)
        activityLable?.center = CGPoint(x: x, y: y)
        activityLable?.font = UIFont.systemFont(ofSize: 18)
        activityLable?.textColor = getColor(key: RappleTintColorKey)
        activityLable?.textAlignment = .center
        activityLable?.numberOfLines = 0
        activityLable?.lineBreakMode = .byWordWrapping
        activityLable?.text = textLabel
        backgroundView?.addSubview(activityLable!)
        
        // set the rounded rectangle view at the middle
        contentSqure = UIView(frame: CGRect(x: 0, y: 0, width: sqWidth, height: sqHeight))
        contentSqure?.backgroundColor = getColor(key: RappleProgressBGColorKey)
        contentSqure?.layer.cornerRadius = 10.0
        contentSqure?.layer.masksToBounds = true
        contentSqure?.center = keyWindow.center
        backgroundView?.addSubview(contentSqure!)
        backgroundView?.sendSubview(toBack: contentSqure!)
        
        completionPoint = activityIndicator!.center
        completionPoint.x = contentSqure!.center.x
        completionRadius = 18
        completionWidth = 2
    }
    
    fileprivate func setBarProgressValue(_ progress: Float, pgText: String?){
        progressBar?.progress = progress
        var textVal = pgText
        if pgText == nil {
            textVal = "\(Int(progress * 100))%";
        }
        progressLabel?.text = textVal
    }
    
    /** create circular UIs */
    fileprivate func createCircleUIs() {
        let size = calcTextSize(textLabel)
        let yi = addAnimatingCircle(twoSided: showProgress == false)
        if showProgress == true {
            addProgresCircle(currentProgress, pgText: "")
        }
        activityLable = UILabel(frame: CGRect(x: 0, y: 0, width: size.width+1, height: size.height+1))
        let x = keyWindow.center.x
        let y = yi + (size.height / 2)
        activityLable?.center = CGPoint(x: x, y: y)
        activityLable?.textColor = getColor(key: RappleTintColorKey)
        activityLable?.font = UIFont.systemFont(ofSize: 16)
        activityLable?.textAlignment = .center
        activityLable?.numberOfLines = 0
        activityLable?.lineBreakMode = .byWordWrapping
        activityLable?.text = textLabel
        backgroundView?.addSubview(activityLable!)
    }
    
    /** radius of the circular activity indicator */
    fileprivate var radius: CGFloat {
        if showProgress {
            return 40
        } else {
            return 26
        }
    }
    
    /** calc text value height - max 220x x 100 */
    fileprivate func calcTextSize(_ text: String?) -> CGSize {
        if (text == nil) {
            return CGSize.zero
        }
        let nss = text! as NSString
        let size = nss.boundingRect(with: CGSize(width: 220, height: 9999), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil).size
        var h = size.height
        if h > 100 {
            h = 100
        }
        var w = size.width
        if w > 220 {
            w = 220
        }
        return CGSize(width: w, height: h)
    }
    
    /** create circulat activity indicators */
    fileprivate func addAnimatingCircle(twoSided: Bool) -> CGFloat {
        
        let size = calcTextSize(textLabel)
        let r = radius
        let h = (2 * r) + size.height + 10
        let cd = (h - size.height - 10) / 2
        
        var center = keyWindow.center; center.y -= cd
        
        let circle1 = UIBezierPath(arcCenter: center, radius: r, startAngle: CGFloat(-M_PI_2), endAngle:CGFloat(3 * M_PI_2), clockwise: true)
        circularActivity1 = rotatingCircle(circle: circle1)
        
        if twoSided == true {
            let circle2 = UIBezierPath(arcCenter: center, radius: r, startAngle: CGFloat(M_PI_2), endAngle:CGFloat(5 * M_PI_2), clockwise: true)
            circularActivity2 = rotatingCircle(circle: circle2)
        }
        completionPoint = center
        completionRadius = (showProgress == true) ? r - 5 : r
        completionWidth = 4
        
        return center.y + r + 10
    }
    
    /** create circular path with UIBezierPath */
    fileprivate func rotatingCircle(circle: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circle.cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = getColor(key: RappleTintColorKey).cgColor
        shapeLayer.lineWidth = 5.0
        backgroundView?.layer.addSublayer(shapeLayer)
        
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 0.0
        strokeEnd.toValue = 1.0
        strokeEnd.duration = 1.0
        strokeEnd.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let endGroup = CAAnimationGroup()
        endGroup.duration = 1.3
        endGroup.repeatCount = MAXFLOAT
        endGroup.animations = [strokeEnd]
        
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.beginTime = 0.3
        strokeStart.fromValue = 0.0
        strokeStart.toValue = 1.0
        strokeStart.duration = 1.0
        strokeStart.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let startGroup = CAAnimationGroup()
        startGroup.duration = 1.3
        startGroup.repeatCount = MAXFLOAT
        startGroup.animations = [strokeStart]
        
        shapeLayer.add(endGroup, forKey: "end")
        shapeLayer.add(startGroup, forKey: "start")
        
        return shapeLayer
    }
    
    /** create & set circular progress bar */
    fileprivate func addProgresCircle(_ progress: Float, pgText: String?) {
        
        if progressLayer == nil {
            let size = calcTextSize(textLabel)
            let r = radius
            let h = 2 * r + size.height + 10
            let cd = (h - size.height - 10) / 2
            
            var center = keyWindow.center; center.y -= cd
            let circle = UIBezierPath(arcCenter: center, radius: (r - 5), startAngle: CGFloat(-M_PI_2), endAngle:CGFloat(2 * M_PI - M_PI_2), clockwise: true)
            
            progressLayerBG = CAShapeLayer()
            progressLayerBG?.path = circle.cgPath
            progressLayerBG?.fillColor = nil
            progressLayerBG?.strokeColor = getColor(key: RappleProgressBarColorKey).cgColor
            progressLayerBG?.lineWidth = 4.0
            backgroundView?.layer.addSublayer(progressLayerBG!)
            
            progressLayer = CAShapeLayer()
            progressLayer?.path = circle.cgPath
            progressLayer?.fillColor = nil
            progressLayer?.strokeColor = getColor(key: RappleProgressBarFillColorKey).cgColor
            progressLayer?.lineWidth = 4.0
            backgroundView?.layer.addSublayer(progressLayer!)
            
            let w = (r * 2) - 10
            progressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: w))
            progressLabel?.center = center
            progressLabel?.textColor = getColor(key: RappleTintColorKey)
            progressLabel?.textAlignment = .center
            progressLabel?.numberOfLines = 0
            progressLabel?.lineBreakMode = .byWordWrapping
            backgroundView?.addSubview(progressLabel!)
        }
        var textVal = pgText
        if pgText == nil { textVal = "\(Int(progress * 100))%"; }
        progressLabel?.text = textVal
        
        progressLayer?.strokeStart = 0.0
        progressLayer?.strokeEnd = CGFloat(progress)
    }
}

extension RappleActivityIndicatorView {
    /** get color attribute values for key */
    fileprivate func getColor(key: String) -> UIColor {
        if let color = attributes[key] as? UIColor {
            return color
        }
        switch key {
        case RappleTintColorKey:
            return UIColor.white.withAlphaComponent(0.8)
        case RappleScreenBGColorKey:
            return UIColor.black.withAlphaComponent(0.4)
        case RappleProgressBGColorKey:
            return UIColor.black.withAlphaComponent(0.7)
        case RappleProgressBarColorKey:
            return UIColor.lightGray.withAlphaComponent(0.8)
        case RappleProgressBarFillColorKey:
            return UIColor.white.withAlphaComponent(0.9)
        default:
            return UIColor.white.withAlphaComponent(0.8)
        }
    }
    /** re-create after orientation change */
    internal func orientationChanged() {
        RappleActivityIndicatorView.sharedInstance.createActivityIndicator()
    }
    /** clear all UIs */
    fileprivate func clearUIs() {
        if let bgview = RappleActivityIndicatorView.sharedInstance.backgroundView {
            for v in bgview.subviews {
                v.removeFromSuperview()
            }
            if let layers = bgview.layer.sublayers {
                for l in layers {
                    l.removeFromSuperlayer()
                }
            }
            progressLayer = nil
            progressLayerBG = nil
            progressLabel = nil
        }
    }
    
    /** get key window */
    fileprivate var keyWindow: UIWindow {
        return UIApplication.shared.keyWindow!
    }
}
