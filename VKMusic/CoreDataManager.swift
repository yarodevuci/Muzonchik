//
//  CoreDataStack.swift
//  Muzonchik
//
//  Created by Yaro on 3/9/18.
//  Copyright © 2018 Yaroslav Dukal. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
		
	static let shared = CoreDataManager()
	
	static var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle(for: CoreDataManager.self).url(forResource: "CoreDataModel", withExtension: "momd")! // type your database name here..
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		let url = DocumentsDirectory.localDocumentsURL.appendingPathComponent("CoreDataModel.sqlite") // type your database name here...
		var failureReason = "There was an error creating or loading the application's saved data."
		let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true as Bool), NSInferMappingModelAutomaticallyOption: NSNumber(value: true as Bool)]
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	var managedObjectContext: NSManagedObjectContext = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
	
	func saveToCoreData(audio: Audio){
		let entity = NSEntityDescription.entity(forEntityName: "TrackInfo", in: managedObjectContext)
		let manageObject = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
		
		manageObject.setValue(audio.url, forKey: "url")
		manageObject.setValue(audio.duration, forKey: "duration")
		manageObject.setValue(audio.artist, forKey: "artist")
		manageObject.setValue(audio.title, forKey: "title")
		manageObject.setValue(incrementedID(), forKey: "id")
		saveContext()		
	}
	
	func updateRecords() {
		let request: NSFetchRequest = TrackInfo.fetchRequest()
		
		do {
			let records = try managedObjectContext.fetch(request)
			for i in 0..<records.count {
				records[i].setValue(i, forKey: "id")
			}
			
		} catch {
			print(error.localizedDescription)
		}
		
		saveContext()
	}
	
	func fetchSavedResults() -> [NSManagedObject]? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackInfo")
		let entityDescription = NSEntityDescription.entity(forEntityName: "TrackInfo", in: managedObjectContext)
		fetchRequest.entity = entityDescription
		
		do {
			let result = try managedObjectContext.fetch(fetchRequest)
			return result as! [NSManagedObject]
			
		} catch {
			let fetchError = error as NSError
			return nil
		}
	}
	
	func incrementedID() -> Int32 {
		let request: NSFetchRequest = TrackInfo.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
		
		request.sortDescriptors = [sortDescriptor]
		request.fetchLimit = 1
		
		do {
			let tracks = try managedObjectContext.fetch(request)
			return (tracks.first?.id ?? 0) + 1
		} catch {
			print(error.localizedDescription)
		}
		return 0
	}
	
	func deleteAudioFile(withID id: Int) {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackInfo")
		fetchRequest.predicate = NSPredicate(format: "id == \(id)")
		fetchRequest.fetchLimit = 1
		let entityDescription = NSEntityDescription.entity(forEntityName: "TrackInfo", in: managedObjectContext)
		fetchRequest.entity = entityDescription
		
		do {
			let result = try managedObjectContext.fetch(fetchRequest)
			if result.count > 0 {
				managedObjectContext.delete(result.first as! NSManagedObject)
			}
		} catch {
			let fetchError = error as NSError
		}
		saveContext()
	}
}
