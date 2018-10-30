import UIKit
import CovertOps

class TodoDetailViewController: UIViewController {
    
    private weak var observer: Operation?
    
    var todo: Todo? {
        didSet {
            observer?.cancel()
            observer = Observe(self.todo?.isCompleted).start() { _,_ in
                self.update()
            }.trigger()
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Todo Detail"
        
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        observer?.cancel()
    }
    
    private func update() {
        guard let todo = todo else { return }
        titleLabel.text = todo.title
        subtitleLabel.text = todo.isCompleted ? "Complete" : "Not Complete"
    }
    
    @IBAction func onToggleComplete() {
        guard let todo = todo else { return }
        
        ToddleTodoComplete(identifier: todo.identifier).queue()
    }
    
    @IBAction func onDelete() {
        guard let todo = todo else { return }
        
        DeleteTodo(identifier: todo.identifier).queue() { _,_ in
            self.navigationController?.popViewController(animated: true)
            
            if let remoteId = todo.id {
                DeleteRemoteTodo(id: remoteId).queue()
            }
        }
    }
}
