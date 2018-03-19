//
//  SettingsHellper.swift
//  Muzonchik
//
//  Created by Yaro on 3/16/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation

extension SettingsTableVC {
	
	//MARK: - Unused at this moment
	func presentActivityVC() {
		let objectsToShare = [DocumentsDirectory.localDocumentsURL.appendingPathComponent("import.zip")]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		DispatchQueue.main.async {
			self.present(activityVC, animated: true, completion: nil)
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
		self.progressView.progress = 0
		self.toolBarStatusLabel.text = ""
		self.activityIndicator.stopAnimating()
		self.navigationController?.setToolbarHidden(true, animated: true)
	}
}
