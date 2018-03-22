//
//  Audio.swift
//  VKMusic
//

func ==(lhs: Audio, rhs: Audio) -> Bool {
    return lhs.url == rhs.url
}

import SwiftSoup

struct Audio: Equatable {
    
    var url = ""
    var title = "Unknown"
    var artist = "Unknown"
    var duration = 0
	var id = 0
    
	init(url: String, title: String, artist: String , duration: Int) {
        self.url = url
        self.title = title.stripped
        self.artist = artist.stripped
        self.duration = duration
    }
	
	init(withID id: Int, url: String, title: String, artist: String , duration: Int) {
		self.id = id
		self.url = url
		self.title = title.stripped
		self.artist = artist.stripped
		self.duration = duration
	}
    
    init(withElement element: Element) {
        var title = ""
        //ARTIST NAME:
        let artist = try! element.child(1).select("span").array()[1].select("a").text()
        //MP3 file name
        if try! element.child(1).select("span").array().count < 3 {
            title = try! element.child(1).select("span").array()[1].select("span").first()?.text() ?? "Unknown"
        } else {
            title = try! element.child(1).select("span").array()[2].select("span").first()?.text() ?? "Unknown"
        }
        //EXTRACT TRACK MP3 FILE
        let url = try! element.child(0).select("li").attr("data-url")
        //GET DURATION
        let duration = try! element.child(2).text()
        
        self.url = url
		self.title = title.stripped.isEmpty ? "Unknown" : title.stripped
        self.artist = artist.stripped.isEmpty ? "Unknown" : artist.stripped
        self.duration = duration.durationToInt
    }
}
