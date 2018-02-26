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
    open class var vkNavBarColor: UIColor { return UIColor(red:0.35, green:0.52, blue:0.71, alpha:1.0) }
    open class var lightBlack: UIColor { return UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.0) }
    open class var blueButtonColor: CGColor { return UIColor(red:0.04, green:0.38, blue:1.00, alpha:1.0).cgColor }
    open class var redButtonColor: CGColor { return UIColor(red:0.93, green:0.11, blue:0.14, alpha:1.0).cgColor }
    open class var splashBlue: UIColor { return UIColor(red:0.06, green:0.10, blue:0.17, alpha:1.0) }
}

//MARK: - UIViewController
extension UIViewController {
   
    func presentViewControllerWithNavBar(identifier: String) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: identifier)
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.barStyle = .blackTranslucent
        navController.navigationBar.barTintColor = .splashBlue
        DispatchQueue.main.async {
            self.present(navController, animated:true, completion: nil)
        }
    }
}
