import Foundation
import CoreData

class LegacyCoreDataStack: Database {
    
    let viewContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    
    private let dataModelName: NSManagedObjectModel
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    private var error: Error?
    
    init(dataModelName: String, at url: URL?) {
        guard let dataModelNameUrl = Bundle.main.url(forResource: dataModelName, withExtension: "momd") else {
            fatalError("Cannot find managed object model (.momd) for URL in bundle.")
        }
        
        self.dataModelName = NSManagedObjectModel(contentsOf: dataModelNameUrl)!
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.dataModelName)
        do {
            try self.persistentStoreCoordinator.addPersistentStore(
                ofType: url == nil ? NSInMemoryStoreType : NSSQLiteStoreType,
                configurationName: nil,
                at: url,
                options: nil
            )
        } catch {
            self.error = error
        }
        
        if let url = url {
            print("\n\nInitialized database at URL:\n\(url)\n\n")
        }
        
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSOverwriteMergePolicy
        backgroundContext.parent = viewContext
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] notification in
                
                if let viewContext = self?.viewContext,
                    let savedContext = notification.object as? NSManagedObjectContext,
                    savedContext.parent == viewContext {
                    
                    viewContext.mergeChanges(fromContextDidSave: notification)
                    self?.save(viewContext)
                }
            }
        )
    }
    
    func load(completion: @escaping (Error?)->()) {
        completion(error)
    }
}
