//
//  SwiftNotificationBanner.swift
//  SwiftNotificationBannerDemo
//
//  Created by Yaroslav on 10/02/16.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class SwiftNotificationBanner: NSObject {
        
    class func presentNotification(_ title: String) {
        DispatchQueue.main.async {
            SwiftNotificationBanner().present(title)
        }
    }
    
    func present(_ title: String) {
        let bannerView = SwiftNotificationBannerView(frame: CGRect(x: 0, y: -95.0, width: UIScreen.main.bounds.width, height: 95.0))
        bannerView.messageLabel.text = title
        
        if let _window = UIApplication.shared.keyWindow {
            _window.addSubview(bannerView)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            bannerView.transform = CGAffineTransform(translationX: 0, y: 95.0)
            
            }, completion: {
                finished in
                
                UIView.animate(withDuration: 0.2, delay: 3.0, options: .curveEaseOut, animations: {
                    bannerView.transform = CGAffineTransform.identity
                    }, completion: {
                        finished in
                        bannerView.removeFromSuperview()
                })
        })
    }
}
