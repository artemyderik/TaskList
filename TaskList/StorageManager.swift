//
//  StorageManager.swift
//  TaskList
//
//  Created by Артемий Дериглазов on 17.08.2023.
//
import CoreData

class StorageManager {
    // MARK: - Singleton
    static let shared = StorageManager()
    private init() {}
    
    // MARK: - Core Data Stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var viewContext = persistentContainer.viewContext

    //MARK: Task Management
    func addNewTask(completion: (Result<Task, Error>) -> Void) {
        let task = Task(context: viewContext)
        completion(.success(task))

        saveContext()
    }

    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
            let taskList = try viewContext.fetch(fetchRequest)
            completion(.success(taskList))
        } catch {
            completion(.failure(error))
        }
    }
    
    //MARK: Saving Context
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: Task Manipulation
    func deleteTask(with task: Task) {
        guard let _ = try? viewContext.existingObject(with: task.objectID) as? Task else { return }
        viewContext.delete(task)
            saveContext()
    }
    
    func renameTask(with task: Task, newName: String) {
        task.title = newName
        saveContext()
    }
}
