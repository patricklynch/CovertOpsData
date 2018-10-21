import Foundation

public protocol IdentifiableObject {
    var id: String? { set get }
    var localId: String? { set get }
}

public extension IdentifiableObject {
    
    public var identifier: Identifier {
        return Identifier(remote: id, local: localId)
    }
}

public struct Identifier: Equatable, Hashable {
    
    struct HashMap<T> {
        private var remote: [String: T] = [:]
        private var local: [String: T] = [:]
        
        subscript(_ identifier: Identifier) -> T? {
            set {
                if let remoteId = identifier.remote {
                    remote[remoteId] = newValue
                }
                if let localId = identifier.local {
                    local[localId] = newValue
                }
            }
            get {
                if let remoteId = identifier.remote,
                    let value = remote[remoteId] {
                    return value
                } else if let localId = identifier.local,
                    let value = local[localId] {
                    return value
                } else {
                    return nil
                }
            }
        }
    }
    
    public var hashValue: Int {
        if let remote = remote {
            return remote.hashValue
        } else if let local = local {
            return local.hashValue
        } else {
            return 0
        }
    }
    
    static func generateLocalId() -> String {
        return NSUUID().uuidString
    }
    
    static func generateLocal(remote: String? = nil) -> Identifier {
        return Identifier(remote: remote, local: Identifier.generateLocalId())
    }
    
    public let remote: String?
    public let local: String?
    
    // MARK: - Equatable
    
    public static func ==(lhs: Identifier, rhs: Identifier) ->  Bool {
        if let lhsRemote = lhs.remote, !lhsRemote.isEmpty, let rhsRmote = rhs.remote, !rhsRmote.isEmpty {
            return lhsRemote == rhsRmote
        } else if let lhsLocal = lhs.local, !lhsLocal.isEmpty , let rhsLocal = rhs.local, !rhsLocal.isEmpty  {
            return lhsLocal == rhsLocal
        } else {
            return false
        }
    }
    
    public func predicate(keyPath: String) -> NSPredicate {
        var predicates: [NSPredicate] = []
        if let localId = local, !localId.isEmpty {
            predicates += [NSPredicate(format: "\(keyPath).localId = %@", localId)]
        }
        if let remoteId = remote, !remoteId.isEmpty {
            predicates += [NSPredicate(format: "\(keyPath).id = %@", remoteId)]
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    public var predicate: NSPredicate {
        var predicates: [NSPredicate] = []
        if let localId = local, !localId.isEmpty {
            predicates += [NSPredicate(format: "localId = %@", localId)]
        }
        if let remoteId = remote, !remoteId.isEmpty {
            predicates += [NSPredicate(format: "id = %@", remoteId)]
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
}
