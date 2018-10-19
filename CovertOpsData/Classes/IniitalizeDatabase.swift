import Foundation
import CoreData
import CovertOps

public class InitializeDatabase: AsyncOperation<Void> {
    
    let databaseName: String
    let url: URL?
    
    var databaseSelector: DatabaseSelector = MainDatabaseSelector.shared
    
    public init(databaseName: String, url: URL?) {
        self.databaseName = databaseName
        self.url = url
    }
    
    override public func execute() {
        let database: Database
        if #available(iOS 10.0, *) {
            database = PersistentContainerStack(dataModelName: databaseName, at: url)
        } else {
            database = LegacyCoreDataStack(dataModelName: databaseName, at: url)
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
                self.databaseSelector.add(database: database, named: self.databaseName)
                self.finish(output: nil)
            }
        }
    }
}
