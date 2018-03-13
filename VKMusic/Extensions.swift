//
//  Extensions.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

//MARK: - String
extension String {
    
    var durationToInt: Int {
        let comp = self.components(separatedBy: ":")
        let min = Int(comp[0])
        let sec = Int(comp[1])
        return ((min ?? 0) * 60) + (sec ?? 0)
    }
	
	var stripped: String {
		let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
		return self.filter { okayChars.contains($0) }
	}
}
//MARK: - Double
extension Double {
	func parsedTimeDuration() -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = .abbreviated
		guard let formattedString = formatter.string(from: self) else { return "" }
		return formattedString
	}
}

//MARK: - Int
extension Int {
    
    var toAudioString: String {
        let minutes = self / 60
        let seconds = self - minutes * 60
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        return "\(minutes):\(seconds)"
    }
}

//MARK: - UIColor
extension UIColor {
    open class var dropDownMenuColor: UIColor { return UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0) }
    open class var estBackGroundColor: UIColor { return UIColor(red:0.38, green:0.38, blue:0.38, alpha:1.0) }
    open class var lightBlack: UIColor { return UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0) }
    open class var blueButtonColor: CGColor { return UIColor(red:0.04, green:0.38, blue:1.00, alpha:1.0).cgColor }
	open class var pinkColor: UIColor { return UIColor(red:0.77, green:0.14, blue:0.29, alpha:1.0) }
    open class var splashBlue: UIColor { return UIColor(red:0.06, green:0.10, blue:0.17, alpha:1.0) }
	open class var playerBackgroundColor: UIColor { return UIColor(red:0.11, green:0.11, blue:0.12, alpha:1.0) }
}

//MARK: - UIViewController
extension UIViewController {
   
    func presentViewControllerWithNavBar(identifier: String) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: identifier)
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.barStyle = .blackTranslucent
        DispatchQueue.main.async {
            self.present(navController, animated:true, completion: nil)
        }
    }
}

//MARK: - UIView extension
extension UIView {
	func roundCorner(corners: UIRectCorner, radius: CGFloat) {
		let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let maskLayer = CAShapeLayer()
		maskLayer.frame = bounds
		maskLayer.path = maskPath.cgPath
		layer.mask = maskLayer
	}
}
//MARK: - Notification.Name
extension Notification.Name {
	static let nextTrack = Notification.Name("playNextSong")
	static let previousTrack = Notification.Name("playPreviousSong")
	static let playTrackAtIndex = Notification.Name("playTrackAtIndex")
}

//MARK: - Bundle
extension Bundle {
	var releaseVersionNumber: String? { return self.infoDictionary?["CFBundleShortVersionString"] as? String }
	var buildVersionNumber: String? { return self.infoDictionary?["CFBundleVersion"] as? String }
}
