
import Foundation
import CoreData

public protocol DatabaseSelector {
    func database(named databaseName: String?) -> Database
    func add(database: Database, named databaseName: String)
    var defaultDatabase: Database? { get set }
}

public class MainDatabaseSelector: DatabaseSelector {
    
    public static let shared: DatabaseSelector = MainDatabaseSelector()
    
    private var databasesByName: [String: Database] = [:]
    
    private init() {}
    
    public var defaultDatabase: Database?
    
    // MARK: - DatabaseSelector
    
    public func database(named databaseName: String?) -> Database {
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
    
    public func add(database: Database, named databaseName: String) {
        databasesByName[databaseName] = database
        defaultDatabase = database
    }
}

public extension DatabaseSelector {
    
    public static func defaultUrl(forDatabaseNamed name: String) -> URL {
        let docsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsDirectory.appendingPathComponent(name)
    }
}
