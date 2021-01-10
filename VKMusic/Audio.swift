//
//  Audio.swift
//  VKMusic
//

func ==(lhs: Audio, rhs: Audio) -> Bool {
    return lhs.url == rhs.url
}

import SwiftSoup

class Audio: Equatable {
    
    var url = ""
    var title = "Unknown"
    var artist = "Unknown"
    var duration = 0
    var thumbnail_image: UIImage?
	var id = 0
    var originalIndex = 0
    
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
    
//    init(withElementOLD element: Element) {
//        //element.getElementsByClass("track-time").text()
//        //element.getElementsByClass("track-desc fx-1").text()
//        //try! element.getElementsByClass("track-dl")
//        let trackInfo = try! element.getElementsByClass("track-desc fx-1").text()
//        let tI = trackInfo.components(separatedBy: " - ")
//
//        let artist = tI[0]
//        let title = tI[1]//try! element.select("div").array()[9].child(0).attr("data-title") ?? ""
//        //EXTRACT TRACK MP3 FILE
//        let url = try! element.select("div").array()[8].child(0).attr("href")
//        //GET DURATION
//        let duration = try! element.getElementsByClass("track-time").text()
//
//        self.url = url
//		self.title = title.stripped.isEmpty ? "Unknown" : title.stripped
//        self.artist = artist.stripped.isEmpty ? "Unknown" : artist.stripped
//        self.duration = duration.toInt
//
//        self.thumbnail_image = #imageLiteral(resourceName: "ArtPlaceholder")
    
//        let artist = try! element.select("div").array()[0].getElementsByClass("ps-title nogog").text()
//        let title = try! element.select("div").array()[0].getElementsByClass("track-namew nogog").text()
//    }
    
    init(withElement element: Element) {
        let trackInfo = try! element.getElementsByClass("track-desc fx-1").text()
        let tI = trackInfo.components(separatedBy: " - ")
        
        let artist = tI[0]
        let title = tI[1]

        //EXTRACT TRACK MP3 FILE
        let url = try! element.getElementsByClass("track-dl").attr("href")
        //GET DURATION
        let duration = try! element.getElementsByClass("track-time").text()
        
        self.url = url.hasPrefix("http") ? url : ("https://mp3mob.net/" + url)
        self.title = title.stripped.isEmpty ? "Unknown" : title.stripped
        self.artist = artist.stripped.isEmpty ? "Unknown" : artist.stripped
        self.duration = duration.durationToInt
        
        self.thumbnail_image = #imageLiteral(resourceName: "ArtPlaceholder")
    }
}
