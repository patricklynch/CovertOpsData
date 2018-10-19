import Foundation
import CoreData

public protocol Database {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func load(completion: @escaping (Error?)->())
}

public extension Database {
    
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

