import Foundation
import CoreData
import CovertOps

public class InitializeDatabase: AsyncOperation<Void> {
    
    let managedObjectModelName: String
    let url: URL?
    
    var databaseSelector: DatabaseSelector = MainDatabaseSelector.shared
    
    public init(managedObjectModelName: String, url: URL?) {
        self.managedObjectModelName = managedObjectModelName
        self.url = url
    }
    
    override public func execute() {
        let database: Database
        if #available(iOS 10.0, *) {
            database = PersistentContainerStack(dataModelName: managedObjectModelName, at: url)
        } else {
            database = LegacyCoreDataStack(dataModelName: managedObjectModelName, at: url)
        }
        database.load() { error in
            if let error = error {
                print("Error initializing persistent store: \(error)")
                do {
                    // Delete existing persistent store
                    if let url = self.url {
                        try FileManager.default.removeItem(at: url)
                    }
                    
                    // Attempt to initialize again
                    self.execute()
                } catch {
                    assertionFailure("Failed to delete old database: \(error)")
                    self.cancel()
                }
                
            } else {
                self.databaseSelector.add(database: database, named: self.managedObjectModelName)
                self.finish(output: nil)
            }
        }
    }
}
