import Foundation

extension Array where Element : NSPredicate {
    
    func compoundOr() -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: self)
    }
    
    func compoundAnd() -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: self)
    }
}
