import Foundation

public extension Array where Element : NSPredicate {
    
    public func compoundOr() -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: self)
    }
    
    public func compoundAnd() -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: self)
    }
}
