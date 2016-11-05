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

