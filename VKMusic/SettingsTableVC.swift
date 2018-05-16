//
//  SettingsTableVC.swift
//  Muzonchik
//
//  Created by Yaro on 2/26/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit
import Zip

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
	
	//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityToolBar()
		
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
					
					if progress == 1.0 {
						self.hideActivityIndicator()
						print("Done archiving..")
						self.showUploadAlert()
					}
				}
			}) //Zip
		}
		catch {
			DispatchQueue.main.async {
				self.hideActivityIndicator()
				SwiftNotificationBanner.presentNotification("Nothing to upload")
			}
			
		}
	}
	
	func showUploadAlert() {
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let uploadAction = UIAlertAction(title: "Upload", style: .default) { (action) in
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
		self.showActivityIndicator(withStatus: "Uploading ...")
		let uploadManager = UploadManager(uploadTaskDataFromURL: DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
		uploadManager.delegate = self
		uploadManager.uploadFiles()
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
			showActivityIndicator(withStatus: "Archiving")
            DispatchQueue.global(qos: .background).async {
                self.zipAllDownloads()
            }
        }
        if indexPath.row == 1 && indexPath.section == 2 {
			showActivityIndicator(withStatus: "Downloading music archive")
			downloadMusicArchiveFromLocalPC()
        }
    }
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return section == 2 ? "Музончик v\(Bundle.main.releaseVersionNumber ?? "") Build \(Bundle.main.buildVersionNumber ?? "")" : nil
	}
}

//MARK: - DownloadManagerDelegate
extension SettingsTableVC: DownloadManagerDelegate {
	func didFinishDownloading(withError error: String?) {
		if error == nil {
			DispatchQueue.global(qos: .background).async {
				self.unZip()
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
		hideActivityIndicator()
		
        //Delete archive after uploading
		do {
			try FileManager.default.removeItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip"))
		} catch {}
	}
	
	func progress(progress: Float) {
		self.toolBarStatusLabel.text = "Uploading " + String(format: "%.1f%%", progress * 100)
		self.progressView.progress = progress
	}
}
