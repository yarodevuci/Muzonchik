//
//  SettingsTableVC.swift
//  Muzonchik
//
//  Created by Yaro on 2/26/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import UIKit
import RealmSwift
import Zip
import SVProgressHUD
import SwiftyDropbox

class SettingsTableVC: UITableViewController {
    
    @IBOutlet weak var musicLibrarySizeLabel: UILabel!
    @IBOutlet weak var numberOfCurrentFilesLabel: UILabel!
    @IBOutlet weak var audioCategorySwitch: UISwitch!
    
    let client = DropboxClient(accessToken: "NmIeH0pT1foAAAAAAAAiguXgIQmC_V0CnwkgG7DZKOF4c4yuYEclYPRldub7UAI3")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DropboxClientsManager.authorizedClient = client
        
        audioCategorySwitch.isOn = UserDefaults.standard.value(forKey: "mixAudioWithOthers") as? Bool ?? true
        musicLibrarySizeLabel.text = GlobalFunctions.shared.getFriendlyCacheSize()
        numberOfCurrentFilesLabel.text = calculatedNumOfSongs()
        
        
        //unZip()
        //dowloadMusicArchiveFromDropBox()
    }
    
    func zipAllDownloads() {
        do {
            let zipFilePath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")
            let downloadsPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("Downloads")
            let realmPath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("default.realm")
            try Zip.zipFiles(paths: [downloadsPath, realmPath], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                
                DispatchQueue.main.async {
                    SVProgressHUD.setStatus("Archiving " + String(format: "%.1f%%", progress * 100))
                }
                if progress == 1.0 {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
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
        let realm = try! Realm()
        let downloadedAudioFiles = realm.objects(SavedAudio.self)
        return downloadedAudioFiles.count.description
    }
    
    func dowloadMusicArchiveFromDropBox() {
        // Download to URL
        SVProgressHUD.show(withStatus: "Downloading music archive")
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
                        SVProgressHUD.dismiss()
                        SwiftNotificationBanner.presentNotification("Nothing to downlad")
                    }
                    print(error)
                }
            }
            .progress { progressData in
                SVProgressHUD.setStatus("Downloading " + String(format: "%.1f%%", progressData.fractionCompleted * 100))
                print(progressData)
        }
    }
    
    func unZip() {
        do {
            let zipFilePath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")
            try Zip.unzipFile(zipFilePath, destination: DocumentsDirectory.localDocumentsURL, overwrite: true, password: nil, progress: { (progress) in
                print(progress)
                
                DispatchQueue.main.async {
                    SVProgressHUD.setStatus("Unzipping " + String(format: "%.1f%%", progress * 100))
                }
                if progress == 1.0 {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
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
                SVProgressHUD.dismiss()
            }
            print("Something went wrong")
        }
        
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
            SVProgressHUD.show(withStatus: "Archiving")
            DispatchQueue.global(qos: .background).async {
                self.zipAllDownloads()
            }
        }
        if indexPath.row == 1 && indexPath.section == 2 {
            SVProgressHUD.show(withStatus: "Unzipping files")
            self.dowloadMusicArchiveFromDropBox()
        }
    }
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return section == 2 ? "Музончик v\(Bundle.main.releaseVersionNumber ?? "") Build \(Bundle.main.buildVersionNumber ?? "")" : nil
	}
}
