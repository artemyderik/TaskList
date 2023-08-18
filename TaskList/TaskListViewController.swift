//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    //MARK: Private Properties
    private let cellID = "task"
    private var taskList: [Task] = []
    
    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    //MARK: Private Methods
    private func addNewTaskButtonTapped() {
        showAlert(withTitle: "Add New Task", message: "What do you want to do?", placeholder: "New task")
    }

    private func showAlert(
        withTitle: String,
        message: String,
        placeholder: String,
        editingTask: Task? = nil,
        indexPath: IndexPath? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if editingTask != nil {
            let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
                guard let renamedTask = alert.textFields?.first?.text, !renamedTask.isEmpty else { return }
                guard let indexPath = indexPath else { return }
                guard let editingTask = editingTask else { return }
                
                StorageManager.shared.renameTask(with: taskList[indexPath.row], newName: renamedTask)
                taskList[indexPath.row] = editingTask
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            alert.addAction(saveAction)
        }
        
        else {
            let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self?.addNewTask(task)
            }
            
            alert.addAction(saveAction)
        }
        
        alert.addAction(cancelAction)
        alert.addTextField { textField in
                textField.placeholder = placeholder
        }
        
        if editingTask != nil {
            alert.textFields?.first?.text = editingTask?.title
            guard let renamedTask = alert.textFields?.first?.text, !renamedTask.isEmpty else { return }
        }
        
        present(alert, animated: true)
    }
    
    private func showDeleteAlert(withTask task: String, indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "Do you want to delete forever \"\(task)\" task?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            StorageManager.shared.deleteTask(with: taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
}

// MARK: Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTaskButtonTapped()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

//MARK: UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteAlert(withTask: taskList[indexPath.row].title ?? "", indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(
            withTitle: "Rename the Task",
            message: "What do you want to do?",
            placeholder: "Enter new name",
            editingTask: taskList[indexPath.row],
            indexPath: indexPath
        )
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: CoreData Methods
extension TaskListViewController {
     private func fetchData() {
         StorageManager.shared.fetchData { result in
             switch result {
             case .success(let loadedTaskList):
                 taskList = loadedTaskList
             case .failure(let error):
                 print(error.localizedDescription)
             }
         }
     }

     private func addNewTask(_ taskName: String) {
         StorageManager.shared.addNewTask() { result in
             switch result {
             case .success(let task):
                 task.title = taskName
                 taskList.append(task)
             case .failure(let error):
                 print(error.localizedDescription)
             }
         }

         let indexPath = IndexPath(row: taskList.count - 1, section: 0)
         tableView.insertRows(at: [indexPath], with: .automatic)
     }
}
