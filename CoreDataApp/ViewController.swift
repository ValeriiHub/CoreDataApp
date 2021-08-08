//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Valerii D on 17.07.2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"                  // - идентификатор ячейки
    private var tasks: [Task] = []
    
    // managed object contex
    private let managedContex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext  // добираемся до AppDelegate, а затем до persistentContainer и его свойства viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Table view cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    // setupView
    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    // setupNavigationBar
    private func setupNavigationBar() {
        
        // srt title for Navigation bar
        title = "Track list"
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // UINavigationBarAppearance()
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        
        // Title color
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        navBarAppearence.titleTextAttributes = [.foregroundColor : UIColor.white]

        // NavigationBar color
        navBarAppearence.backgroundColor = UIColor(red: 21/255,
                                                   green: 101/255,
                                                   blue: 192/255,
                                                   alpha: 194/255)
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence


        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewTask))
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "What do you want to do?")
    }
    
    private func fetchData() {
        // запрос выборки из базы всех значений по ключу Task
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            tasks = try managedContex.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }

            // Add new task to tasks array
            self.save(task)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        // entity name
        guard let entityDescroption = NSEntityDescription.entity(forEntityName: "Task", in: managedContex) else { return }
        
        // Model instance
        let task = NSManagedObject(entity: entityDescroption, insertInto: managedContex) as! Task
        
        task.name = taskName
        
        if managedContex.hasChanges {
            do {
                try managedContex.save()
                
                tasks.append(task)
                
                let cellIndex = IndexPath(row: self.tasks.count - 1, section: 0)
                self.tableView.insertRows(at: [cellIndex], with: .automatic)                // обновляет в таблице только указанные ряды
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name

        return cell
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        managedContex.delete(tasks[indexPath.row])
        
        do {
            try managedContex.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
