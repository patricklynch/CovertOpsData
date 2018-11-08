
import Foundation
import CoreData

public protocol DatabaseSelector {
    func database(named managedObjectModelName: String?) -> Database
    func add(database: Database, named managedObjectModelName: String)
    var defaultDatabase: Database? { get set }
}

public class MainDatabaseSelector: DatabaseSelector {
    
    public static let shared: DatabaseSelector = MainDatabaseSelector()
    
    private var databasesByName: [String: Database] = [:]
    
    private init() {}
    
    public var defaultDatabase: Database?
    
    // MARK: - DatabaseSelector
    
    public func database(named managedObjectModelName: String?) -> Database {
        if let managedObjectModelName = managedObjectModelName {
            guard let selectedDatabase = databasesByName[managedObjectModelName]else {
                fatalError("Failed to find database named: \(managedObjectModelName)")
            }
            return selectedDatabase
        } else if let defaultDatabase = defaultDatabase {
            return defaultDatabase
        } else {
            fatalError("Failed to find default database.")
        }
    }
    
    public func add(database: Database, named managedObjectModelName: String) {
        databasesByName[managedObjectModelName] = database
        defaultDatabase = database
    }
}

public extension DatabaseSelector {
    
    public static func defaultUrl(formanagedObjectModelNamed name: String) -> URL {
        let docsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsDirectory.appendingPathComponent(name)
    }
}
