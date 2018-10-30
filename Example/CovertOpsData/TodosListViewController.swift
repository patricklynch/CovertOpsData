import UIKit
import CovertOps
import CovertOpsData

class TodosListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let databaseName = "Todos"

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    private var currentSearchTerm: String?
    
    private var todos: [Todo] = []
    
    private func updateAll() {
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet([0]), with: .automatic)
        tableView.endUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        todos = todos.existing()
        updateAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url: URL? = MainDatabaseSelector.defaultUrl(forDatabaseNamed: databaseName)
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
            self.updateAll()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTodo = todos[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "TodoDetailViewController") as! TodoDetailViewController
        detailViewController.todo = selectedTodo
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        var subtitle = todo.isCompleted ? "✅" : ""
        if let user = todo.user {
            subtitle.append("Created by \(user.name!)")
        }
        cell.viewData = TodoCell.ViewData(
            title: todo.title?.localizedCapitalized ?? "",
            subtitle: subtitle
        )
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.currentSearchTerm = searchBar.text
        self.refetch(andReload: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.currentSearchTerm = nil
            self.refetch(andReload: false)
        }
    }
}
