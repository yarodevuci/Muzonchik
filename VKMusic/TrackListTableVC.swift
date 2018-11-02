//
//  TrackListTableVC.swift
//  VKMusic
//
//  Created by Yaro on 2/23/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import SwiftSoup
import LNPopupController
import RMQClient

class TrackListTableVC: UITableViewController {
	
	//MARK: - Constants
	let searchController = UISearchController(searchResultsController: nil)
    
	//MARK: - Variables
	var currentSelectedIndex = -1
	var audioFiles = [Audio]()
	var filterAudios = [Audio]()
	var activeDownloads = [String: Download]()
	var isDownloadedListShown = false
	var activityIndicator = UIActivityIndicatorView()
	var toolBarStatusLabel = UILabel()
	
	lazy var downloadsSession: URLSession = {
		let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
		let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		return session
	}()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	//MARK: - viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
//		setupDropdownMenu()
//		pullMusic()
		fetchDownloads()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if ProcessInfo.processInfo.operatingSystemVersion.majorVersion <= 10 {
			let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
			tableView.contentInset = insets
			tableView.scrollIndicatorInsets = insets
		}
	}
	
	@objc func playTrackAtIndex(notification: NSNotification) {
		if let index = notification.userInfo?["index"] as? Int {

            let selectedIndexPath = IndexPath(item: index, section: 0)
            let oldIndexPath = IndexPath(item: currentSelectedIndex, section: 0)
            tableView.reloadRows(at: [oldIndexPath, selectedIndexPath], with: .none)
            
            currentSelectedIndex = index
		}
	}
	
	private func setupVolumeBar() {
		let volume = SubtleVolume(style: .dashes)
		let volumeHeight: CGFloat = 20
		let volumeOrigin: CGFloat = -20
		
		volume.frame = CGRect(x: 0, y: volumeOrigin, width: UIScreen.main.bounds.width, height: volumeHeight)
		volume.barTintColor = .pinkColor
		volume.barBackgroundColor = UIColor.white.withAlphaComponent(0.3)
		volume.animation = .slideDown
		navigationController?.navigationBar.addSubview(volume)
	}
	
	private func setupUI() {
		NotificationCenter.default.addObserver(self, selector: #selector(playTrackAtIndex), name: .playTrackAtIndex, object: nil)
		setupActivityToolBar()
		setupRefreshControl()
		setupVolumeBar()
		setupMimiMusicPlayerView()
		addRightBarButton()
		setupSearchBar()
		setBackViewForTableView()
	}

	func setBackViewForTableView() {
		let backView = UIView(frame: self.tableView.bounds)
		backView.backgroundColor = .youtubeDarkGray
		self.tableView.backgroundView = backView
	}
	
	private func setupRefreshControl() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(fetchDownloads), for: .valueChanged)

		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			if let refreshControl = refreshControl {
				tableView.addSubview(refreshControl)
			}
		}
	}
	
	private func addRightBarButton() {
		let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(didTapSettingsButton))
		self.navigationItem.rightBarButtonItem = rightBarButton
	}
	
	@objc func didTapSettingsButton() {
		self.presentViewControllerWithNavBar(identifier: "SettingsTableVC")
	}
	
	// Setup the Search Controller
	private func setupSearchBar() {
		if #available(iOS 9.1, *) {
			searchController.obscuresBackgroundDuringPresentation = false
		}
		searchController.searchBar.placeholder = "Search for music"
		
		let cancelButtonAttributes: [NSAttributedStringKey : Any] = [.foregroundColor: UIColor.white]
		UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, for: .normal)
		
		definesPresentationContext = true
		searchController.searchBar.barTintColor = .youtubeDarkGray
		searchController.searchBar.keyboardAppearance = .dark
		searchController.searchBar.delegate = self
		searchController.searchBar.textField?.textColor = .white
		searchController.searchBar.textField?.font = UIFont.systemFont(ofSize: 13)
		searchController.searchBar.textField?.backgroundColor = .lightBlack
		searchController.searchBar.textField?.layer.borderWidth = 2
		searchController.searchBar.textField?.autocapitalizationType = .none
		searchController.searchBar.textField?.layer.borderColor = UIColor.youtubeDarkGray.cgColor
		searchController.searchBar.textField?.layer.cornerRadius = 10
		searchController.searchBar.textField?.clipsToBounds = true
		tableView.tableHeaderView = searchController.searchBar
	}
	
	func setupActivityToolBar() {
		activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		activityIndicator.transform = CGAffineTransform(translationX: -5, y: 0)
		let activityContainer = UIView(frame: activityIndicator.frame)
		activityContainer.addSubview(activityIndicator)
		let activityIndicatorButton = UIBarButtonItem(customView: activityContainer)
		
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		let statusView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 44))
	
		toolBarStatusLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 44))
		toolBarStatusLabel.backgroundColor = .clear
		toolBarStatusLabel.textAlignment = .center
		toolBarStatusLabel.textColor = .white
		toolBarStatusLabel.adjustsFontSizeToFitWidth = true
		toolBarStatusLabel.minimumScaleFactor = 0.6
		statusView.addSubview(toolBarStatusLabel)
		let statusLabelButton = UIBarButtonItem(customView: statusView)
		toolbarItems = [activityIndicatorButton, spacer, statusLabelButton, spacer]
	}
	
	private func setupMimiMusicPlayerView() {
		UIProgressView.appearance(whenContainedInInstancesOf: [LNPopupBar.self]).tintColor = .pinkColor
		
		navigationController?.popupBar.progressViewStyle = .top
		navigationController?.popupBar.barStyle = .compact
		navigationController?.popupInteractionStyle = .drag
		navigationController?.popupBar.imageView.layer.cornerRadius = 5
		navigationController?.toolbar.barStyle = .black
		navigationController?.popupBar.tintColor = .white
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .left
		navigationController?.popupBar.subtitleTextAttributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
		navigationController?.popupBar.titleTextAttributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
		navigationController?.updatePopupBarAppearance()
	}
	
	private func setupDropdownMenu() {
		let items = ["Music", "Downloads"]
		let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title("Music"), items: items)
		menuView.cellSeparatorColor = .black
		menuView.cellHeight = 50
		menuView.cellBackgroundColor = .lightBlack
		menuView.cellSelectionColor = .lightBlack
		menuView.shouldKeepSelectedCellColor = false
		menuView.cellTextLabelColor = .white
		menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 15)
		menuView.cellTextLabelAlignment = .center
		menuView.arrowPadding = 15
		menuView.animationDuration = 0.5
		menuView.maskBackgroundColor = .black
		menuView.maskBackgroundOpacity = 0.3
		menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
			indexPath == 0 ? self.pullMusic() : self.fetchDownloads()
		}
		self.navigationItem.titleView = menuView
		
	}
	
	@objc func fetchDownloads() {
        
        if searchController.isActive {
            self.refreshControl?.endRefreshing()
            return
        }
        
		isDownloadedListShown = true
//		currentSelectedIndex = -1
		
		if let downloadedAudioFiles = CoreDataManager.shared.fetchSavedResults() {
			audioFiles.removeAll()
			for audio in downloadedAudioFiles {
				let url = audio.value(forKey: "url") as? String ?? ""
				let artist = audio.value(forKey: "artist") as? String ?? ""
				let title = audio.value(forKey: "title") as? String ?? ""
				let duration = audio.value(forKey: "duration") as? Int ?? 0
				let id = audio.value(forKey: "id") as? Int ?? 0
                
                
                let urlString = "\(title)_\(artist)_\(duration).mp3"
                var default_thmb_img = getAlbumImage(fromURL: localFilePathForUrl(urlString)!)
                
                if url.hasSuffix(".mp4"), let thumb_imageData = audio.value(forKey: "thumbnail_img") as? Data {
                    default_thmb_img = UIImage(data: thumb_imageData) ?? #imageLiteral(resourceName: "ArtPlaceholder")
                }
                
                audioFiles.append(Audio(withID: id, url: url, title: title, artist: artist, duration: duration, t_img: default_thmb_img))
				
				//MARK: - Used this to rename files in the directory
//				do {
//					let documentDirectory = DocumentsDirectory.localDownloadsURL
//					let originPath = documentDirectory.appendingPathComponent("\(title)_\(artist).mp\(url.last ?? "3")")
//					let destinationPath = documentDirectory.appendingPathComponent("\(title)_\(artist)_\(duration).mp\(url.last ?? "3")")
//					try FileManager.default.moveItem(at: originPath, to: destinationPath)
//				} catch {
//					print(error)
//				}
			}
		}
		
		DispatchQueue.main.async {
			self.refreshControl?.endRefreshing()
			self.tableView.reloadData()
		}
	}
	
	func pullMusic() {
		currentSelectedIndex = -1
		isDownloadedListShown = false
		
		showActivityIndicator(withStatus: "Loading")
		GlobalFunctions.shared.urlToHTMLString(url: WEB_BASE_URL) { (htmlString, error) in
			if let error = error {
				print(error)
				DispatchQueue.main.async {
					SwiftNotificationBanner.presentNotification("Unable to load")
				}
				self.hideActivityIndicator()
			}
			if let htmlString = htmlString {
				self.parseHTML(html: htmlString)
			}
		}
	}
	
	func searchMusic(tag: String) {
		currentSelectedIndex = -1
		isDownloadedListShown = false
		
		showActivityIndicator(withStatus: "Searching for \(tag)")
		GlobalFunctions.shared.urlToHTMLString(url: SEARCH_URL + "\(tag)?offset=0&sameFromAjax=1") { (htmlString, error) in
			if let error = error {
				print(error)
				DispatchQueue.main.async {
					SwiftNotificationBanner.presentNotification(error)
				}
				self.hideActivityIndicator()
			}
			if let htmlString = htmlString {
				self.parseHTML(html: htmlString)
			}
		}
	}
	
	func parseHTML(html: String) {
		let els: Elements = try! SwiftSoup.parse(html).select("div")
		audioFiles.removeAll()
		for element: Element in els.array() {
			if try! element.className() == "eventContent__audio  mm-clickable mm-audioPlay" {
				let audioFile = Audio(withElement: element)
				audioFiles.append(audioFile)
			}
		}
		
		DispatchQueue.main.async {
			self.hideActivityIndicator()
			self.tableView.reloadData()
		}
	}
	
	func subscribeForProgress() {
		let conn = RMQConnection(uri: RMQConnection_URI, delegate: RMQConnectionDelegateLogger())
		conn.start()
		let ch = conn.createChannel()
		let q = ch.queue(GlobalFunctions.shared.getUserCurrentOneSigPushID())
		q.subscribe({ m in
			
			guard let messageData = String(data: m.body, encoding: String.Encoding.utf8) else { return }
			if let progress = Double(messageData) {
				let prettyProgress = "Converting " + String(format: "%.1f%%", progress * 100)
				DispatchQueue.main.async {
					self.toolBarStatusLabel.text = prettyProgress
				}
			}
			
			do {
				if let json = try JSONSerialization.jsonObject(with: m.body, options: .mutableContainers) as? [String: Any] {
					if let data = json["data"] as? [String : Any] {
						let title = data["title"] as? String ?? "Unknown"
						let duration = data["duration"] as? Int ?? 0
						let url = data["url"] as? String ?? ""
                        let thumbnail_url = data["thumbnail_url"] as? String ?? ""
                        
                        let thumbnail_URL = URL(string: thumbnail_url)
                        
                        DispatchQueue.main.async {
                            self.toolBarStatusLabel.text = "Getting Preview Image ..."
                        }
                        
                        DispatchQueue.global().async {
                            let data = try? Data(contentsOf: thumbnail_URL!)
                            let audio = Audio(withThumbnailImage: UIImage(data: data!)!, url: url, title: "YouTube", artist: title, duration: duration)
                            self.audioFiles.removeAll()
                            self.audioFiles.append(audio)
                            
                            DispatchQueue.main.async {
                                self.isDownloadedListShown = false
                                self.tableView.reloadData()
                                self.hideActivityIndicator()
                                
                            }
                        }
					}
					if let data = json["error"] as? [String : Any] {
						let error_message = data["message"] as? String ?? "Some error"
						SwiftNotificationBanner.presentNotification(error_message)
					}
					
					q.delete()
					conn.close()
					print("Operation Complete. PIKA Connection is now closed")
					
				}
			}  catch let error {
				//print("not json")
			}
		})
	}
    
    func getLocalTrack() {
        showActivityIndicator(withStatus: "Waiting for response ...")
        
        GlobalFunctions.shared.getLocalTrack { (audios, error) in
            if error == nil {
                self.currentSelectedIndex = -1
                
                guard let audios = audios else { return }
                
                self.audioFiles.removeAll()

                for audio in audios {
                    self.audioFiles.append(audio)
                }
                
                DispatchQueue.main.async {
                    self.isDownloadedListShown = false
                    self.tableView.reloadData()
                    self.hideActivityIndicator()
                }
            } else {
                DispatchQueue.main.async {
                    SwiftNotificationBanner.presentNotification(error ?? "Error parsing video")
                    self.hideActivityIndicator()
                }
            }
        }
    }
	
	func getAudioFromYouTubeURL(url: String) {
		showActivityIndicator(withStatus: "Waiting for response ...")
		GlobalFunctions.shared.convertYouTubeURL(url: url) { (message, error) in
			
			if error == nil {
                self.currentSelectedIndex = -1

				guard let message = message else { return }
				
                self.subscribeForProgress()
				DispatchQueue.main.async {
					self.toolBarStatusLabel.text = "Connection established."
				}
			} else {
				DispatchQueue.main.async {
					SwiftNotificationBanner.presentNotification(error ?? "Error parsing video")
					self.hideActivityIndicator()
				}
			}
		}
	}
	
	func isFiltering() -> Bool {
		return searchController.isActive && !(searchController.searchBar.text ?? "").isEmpty && isDownloadedListShown
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return audioFiles.count
		//return isFiltering() ? filterAudios.count : audioFiles.count
	}
		
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65.0
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return CGFloat(Float.ulpOfOne)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return isDownloadedListShown
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			deleteSong(indexPath.row)
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TrackListTableViewCell", for: indexPath) as! TrackListTableViewCell
		//        let audio: Audio
		//        isFiltering() ? (audio = filterAudios[indexPath.row]) : (audio = audioFiles[indexPath.row])
		//        cell.audioData = audio
		//        cell.downloadData = activeDownloads[audio.url]
		//        cell.checkMarkImageView.isHidden = !localFileExistsForTrack(audio)
		
		cell.delegate = self
		cell.audioData = audioFiles[indexPath.row]
		cell.downloadData = activeDownloads[audioFiles[indexPath.row].url]
		cell.checkMarkImageView.isHidden = !localFileExistsForTrack(audioFiles[indexPath.row])
		cell.isSelected = currentSelectedIndex == indexPath.row
		
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//        var audio: Audio
		//        isFiltering() ? (audio = filterAudios[indexPath.row]) : (audio = audioFiles[indexPath.row])
		if currentSelectedIndex != indexPath.row {
			
            let audio = audioFiles[indexPath.row]
//            currentSelectedIndex = indexPath.row
			
            let musicPlayerController = storyboard?.instantiateViewController(withIdentifier: "CompactMusicPlayerVC") as! CompactMusicPlayerVC
            musicPlayerController.tracks = audioFiles
            musicPlayerController.currentIndexPathRow = indexPath.row
            navigationController?.popupBar.marqueeScrollEnabled = true
            navigationController?.presentPopupBar(withContentViewController: musicPlayerController, animated: true, completion: nil)

            AudioPlayer.defaultPlayer.setPlayList(audioFiles)
            AudioPlayer.index = indexPath.row
			
            if localFileExistsForTrack(audio) {
                var trackURLString = ""
                if audio.url.hasSuffix(".mp3") || audio.url.hasSuffix(".mp4") {
                    trackURLString = audio.url
                } else { //MAILRU IS MISSING .mp3 extension, adding it manually to avoid bugs
                    trackURLString = audio.url + ".mp3"
                }
                let urlString = "\(audio.title)_\(audio.artist)_\(audio.duration).mp\(trackURLString.hasSuffix(".mp3") ? "3" : "4")"
                let url = localFilePathForUrl(urlString)
                AudioPlayer.defaultPlayer.playAudio(fromURL: url!)
            } else {
                let url = URL(string: audio.url)
                DispatchQueue.global(qos: .background).async {
                    AudioPlayer.defaultPlayer.playAudio(fromURL: url)
                }
            }
		}
	}
}

//MARK: - UISearchBar Delegate
extension TrackListTableVC: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		//searchBar.showsCancelButton = true
		//        if isDownloadedListShown {
		//            filterContentForSearchText(searchText)
		//        }
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if let url = UIPasteboard.general.string, url.hasPrefix("http") {
			searchBar.textField?.insertText(url)
            UIPasteboard.general.string = ""
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		fetchDownloads()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchText = searchBar.text {
			if searchText.hasPrefix("http") {
				getAudioFromYouTubeURL(url: searchText)
			} else if searchText == "q" {
                getLocalTrack()
            } else {
                searchMusic(tag: searchText.lowercased())

            }
		}
	}
	
	func filterContentForSearchText(_ searchText: String) {
		filterAudios = audioFiles.filter({(audio : Audio) -> Bool in
			return audio.title.lowercased().contains(searchText.lowercased())
		})
		tableView.reloadData()
	}
}
