//
//  Audio.swift
//  VKMusic
//

func ==(lhs: Audio, rhs: Audio) -> Bool {
    return lhs.url == rhs.url
}

struct Audio: Equatable {
    
    let url: String?
    let title: String
    var artist = ""
    let duration: Int
    
    init(url: String?, title: String, artist: String , duration: Int) {
        self.url = url
        self.title = title
        self.artist = artist
        self.duration = duration
    }
}
