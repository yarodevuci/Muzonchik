//
//  SettingsTableVC.swift
//  Muzonchik
//
//  Created by Yaro on 2/26/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit
import Zip
import SwiftyDropbox

class SettingsTableVC: UITableViewController {
    
    @IBOutlet weak var musicLibrarySizeLabel: UILabel!
    @IBOutlet weak var numberOfCurrentFilesLabel: UILabel!
    @IBOutlet weak var audioCategorySwitch: UISwitch!
	@IBOutlet weak var totalDurationTimeLabel: UILabel!
	//MARK: - Variables
	var activityIndicator = UIActivityIndicatorView()
	var toolBarStatusLabel = UILabel()
	var progressView = UIProgressView()
	
	//MARK: - Constants
	let client = DropboxClient(accessToken: "NmIeH0pT1foAAAAAAAAiguXgIQmC_V0CnwkgG7DZKOF4c4yuYEclYPRldub7UAI3")

	//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityToolBar()
		
        DropboxClientsManager.authorizedClient = client
        
        audioCategorySwitch.isOn = UserDefaults.standard.value(forKey: "mixAudioWithOthers") as? Bool ?? true
        musicLibrarySizeLabel.text = GlobalFunctions.shared.getFriendlyCacheSize()
        numberOfCurrentFilesLabel.text = calculatedNumOfSongs()
    }
    
    func zipAllDownloads() {
        do {
            let zipFilePath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")
            let downloadsPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("Downloads")
            let sqlitePath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("CoreDataModel.sqlite")
			let sqlite_shmPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("CoreDataModel.sqlite-shm")
			let sqlite_walPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("CoreDataModel.sqlite-wal")
			
            try Zip.zipFiles(paths: [downloadsPath, sqlitePath, sqlite_shmPath, sqlite_walPath], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                
                DispatchQueue.main.async {
					self.toolBarStatusLabel.text = "Archiving " + String(format: "%.1f%%", progress * 100)
					self.progressView.progress = Float(progress)
                }
				if progress == 1.0 {
					DispatchQueue.main.async {
						self.hideActivityIndicator()
						self.presentActivityVC()
					}
				}
            }) //Zip
            
        }
        catch {
            print("Something went wrong")
        }
    }
    
    func presentActivityVC() {
        let objectsToShare = [DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
	func calculatedNumOfSongs() -> String {
		var timeSeconds = 0
		guard let downloadedAudioFiles = CoreDataManager.shared.fetchSavedResults() else { return 0.description }
		for audio in downloadedAudioFiles {
			let duration = audio.value(forKey: "duration") as? Int ?? 0
			timeSeconds += duration
		}

		totalDurationTimeLabel.text = Double(timeSeconds).parsedTimeDuration()
		return downloadedAudioFiles.count.description
	}
    
    func dowloadMusicArchiveFromDropBox() {
        // Download to URL
        let destURL = DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }
        client.files.download(path: "/import.zip", overwrite: true, destination: destination)
            .response { response, error in
                if let response = response {
                    print(response)
                    DispatchQueue.global(qos: .background).async {
                        self.unZip()
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        SwiftNotificationBanner.presentNotification("Nothing to downlad")
                    }
                    print(error)
                }
            }
            .progress { progressData in
				self.toolBarStatusLabel.text = "Downloading " + String(format: "%.1f%%", progressData.fractionCompleted * 100)
				self.progressView.progress = Float(progressData.fractionCompleted)
                print(progressData)
        }
    }
    
    func unZip() {
        do {
            let zipFilePath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")
            try Zip.unzipFile(zipFilePath, destination: DocumentsDirectory.localDocumentsURL, overwrite: true, password: nil, progress: { (progress) in
                print(progress)
                
                DispatchQueue.main.async {
					self.toolBarStatusLabel.text = "Unzipping " + String(format: "%.1f%%", progress * 100)
					self.progressView.progress = Float(progress)
                }
                if progress == 1.0 {
                    DispatchQueue.main.async {
						self.hideActivityIndicator()
                        self.musicLibrarySizeLabel.text = GlobalFunctions.shared.getFriendlyCacheSize()
                        self.numberOfCurrentFilesLabel.text = self.calculatedNumOfSongs()
                        
                        //Delete archive after downloading
                        do {
                            try FileManager.default.removeItem(at: zipFilePath)
                        } catch {
                            //Error Deleting file
                        }
                    }
                }
            })
            
        } catch {
            DispatchQueue.main.async {
                SwiftNotificationBanner.presentNotification("Something went wrong")
                self.hideActivityIndicator()
            }
            print("Something went wrong")
        }
        
    }
	
	func setupActivityToolBar() {
		self.navigationController?.toolbar.barStyle = .blackTranslucent
		activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		activityIndicator.transform = CGAffineTransform(translationX: -5, y: 0)
		let activityContainer = UIView(frame: activityIndicator.frame)
		activityContainer.addSubview(activityIndicator)
		let activityIndicatorButton = UIBarButtonItem(customView: activityContainer)
		
		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		
		let statusView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 40))
		progressView = UIProgressView(frame: CGRect(x: 0.0, y: 25, width: 200, height: 10))
		progressView.progress = 0.0
		progressView.tintColor = .red
		
		toolBarStatusLabel = UILabel(frame: CGRect(x: 0.0, y: 2.0, width: 200, height: 20))
		toolBarStatusLabel.backgroundColor = .clear
		toolBarStatusLabel.adjustsFontSizeToFitWidth = true
		toolBarStatusLabel.minimumScaleFactor = 0.5
		toolBarStatusLabel.textAlignment = .center
		toolBarStatusLabel.textColor = .white
		statusView.addSubview(toolBarStatusLabel)
		statusView.addSubview(progressView)
		let statusLabelButton = UIBarButtonItem(customView: statusView)
		toolbarItems = [activityIndicatorButton, spacer, statusLabelButton, spacer]
	}
	
	func showActivityIndicator(withStatus status: String) {
		DispatchQueue.main.async {
			self.toolBarStatusLabel.text = status
			self.activityIndicator.startAnimating()
			self.navigationController?.setToolbarHidden(false, animated: true)
		}
	}
	
	func hideActivityIndicator() {
		self.activityIndicator.stopAnimating()
		self.navigationController?.setToolbarHidden(true, animated: true)
		
	}
    
    @IBAction func didTapDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCategorySwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "mixAudioWithOthers")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 2 {
			showActivityIndicator(withStatus: "Archiving")
            DispatchQueue.global(qos: .background).async {
                self.zipAllDownloads()
            }
        }
        if indexPath.row == 1 && indexPath.section == 2 {
			showActivityIndicator(withStatus: "Downloading music archive")
            self.dowloadMusicArchiveFromDropBox()
        }
    }
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return section == 2 ? "Музончик v\(Bundle.main.releaseVersionNumber ?? "") Build \(Bundle.main.buildVersionNumber ?? "")" : nil
	}
}
