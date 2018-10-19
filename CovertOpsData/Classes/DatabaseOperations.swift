import UIKit
import CovertOps
import CoreData

/// An operation that is configured to select a database by name from one of the initialized
/// databases, or the "default" database if no name is provided and one or more databases
/// have been initialized.
open class DatabaseOperation<OutputType>: AsyncOperation<OutputType> {
    
    lazy var database: Database = {
        return databaseSelector.database(named: self.databaseName)
    }()
    
    private(set) var databaseName: String?
    var databaseSelector: DatabaseSelector = MainDatabaseSelector.shared
    
    init(databaseName: String? = nil) {
        self.databaseName = databaseName
    }
}

/// An operation that executes on a background thread for making changes to some managed object
/// in the persistent store.  The `write(context:)` function shoudl be overidden and include
/// all interactions with the managed object context.  The changes are merged into the main
/// context when `context.save` is called.
open class DatabaseWriteOperation: DatabaseOperation<Void> {
    
    override open func execute() {
        let context = database.backgroundContext
        context.perform {
            self.write(context: context)
            self.finish(output: nil)
        }
    }
    
    func write(context: NSManagedObjectContext) {
        fatalError("Override in subclass")
    }
    
    final func save(_ context: NSManagedObjectContext) {
        database.save(context)
    }
}

/// Defines an object that has produced an array of object IDs to re-fetched again
/// from another context.
protocol FetchedObjectsDependency {
    var objectIds: [NSManagedObjectID]? { get }
}

/// An operation that will fetch managed objects objects corresponding to the provided `objectIds`
/// from the main context of the persistent store.  This is useful for another operations has
/// references to managed objects from another context and wishes to quickly fetch them from
/// the view context in order to be displayed to the user.
open class DatabaseRefetch<T: NSManagedObject>: DatabaseOperation<[T]> {
    
    let objectIds: [NSManagedObjectID]?
    
    init(objectIds: [NSManagedObjectID]? = nil) {
        self.objectIds = objectIds
    }
    
    override open func execute() {
        guard let dependency = dependencies.compactMap({ $0 as? QueueableOperation<[T]> }).first else {
            cancel()
            return
        }
        let objectIds = dependency.output?.map { $0.objectID } ?? []
        guard !objectIds.isEmpty else {
            finish(output: [])
            return
        }
        
        let context: NSManagedObjectContext
        if Thread.isMainThread {
            context = database.viewContext
        } else {
            context = database.backgroundContext
        }
        context.perform {
            self.finish(output: objectIds.compactMap { context.object(with: $0) as? T })
        }
    }
}

/// A command object that performance a synchronous read from a managed object context.
/// The context is automatically selected based on the thread of execution.  When `execute()`
/// is called on the main thread, the view context of the persistent store is selected.  On
/// any other thread, a background child context will be selected.
class DatabaseSyncRead<OutputType> {
    
    lazy var database: Database = {
        return databaseSelector.database(named: self.databaseName)
    }()
    
    private(set) var databaseName: String?
    var databaseSelector: DatabaseSelector = MainDatabaseSelector.shared
    
    init(databaseName: String? = nil) {
        self.databaseName = databaseName
    }
    
    final func execute() -> OutputType {
        let context: NSManagedObjectContext
        if Thread.isMainThread {
            context = database.viewContext
        } else {
            context = database.backgroundContext
        }
        var output: OutputType!
        context.performAndWait {
            output = fetch(context: context)
        }
        return output
    }
    
    func fetch(context: NSManagedObjectContext) -> OutputType {
        fatalError("Override in subclass")
    }
}

open class DatabaseFetchObject<OutputType: NSManagedObject>: DatabaseOperation<OutputType> {
    
    override open func execute() {
        let backgroundContext = database.backgroundContext
        let viewContext = database.viewContext
        backgroundContext.perform {
            guard let object = self.fetch(context: backgroundContext) else {
                self.finish()
                return
            }
            viewContext.perform {
                let refetched = viewContext.object(with: object.objectID) as? OutputType
                self.finish(output: refetched)
            }
        }
    }
    
    func fetch(context: NSManagedObjectContext) -> OutputType? {
        fatalError("Override in subclass")
    }
}

open class DatabaseFetchObjects<OutputType: NSManagedObject>: DatabaseOperation<[OutputType]> {
    
    override open func execute() {
        let backgroundContext = database.backgroundContext
        let viewContext = database.viewContext
        backgroundContext.perform {
            guard let objects = self.fetch(context: backgroundContext) else {
                self.finish()
                return
            }
            viewContext.perform {
                let refetched = objects.compactMap { viewContext.object(with: $0.objectID) as? OutputType }
                self.finish(output: refetched)
            }
        }
    }
    
    func fetch(context: NSManagedObjectContext) -> [OutputType]? {
        fatalError("Override in subclass")
    }
}
