import UIKit
import CovertOps
import CovertOpsData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    private var currentSearchTerm: String?
    
    private var todos: [Todo] = [] {
        didSet {
            self.updateAll()
        }
    }
    
    private func updateAll() {
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet([0]), with: .automatic)
        tableView.endUpdates()
    }
    
    private func update(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseName = "Todos"
        let url: URL? = nil // = MainDatabaseSelector.defaultUrl(forDatabaseNamed: databaseName)
        InitializeDatabase(databaseName: databaseName, url: url).queue() { _,_ in
            self.refetch(andReload: false)
            
            // Side load users and save in persistent store:
            let operations = [
                Wait(duration: 1.0),
                NetworkOperation<[UserPayload]>(apiPath: "users"),
                SaveUsers()
            ]
            operations.chained().queue() { _ in
                self.updateAll()
            }
        }
    }
    
    private func refetch(andReload reload: Bool) {
        FetchAllTodos(searchTerm: currentSearchTerm, reload: reload).queue() { _, todos in
            self.todos = todos ?? []
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTodo = todos[indexPath.row]
        CompleteTodo(id: selectedTodo.id).queue() { _,_ in
            self.update(at: indexPath)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        let subtitle: String?
        if let user = todo.user {
            subtitle = "Created by \(user.name!)"
        } else {
            subtitle = nil
        }
        cell.viewData = TodoCell.ViewData(
            title: todo.title?.localizedCapitalized ?? "",
            textColor: todo.isCompleted ? .black : .gray,
            subtitle: subtitle
        )
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.currentSearchTerm = searchBar.text
        self.refetch(andReload: false)
    }
}
