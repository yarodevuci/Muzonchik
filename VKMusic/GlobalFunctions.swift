//
//  GlobalFunctions.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 9/30/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GlobalFunctions {
    //Dropdown menu color
    static let dropDownMenuColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
    //VK Blue Color
    static let vkNavBarColor = UIColor(red:0.35, green:0.52, blue:0.71, alpha:1.0)
    //Blue color
    let blueButtonColor = UIColor(red:0.04, green:0.38, blue:1.00, alpha:1.0).cgColor
    //Red color
    let redButtonColor = UIColor(red:0.93, green:0.11, blue:0.14, alpha:1.0).cgColor
    
    var animator : ARNTransitionAnimator!
    var modalVC : AudioPlayerVC!
    
    //Set up MiniPlayer Transition
    func setupAnimator(vc: UIViewController, miniPlayerView: UIView, view: UIView, cView: UIView, tableView: UITableView) {
        
        miniPlayerView.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        modalVC = storyboard.instantiateViewController(withIdentifier: "AudioPlayerVC") as? AudioPlayerVC
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.tapCloseButtonActionHandler = { [unowned self] in
            self.animator.interactiveType = .none
        }
        
        animator = ARNTransitionAnimator(operationType: .present, fromVC: vc, toVC: modalVC)
        animator.usingSpringWithDamping = 1.8 //original value is 0.8
        animator.gestureTargetView = miniPlayerView
        animator.interactiveType = .present
        
        // Present
        self.animator.presentationBeforeHandler = { [unowned self] cView, transitionContext in
            //print("start presentation")
            vc.beginAppearanceTransition(false, animated: false)
            self.animator.direction = .top
            
            self.modalVC.view.frame.origin.y = miniPlayerView.frame.origin.y + miniPlayerView.frame.size.height
            view.insertSubview(self.modalVC.view, belowSubview: view)
            
            view.layoutIfNeeded()
            self.modalVC.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = miniPlayerView.frame.origin.y
            let endOriginY = -miniPlayerView.frame.size.height
            let diff = -endOriginY + startOriginY
            
            self.animator.presentationCancelAnimationHandler = { cView in
                miniPlayerView.frame.origin.y = startOriginY
                self.modalVC.view.frame.origin.y = miniPlayerView.frame.origin.y + miniPlayerView.frame.size.height
                cView.alpha = 1.0
                miniPlayerView.alpha = 1.0
                for subview in miniPlayerView.subviews {
                    subview.alpha = 1.0
                }
            }
            
            self.animator.presentationAnimationHandler = { [unowned self] cView, percentComplete in
                let _percentComplete = percentComplete >= 0 ? percentComplete : 0
                miniPlayerView.frame.origin.y = startOriginY - (diff * _percentComplete)
                if miniPlayerView.frame.origin.y < endOriginY {
                    miniPlayerView.frame.origin.y = endOriginY
                }
                self.modalVC.view.frame.origin.y = miniPlayerView.frame.origin.y + miniPlayerView.frame.size.height
                
                let alpha = 1.0 - (1.0 * _percentComplete)
                cView.alpha = alpha + 0.5
                for subview in miniPlayerView.subviews {
                    subview.alpha = alpha
                }
                
            }
            
            self.animator.presentationCompletionHandler = { cView, completeTransition in
                vc.endAppearanceTransition()
                
                if completeTransition {
                    
                    self.modalVC.view.removeFromSuperview()
                    cView.alpha = 1
                    cView.addSubview(self.modalVC.view)
                    self.animator.interactiveType = .dismiss
                    self.animator.gestureTargetView = self.modalVC.view
                    self.animator.direction = .bottom
                } else {
                    vc.beginAppearanceTransition(true, animated: false)
                    vc.endAppearanceTransition()
                }
            }
        }
        
        // Dismiss
        self.animator.dismissalBeforeHandler = { [unowned self] cView, transitionContext in
            //print("start dismissal")
            vc.beginAppearanceTransition(true, animated: false)
            vc.view.insertSubview(self.modalVC.view, belowSubview: view)
            
            vc.view.layoutIfNeeded()
            
            self.modalVC.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = 0 - miniPlayerView.bounds.size.height
            let endOriginY = cView.bounds.size.height - miniPlayerView.frame.size.height
            let diff = -startOriginY + endOriginY
            
            self.animator.dismissalCancelAnimationHandler = { cView in
                miniPlayerView.frame.origin.y = startOriginY
                self.modalVC.view.frame.origin.y = miniPlayerView.frame.origin.y + miniPlayerView.frame.size.height
                cView.alpha = 1
                miniPlayerView.alpha = 0.0
                for subview in miniPlayerView.subviews {
                    subview.alpha = 0.0
                }
            }
            
            self.animator.dismissalAnimationHandler = { cView, percentComplete in
                let _percentComplete = percentComplete >= -0.05 ? percentComplete : -0.05
                miniPlayerView.frame.origin.y = startOriginY + (diff * _percentComplete)
                self.modalVC.view.frame.origin.y = miniPlayerView.frame.origin.y + miniPlayerView.frame.size.height
                
                let alpha = 1.0 * _percentComplete
                cView.alpha = alpha + 0.5
                miniPlayerView.alpha = 1.0
                for subview in miniPlayerView.subviews {
                    subview.alpha = alpha
                }
            }
            
            self.animator.dismissalCompletionHandler = { cView, completeTransition in
                vc.endAppearanceTransition()
                
                if completeTransition {
                    
                    self.modalVC.view.removeFromSuperview()
                    tableView.reloadData()
                    self.animator.gestureTargetView = miniPlayerView
                    self.animator.interactiveType = .present
                } else {
                    self.modalVC.view.removeFromSuperview()
                    cView.addSubview(self.modalVC.view)
                    vc.beginAppearanceTransition(false, animated: false)
                    vc.endAppearanceTransition()
                }
            }
        }
        self.modalVC.transitioningDelegate = self.animator
    }
    
    //TableView Empty state
    func emptyMessage(message:String, tableView: UITableView, view: UIView) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: -view.bounds.size.height / 2, width: view.bounds.size.width, height: view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 22)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
    //Save audio info to Realm
    func createSavedAudio(title: String, artist: String, duration: Int, url: URL) {
        let savedAudio = SavedAudio()
        savedAudio.title = title
        savedAudio.artist = artist
        savedAudio.duration = duration
        savedAudio.url = url.absoluteString
        
        let realm = try! Realm()
        try! realm.write { realm.add(savedAudio)}
    }
}

