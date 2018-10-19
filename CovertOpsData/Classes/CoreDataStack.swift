import Foundation
import CoreData

class CoreDataStack: Database {
    
    let dataModelName: String
    let persistentContainer: NSPersistentContainer
    
    let backgroundContext: NSManagedObjectContext
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(dataModelName: String, at url: URL?) {
        self.dataModelName = dataModelName
        
        persistentContainer = NSPersistentContainer(name: dataModelName)
        var descriptions = [NSPersistentStoreDescription]()
        if let url = url {
            let directoryUrl = url.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: directoryUrl.absoluteString) {
                do {
                    try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: [:])
                } catch {
                    // print(error)
                }
            }
            print("Loading persistent database at:\n\(url)")
            let description = NSPersistentStoreDescription(url: url)
            descriptions.append(description)
        } else {
            descriptions.append(NSPersistentStoreDescription())
            print("Initializing in-memory store.")
        }
        persistentContainer.persistentStoreDescriptions = descriptions
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] notification in
                
                if let viewContext = self?.persistentContainer.viewContext,
                    let savedContext = notification.object as? NSManagedObjectContext,
                    savedContext.parent == viewContext {
                    
                    viewContext.mergeChanges(fromContextDidSave: notification)
                    self?.save(viewContext)
                }
            }
        )
    }
    
    func load(completion: @escaping (Error?)->()) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            self.backgroundContext.parent = self.persistentContainer.viewContext
            completion(error)
        }
    }
    
    // MARK:  ..- Core Data Saving support
    
    func save(_ context: NSManagedObjectContext) {
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            var message = "\n\n *** FAILED TO SAVE! ***\n"
            let userInfo = nserror.userInfo
            var managedObject: NSManagedObject?
            if let detailedErrors = userInfo[ "NSDetailedErrors" ] as? [NSError] {
                for detailedError in detailedErrors {
                    if let validationField = detailedError.userInfo[ "NSValidationErrorKey" ] as? String,
                        let object = detailedError.userInfo[ "NSValidationErrorObject" ] as? NSManagedObject {
                        managedObject = object
                        message += "\n - Missing value for non-optional field \"\(validationField)\" on object \(managedObject!.entity.name!))."
                    }
                }
            } else if let validationField = userInfo[ "NSValidationErrorKey" ] as? String,
                let object = userInfo[ "NSValidationErrorObject" ] as? NSManagedObject {
                managedObject = object
                message += "\n - Missing value for non-optional field \"\(validationField)\" on object \(managedObject!.entity.name!)."
            }
            
            assertionFailure(message + "\n\n")
        }
    }
}
