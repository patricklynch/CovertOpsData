import Foundation
import CovertOps

class DeleteRemoteTodo: NetworkOperation<NoReply, None> {
    
    init(id: String) {
        super.init(method: .delete, path: "todos/\(id)")
    }
}

class GetRemoteUsers: NetworkOperation<[UserPayload], None> {
    
    init() {
        super.init(method: .get, path: "users")
    }
}

class CreateRemoteTodo: NetworkOperation<None, TodoPostPayload> {
    
    init(payload: TodoPostPayload) {
        super.init(method: .post, path: "todos", body: payload)
    }
}

class GetRemoteTodos: NetworkOperation<[TodoPayload], None> {
    
    init() {
        super.init(method: .get, path: "todos")
    }
}
