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
    var thumbnail_image: UIImage?
	var id = 0
    
    init(withThumbnailImage timage: UIImage?, url: String, title: String, artist: String , duration: Int) {
        self.thumbnail_image = timage
        self.url = url
        self.title = title.stripped
        self.artist = artist.stripped
        self.duration = duration
    }
	
    //Used for Core Data loading Image
	init(withID id: Int, url: String, title: String, artist: String , duration: Int, t_img: UIImage?) {
		self.id = id
		self.url = url
		self.title = title.stripped
		self.artist = artist.stripped
		self.duration = duration
        self.thumbnail_image = t_img
	}
    
    init(withElement element: Element) {
//        var title = ""
        //ARTIST NAME:
//        let artist = try! element.child(1).select("span").array()[1].select("a").text()
        let artist = try! element.select("span").array()[1].text() ?? ""
        //MP3 file name
//        if try! element.child(1).select("span").array().count < 3 {
//            title = try! element.child(1).select("span").array()[1].select("span").first()?.text() ?? "Unknown"
//        } else {
//            title = try! element.child(1).select("span").array()[2].select("span").first()?.text() ?? "Unknown"
//        }
        let title = try! element.select("span").array()[0].text() ?? ""
        //EXTRACT TRACK MP3 FILE
//        let url = try! element.child(0).select("li").attr("data-url")
        let url = try! element.attr("data-audio-src")
        //GET DURATION
//        let duration = try! element.child(2).text()
        let duration =  try! element.select("span").array()[2].text() ?? ""
        
        self.url = url
		self.title = title.stripped.isEmpty ? "Unknown" : title.stripped
        self.artist = artist.stripped.isEmpty ? "Unknown" : artist.stripped
        self.duration = duration.durationToInt
        
        self.thumbnail_image = #imageLiteral(resourceName: "ArtPlaceholder")
    }
}
