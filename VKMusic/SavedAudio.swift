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
    dynamic var url         = ""
    dynamic var title       = ""
    dynamic var artist      = ""
    dynamic var duration    = 0
}

