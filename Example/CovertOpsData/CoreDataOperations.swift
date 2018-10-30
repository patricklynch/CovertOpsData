import Foundation
import CoreData
import CovertOpsData

class SaveTodos: DatabaseWriteOperation {
    
    override func write(context: NSManagedObjectContext) {
        guard let networkOutput: NetworkOperationOutput<[TodoPayload]> = outputFromDependency(),
            let todos = networkOutput.data else {
            cancel()
            return
        }
        
        for payload in todos {
            let todo: Todo = context.fetchOrCreate(id: String(payload.id))
            todo.id = Int64(payload.id)
            todo.title = payload.title
            todo.isCompleted = payload.completed
            todo.userId = Int64(payload.userId)
        }
        save(context)
    }
}

class ToddleTodoComplete: DatabaseWriteOperation {
    
    let id: Int64
    
    init(id: Int64) {
        self.id = id
    }
    
    override func write(context: NSManagedObjectContext) {
        guard let todo: Todo = context.fetch(id: String(id)) else {
            return
        }
        todo.isCompleted = !todo.isCompleted
        save(context)
    }
}

class DeleteTodo: DatabaseWriteOperation {
    
    let id: Int64
    
    init(id: Int64) {
        self.id = id
    }
    
    override func write(context: NSManagedObjectContext) {
        guard let todo: Todo = context.fetch(id: String(id)) else {
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
            let user: User = context.fetchOrCreate(id: String(payload.id))
            user.id = Int64(payload.id)
            user.name = payload.name
            user.username = payload.username
            user.email = payload.email
            user.phone = payload.phone
            user.website = payload.website
            
            let predicate = NSPredicate(format: "userId = %i", user.id)
            let todos: [Todo] = context.fetchAll(predicate: predicate)
            user.todos = NSOrderedSet(array: todos)
        }
        save(context)
    }
}

class FetchAllTodos: DatabaseFetchObjects<Todo> {
    
    let reload: Bool
    let searchTerm: String?
    
    init(searchTerm: String?, reload: Bool = false) {
        self.searchTerm = searchTerm
        self.reload = reload
    }
    
    override func operationWillStart() {
        [NetworkOperation<[TodoPayload]>(apiPath: "todos"), SaveTodos()].chained().before(self).queue()
    }
    
    override func fetch(context: NSManagedObjectContext) -> [Todo]? {
        if let searchTerm = searchTerm {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
            return context.fetchAll(predicate: predicate, sortDescriptors: [])
        } else {
            return context.fetchAll()
        }
    }
}
