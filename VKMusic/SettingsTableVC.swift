//
//  SettingsTableVC.swift
//  Muzonchik
//
//  Created by Yaro on 2/26/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var musicLibrarySizeLabel: UILabel!
    @IBOutlet weak var numberOfCurrentFilesLabel: UILabel!
    @IBOutlet weak var audioCategorySwitch: UISwitch!
	@IBOutlet weak var totalDurationTimeLabel: UILabel!
    @IBOutlet weak var uploadToServerLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    
	//MARK: - Variables
	var activityIndicator = UIActivityIndicatorView()
	var toolBarStatusLabel = UILabel()
	var progressView = UIProgressView()
    var isTaskActive = false
    var fileCounter = 0
    var totalFiles = 0
	
	//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityToolBar()
		
        audioCategorySwitch.isOn = UserDefaults.standard.value(forKey: "mixAudioWithOthers") as? Bool ?? true
        musicLibrarySizeLabel.text = GlobalFunctions.shared.getFriendlyCacheSize()
        numberOfCurrentFilesLabel.text = calculatedNumOfSongs()
    }
	
	func showUploadAlert() {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let uploadAction = UIAlertAction(title: "Upload", style: .default) { (action) in
            self.showActivityIndicator(withStatus: "Uploading ...")
            self.fileCounter = 0
			self.uploadZipToLocalPC()
		}
		
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
            self.resetUI()
        }
		
		sheet.addAction(uploadAction)
		sheet.addAction(cancelAction)
		
//		sheet.popoverPresentationController?.sourceView = tableView
//		sheet.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
		
		DispatchQueue.main.async {
			self.present(sheet, animated: true, completion:nil)
		}
	}
	
	func uploadZipToLocalPC() {
		self.progressView.progress = Float(0)
		UploadManager.shared.delegate = self
        
        if let downloadedAudioFiles = CoreDataManager.shared.fetchSavedResults() {
            totalFiles = downloadedAudioFiles.count
            UploadManager.shared.uploadFile(audio: downloadedAudioFiles[fileCounter])
            fileCounter += 1
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
	
	func downloadMusicArchiveFromLocalPC() {
		DownloadManager.shared.activate()
		DownloadManager.shared.delegate = self
		let task = DownloadManager.shared.activate().downloadTask(with: DOWNLOAD_ZIP_FILE_URL)
		task.resume()
	}
    
    func grayOutButtons() {
        isTaskActive = true
        uploadToServerLabel.textColor = .gray
        downloadLabel.textColor = .gray
    }
    
    func resetUI() {
        isTaskActive = false
        uploadToServerLabel.textColor = .white
        downloadLabel.textColor = .white
    }
    
    @IBAction func didTapDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCategorySwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "mixAudioWithOthers")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isTaskActive { return }
        
        if indexPath.row == 0 && indexPath.section == 2 {
            self.showUploadAlert()
//            DispatchQueue.global(qos: .background).async {
//                self.zipAllDownloads()
//
//            }
        }
        if indexPath.row == 1 && indexPath.section == 2 {
			showActivityIndicator(withStatus: "Downloading music archive")
			downloadMusicArchiveFromLocalPC()
        }
    }
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return section == 2 ? "Музончик v\(Bundle.main.releaseVersionNumber ?? "") Build \(Bundle.main.buildVersionNumber ?? "")\nLocal IP: \(LOCAL_IP)" : nil
	}
}

//MARK: - DownloadManagerDelegate
extension SettingsTableVC: DownloadManagerDelegate {
	func didFinishDownloading(withError error: String?) {
        if error == nil { 
			DispatchQueue.global(qos: .background).async {
				
			}
		} else {
			DispatchQueue.main.async {
				self.hideActivityIndicator()
				SwiftNotificationBanner.presentNotification(error ?? "Some error occured")
			}
		}
	}
	
	func receivedProgress(_ progress: Float) {
		DispatchQueue.main.async {
			self.toolBarStatusLabel.text = "Downloading " + String(format: "%.1f%%", progress * 100)
			self.progressView.progress = progress
		}
	}
}

//MARK: - SessionDelegage
extension SettingsTableVC: UploadManagerDelegage {
	func didReceiveResponseJSON(_ json: [String : Any]) {
        
        if let error = json["error"] as? String {
            DispatchQueue.main.async {
                SwiftNotificationBanner.presentNotification("Error occured while uploading a file. \(error)")
            }
        }
        //Delete archive after uploading
		do {
			try FileManager.default.removeItem(at: AppDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
		} catch {}
        print(json)
        if fileCounter < totalFiles {
            uploadZipToLocalPC()
        } else {
            hideActivityIndicator()
        }
	}
	
    func progress(progress: Float) {
        DispatchQueue.main.async {
            self.toolBarStatusLabel.text = "Uploading file \(self.fileCounter) of \(self.totalFiles) "// + String(format: "%.1f%%", progress * 100)
            self.progressView.progress = progress
        }
    }
}
