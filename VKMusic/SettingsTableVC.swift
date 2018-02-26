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

class SettingsTableVC: UITableViewController {
    
    @IBOutlet weak var musicLibrarySizeLabel: UILabel!
    @IBOutlet weak var numberOfCurrentFilesLabel: UILabel!
    @IBOutlet weak var audioCategorySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioCategorySwitch.isOn = UserDefaults.standard.value(forKey: "mixAudioWithOthers") as? Bool ?? true
        musicLibrarySizeLabel.text = GlobalFunctions.shared.getFriendlyCacheSize()
        numberOfCurrentFilesLabel.text = calculatedNumOfSongs()
    }
    
    func zipAllDownloads() {
        do {
            let zipFilePath = DocumentsDirectory.localDocumentsURL.appendingPathComponent("archive.zip")
            try Zip.zipFiles(paths: [DocumentsDirectory.localDocumentsURL.appendingPathComponent("Downloads")], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                print(progress)
//                self.numberOfCurrentFilesLabel.text = String(format: "%.1f%%", progress * 100)
                
                if progress == 1.0 {
                    self.presentActivityVC()
                }
            }) //Zip
            
        }
        catch {
            print("Something went wrong")
        }
    }
    
    func presentActivityVC() {
        let objectsToShare = [DocumentsDirectory.localDocumentsURL.appendingPathComponent("archive.zip")]
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
    
    @IBAction func didTapDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCategorySwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "mixAudioWithOthers")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 2 {
            self.zipAllDownloads()
        }
    }
}
