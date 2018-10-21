import Foundation
import CoreData

public extension NSManagedObjectContext {
    
    public func fetchOrCreate<T: NSManagedObject & IdentifiableObject>(identifier: Identifier) -> T {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = identifier.predicate
        if fetchRequest.predicate != nil,
            let results = try? fetch(fetchRequest),
            let result = results.first {
            return result
        } else {
            var object: T = create()
            object.id = identifier.remote
            object.localId = identifier.local
            return object
        }
    }
    
    public func fetch<T: NSManagedObject & IdentifiableObject>(identifier: Identifier) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = identifier.predicate
        if let results = try? fetch(fetchRequest) {
            return results.first
        }
        return nil
    }
}
