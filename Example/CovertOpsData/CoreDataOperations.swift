import Foundation
import CoreData
import CovertOpsData

extension Todo: IdentifiableObject { }

class SaveTodos: DatabaseWriteOperation {
    
    override func write(context: NSManagedObjectContext) {
        guard let networkOutput: NetworkOperationOutput<[TodoPayload]> = outputFromDependency(),
            let todos = networkOutput.data else {
            cancel()
            return
        }
        
        for payload in todos {
            let todo: Todo = context.fetchOrCreate(id: String(payload.id))
            todo.identifier = Identifier.generateLocal(remote: String(payload.id))
            todo.title = payload.title
            todo.isCompleted = payload.completed
            todo.userId = String(payload.userId)
            todo.dateCreated = Date()
        }
        save(context)
    }
}

class ToddleTodoComplete: DatabaseWriteOperation {
    
    let identifier: Identifier
    
    init(identifier: Identifier) {
        self.identifier = identifier
    }
    
    override func write(context: NSManagedObjectContext) {
        guard let todo: Todo = context.fetch(identifier: identifier) else {
            return
        }
        todo.isCompleted = !todo.isCompleted
        save(context)
    }
}

class SyncWithRemote: DatabaseOperation<Void> {
    
    override func execute() {
        let context = database.backgroundContext
        context.perform {
            let predicate = NSPredicate(format: "id = nil && localId != nil")
            let createdTodos: [Todo] = context.fetchAll(predicate: predicate)
            let payloads: [TodoPostPayload] = createdTodos.map { todo in
                return TodoPostPayload(
                    localId: todo.localId ?? "",
                    title: todo.title!,
                    completed: todo.isCompleted
                )
            }
            let operations: [Operation] = payloads.compactMap { payload in
                return CreateRemoteTodo(payload: payload)
            }
            operations.queue() { _ in
                self.finish()
            }
        }
    }
    
}

class CreateTodo: DatabaseWriteOperation {
    let userId: String
    
    private var postPayload: TodoPayload?
    
    init(userId: String) {
        self.userId = userId
    }
    
    override func write(context: NSManagedObjectContext) {
        let count = context.count(of: Todo.self)
        let newTodo: Todo = context.create()
        newTodo.title = "New Todo \(count + 1)"
        newTodo.identifier = Identifier.generateLocal()
        newTodo.isCompleted = false
        newTodo.userId = userId
        newTodo.dateCreated = Date()
        save(context)
    }
}

class DeleteTodo: DatabaseWriteOperation {
    
    let identifier: Identifier
    
    init(identifier: Identifier) {
        self.identifier = identifier
    }
    
    override func write(context: NSManagedObjectContext) {
        guard let todo: Todo = context.fetch(identifier: identifier) else {
            return
        }
        context.delete(todo)
        save(context)
    }
}

class SaveUsers: DatabaseWriteOperation {
    
    override func write(context: NSManagedObjectContext) {
        guard let networkOutput: NetworkOperationOutput<[UserPayload]> = outputFromDependency(),
            let users = networkOutput.data else {
                return
        }
        
        for payload in users {
            let userId = String(payload.id)
            let user: User = context.fetchOrCreate(id: userId)
            user.id = userId
            user.name = payload.name
            user.username = payload.username
            user.email = payload.email
            user.phone = payload.phone
            user.website = payload.website
            
            let predicate = [
                NSPredicate(format: "userId = %@", userId),
                NSPredicate(format: "user.id = %@", userId)
            ].compoundOr()
            let todos: [Todo] = context.fetchAll(predicate: predicate)
            user.todos = NSOrderedSet(array: todos)
        }
        save(context)
    }
}

class FetchAllTodos: DatabaseFetchObjects<Todo> {
    
    let reload: Bool
    
    init(searchTerm: String?, reload: Bool = false) {
        self.reload = reload
        
        let dateSortDescriptor = NSSortDescriptor(key: #keyPath(Todo.dateCreated), ascending: false)
        if let searchTerm = searchTerm {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
            super.init(predicate: predicate, sortDescriptors: [dateSortDescriptor])
        } else {
            super.init(sortDescriptors: [dateSortDescriptor])
        }
    }
    
    override func operationWillStart() {
        guard reload else { return }
        
        [GetRemoteTodos(), SaveTodos()].chained().before(self).queue()
    }
}
