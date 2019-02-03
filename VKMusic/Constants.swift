//
//  Constants.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

let WEB_BASE_URL = "https://m.my.mail.ru/"
let SEARCH_URL = WEB_BASE_URL + "music/search/"
//OneSignal
let ONE_SIGNAL_APP_ID = "d9d4d060-a3b8-4324-9474-eafea38ee267"

//Local APIS URL
let LOCAL_IP = "192.168.1.93"
let SERVER_RMQ_URL = "amqp://yaroslav:dukalis@\(LOCAL_IP)"
let RMQConnection_URI = "amqp://yaroslav:dukalis@\(LOCAL_IP)"

let LOCAL_API_SERVER_ADDRESS = "http://\(LOCAL_IP):8080/"
let SERVER_API_ADDRESS = LOCAL_API_SERVER_ADDRESS//"http://50.18.38.224/"

let YOUTUBE_CONVERTER_API = URL(string: SERVER_API_ADDRESS + "youtube_url_to_audio")!
let LOCAL_TRACK_DOWLOAD_URL = URL(string: SERVER_API_ADDRESS + "getLocalmp3List")!

let URL_TO_HTML_API = URL(string: LOCAL_API_SERVER_ADDRESS + "urltostring")!
let LOCAL_API_URL_FILEDOWNLOAD = URL(string: SERVER_API_ADDRESS + "downloadfile")!
//ZIP FILE OPERATIONS URLS
let UPLOAD_ZIP_FILE_URL = URL(string: SERVER_API_ADDRESS + "upload/import.zip")!
let DOWNLOAD_ZIP_FILE_URL = URL(string: SERVER_API_ADDRESS + "downloads/import.zip")!
