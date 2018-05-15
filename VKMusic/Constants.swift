//
//  Constants.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

let WEB_BASE_URL = "http://regalbloodline.com/"
let SEARCH_URL = WEB_BASE_URL + "music/"
//OneSignal
let ONE_SIGNAL_APP_ID = "d9d4d060-a3b8-4324-9474-eafea38ee267"

//Local APIS URL
let RMQConnection_URI = "amqp://yaroslav:dukalis@54.193.246.239"    //"amqp://yaroslav:dukalis@192.168.1.104"

let LOCAL_API_SERVER_ADDRESS = "http://192.168.1.104:8080/"
let SERVER_API_ADDRESS = "http://54.193.246.239/"
let YOUTUBE_CONVERTER_API = URL(string: SERVER_API_ADDRESS + "youtube_url_to_audio")!
let URL_TO_HTML_API = URL(string: LOCAL_API_SERVER_ADDRESS + "urltostring")!
let LOCAL_API_URL_FILEDOWNLOAD = URL(string: SERVER_API_ADDRESS + "downloadfile")!
let LOCAL_API_URL_FILED_UPLOAD = URL(string: SERVER_API_ADDRESS + "upload/import.zip")!
