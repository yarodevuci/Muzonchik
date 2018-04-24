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
//RabbitMQ
let RMQConnection_URI = "amqp://yaroslav:dukalis@192.168.1.104"
//let RMQConnection_URI = "amqp://yaroslav:dukalis@34.210.113.117"
//Local API URL
let LOCAL_API_URL = URL(string: "http://192.168.1.104:8080/audio")!
//let LOCAL_API_URL = URL(string: "http://ec2-34-210-113-117.us-west-2.compute.amazonaws.com/audio")!
let LOCAL_API_URL_TOHTML = URL(string: "http://192.168.1.104:8080/urltostring")!
let LOCAL_API_URL_FILEDOWNLOAD = URL(string: "http://192.168.1.104:8080/downloadfile")!
