import Foundation
import CoreData

protocol Database {
    func save(_ context: NSManagedObjectContext)
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
}

protocol DatabaseSelector {
    func database(named databaseName: String?) -> Database
    func add(database: Database, named databaseName: String)
    var defaultDatabase: Database? { get set }
}

class MainDatabaseSelector: DatabaseSelector {
    
    static let shared: DatabaseSelector = MainDatabaseSelector()
    
    private var databasesByName: [String: Database] = [:]
    
    private init() {}
    
    var defaultDatabase: Database?
    
    // MARK: - DatabaseSelector
    
    func database(named databaseName: String?) -> Database {
        if let databaseName = databaseName {
            guard let selectedDatabase = databasesByName[databaseName]else {
                fatalError("Failed to find database named: \(databaseName)")
            }
            return selectedDatabase
        } else if let defaultDatabase = defaultDatabase {
            return defaultDatabase
        } else {
            fatalError("Failed to find default database.")
        }
    }
    
    func add(database: Database, named databaseName: String) {
        databasesByName[databaseName] = database
        defaultDatabase = database
    }
}

extension DatabaseSelector {
    
    static func defaultUrl(forDatabaseNamed name: String) -> URL {
        let docsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsDirectory.appendingPathComponent(name)
    }
}
