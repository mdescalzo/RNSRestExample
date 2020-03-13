//
//  MasterViewController.swift
//  RNSRestExample
//
//  Created by Mark Descalzo on 3/12/20.
//  Copyright © 2020 Ringneck Software, LLC. All rights reserved.
//

import UIKit
import CoreData

// TODO: Replace with core data implementation

enum State {
    case error
    case empty
    case loading
    case viewing
}

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!

    var state: State = .viewing {
        didSet {
            if state == .loading {
                refreshContent()
            }
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.tableView.reloadData()
                this.configureFooterView()
            }
        }
    }
        
    let networkService = NetworkService()
    
    var detailViewController: DetailTableViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var error: Error? = nil {
        didSet {
            if error != nil {
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else { return }
                    print(this.error!)
                    this.errorLabel.text = "⛔️\n" + this.error!.localizedDescription
                }
                state = .error
            }
        }
    }
    
    var employeeRecords: [EmployeeModel] = []
    
    // TODO: More error view to header position or section 0, row 0
    
    func configureFooterView() {
        switch state {
        case .error:
            self.tableView.tableHeaderView = errorView
        case .empty:
            self.tableView.tableHeaderView = emptyView
        case .viewing:
            self.tableView.tableHeaderView = nil
        case .loading:
            self.tableView.tableHeaderView = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailTableViewController
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if employeeRecords.count == 0 {
            state = .empty
        }
        state = .loading
    }
    
    @objc func handleRefreshControl() {
        state = .loading
    }
    
    func refreshContent() {
        refreshControl?.beginRefreshing()
        networkService.fetchRecords { [weak self] (fetchResult) in
            guard let this = self else { return }
            
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl?.endRefreshing()
                }
            }
            
            guard fetchResult.error == nil else {
                this.error = fetchResult.error
                return
            }
               
            guard let restults = fetchResult.restults else {
                this.state = .empty
                return
            }
            
            this.employeeRecords = restults
            this.state = .viewing
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
//        let context = self.fetchedResultsController.managedObjectContext
//        let newEmployee = Employee(context: context)
//             
//        // If appropriate, configure the new managed object.
//        newEmployee.timestamp = Date()
//
//        // Save the context.
//        do {
//            try context.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = fetchedResultsController.object(at: indexPath)
                let object = self.employeeRecords[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailTableViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
//        return fetchedResultsController.sections?.count ?? 0
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.employeeRecords.count
//        let sectionInfo = fetchedResultsController.sections![section]
//        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let employee = fetchedResultsController.object(at: indexPath)
        let employee = self.employeeRecords[indexPath.row]
        configureCell(cell, withEvent: employee)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent employee: Employee) {
        if let label = cell.textLabel {
            label.text = employee.employee_name
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent employee: EmployeeModel) {
        if let label = cell.textLabel {
            label.text = employee.name
        }
    }


    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Employee> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Employee>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Employee)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Employee)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

