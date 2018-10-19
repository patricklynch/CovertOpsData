import Foundation

public extension NSOrderedSet {
    
    public func orderedSet(appending objects: [Any]) -> NSOrderedSet {
        let set = NSMutableOrderedSet(orderedSet: self)
        let total = set.count + objects.count
        set.insert(objects, at: IndexSet(integersIn: set.count..<total))
        return NSOrderedSet(orderedSet: set)
    }
    
    public func orderedSet(removing objects: [Any]) -> NSOrderedSet {
        let set = NSMutableOrderedSet(orderedSet: self)
        set.removeObjects(in: objects)
        return NSOrderedSet(orderedSet: set)
    }
    
    public func orderedSet(removingAt index: Int) -> NSOrderedSet {
        let set = NSMutableOrderedSet(orderedSet: self)
        set.removeObject(at: index)
        return NSOrderedSet(orderedSet: set)
    }
    
    public func orderedSet(replacingAt index: Int, with object: Any) -> NSOrderedSet {
        let set = NSMutableOrderedSet(orderedSet: self)
        set.replaceObject(at: index, with: object)
        return NSOrderedSet(orderedSet: set)
    }
}
