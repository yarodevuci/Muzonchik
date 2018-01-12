//
//  SavedAudio.swift
//  VKMusic
//
//  Created by Yaroslav Dukal on 10/5/16.
//  Copyright © 2016 Yaroslav Dukal. All rights reserved.
//

import Foundation
import RealmSwift

class SavedAudio: Object {
    @objc dynamic var url         = ""
    @objc dynamic var title       = ""
    @objc dynamic var artist      = ""
    @objc dynamic var duration    = 0
}

