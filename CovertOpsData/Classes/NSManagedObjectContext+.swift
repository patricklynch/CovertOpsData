import Foundation
import CoreData

extension Array where Element : NSManagedObject {
    
    public func deleted() -> [Element] {
        return filter { !$0.existsInContext }
    }
    
    public func existing() -> [Element] {
        return filter { $0.existsInContext }
    }
}

public extension NSManagedObject {
    
    public static var entityName: String {
        return String(describing: self)
    }
    
    public var existsInContext: Bool {
        return managedObjectContext?.object(with: objectID) != nil
    }
}

public extension NSManagedObjectContext {
    
    public func count(of entityType: NSManagedObject.Type, predicate: NSPredicate? = nil) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityType.entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        do {
            return try count(for: fetchRequest)
        } catch {
            assertionFailure("Fetch error: \(error)")
            return 0
        }
    }
    
    public func fetch<T: NSManagedObject>(objectID: NSManagedObjectID) -> T {
        guard let object = object(with: objectID) as? T else {
            fatalError("Failed to fetch object of type \(T.self) by objectID.")
        }
        return object
    }
    
    public func delete(ids: [String], entity: NSManagedObject.Type, idFieldName: String = "id") {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.entityName)
        fetchRequest.predicate = NSPredicate(format: "\(idFieldName) IN %@", ids)
        do {
            if #available(iOS 10.0, *) {
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                let _ = try execute(deleteRequest)
            } else {
                let results = try fetch(fetchRequest)
                for object in results as? [NSManagedObject] ?? [] {
                    delete(object)
                }
            }
        } catch {
            assertionFailure("Failed to delete request: \(error)")
        }
    }
    
    public func fetchAll<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        do {
            return try fetch(fetchRequest)
        } catch {
            assertionFailure("Fetch all error: \(error)")
            return []
        }
    }
    
    public func fetch<T: NSManagedObject>(id: String, idFieldName: String = "id") -> T? {
        return fetch(predicate: NSPredicate(format: "\(idFieldName) = %@", id))
    }
    
    public func fetch<T: NSManagedObject>(predicate: NSPredicate) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: T.entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        do {
            let results = try fetch(fetchRequest)
            return results.first
        } catch {
            assertionFailure("Fetch error: \(error)")
            return nil
        }
    }
    
    public func fetchOrCreate<T: NSManagedObject>(id: String, idFieldName: String = "id") -> T {
        return fetchOrCreate(predicate: NSPredicate(format: "\(idFieldName) = %@", id))
    }
    
    public func fetchOrCreate<T: NSManagedObject>(predicate: NSPredicate) -> T {
        if let existing: T = fetch(predicate: predicate) {
            return existing
        } else {
            return create()
        }
    }
    
    public func create<T: NSManagedObject>() -> T {
        guard let entity = NSEntityDescription.entity(forEntityName: T.entityName, in: self) else {
            fatalError("Could not find entity for name: \(T.entityName).  Make sure the entity name configurated in the managed object object matches the expected type.")
        }
        return NSManagedObject(entity: entity, insertInto: self) as! T
    }
}
