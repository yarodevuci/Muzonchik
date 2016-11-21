//
//  Audio.swift
//  VKMusic
//

func ==(lhs: Audio, rhs: Audio) -> Bool {
    return lhs.url == rhs.url
}

struct Audio: Equatable {
    
    var id: Int
    let url: String?
    let title: String
    let artist: String
    let duration: Int
    var ownerID: Int
    
    init(serverData: [String: AnyObject]) {
        url = "\(serverData["url"]!)"
        title = "\(serverData["title"]!)"
        artist = "\(serverData["artist"]!)"
        duration = serverData["duration"] as! Int
        id = serverData["id"] as! Int
        ownerID = serverData["owner_id"] as! Int
    }
    
    init(url: String?, title: String, artist: String , duration: Int) {
        self.url = url
        self.title = title
        self.artist = artist
        self.duration = duration
        id = 0
        ownerID = 0
    }
}
