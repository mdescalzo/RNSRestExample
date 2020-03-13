//
//  DetailTableViewController.swift
//  RNSRestExample
//
//  Created by Mark Descalzo on 3/13/20.
//  Copyright © 2020 Ringneck Software, LLC. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var detailItem: EmployeeModel? {
        didSet {
            // Update the view.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard detailItem != nil else {
            return 0
        }
        return EmployeeModel.CodingKeys.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        
        // Configure the cell...
        guard let detailItem = detailItem else {
            return cell
        }
        
        let key = EmployeeModel.CodingKeys.allCases[indexPath.row]
        
        cell.textLabel?.text = key.rawValue
        switch key {
        case .id:
            cell.detailTextLabel?.text = detailItem.id
        case .name:
            cell.detailTextLabel?.text = detailItem.name
        case .salary:
            cell.detailTextLabel?.text = detailItem.salary
        case .age:
            cell.detailTextLabel?.text = detailItem.age
        case .profileImagePath:
            cell.detailTextLabel?.text = detailItem.profileImagePath
        }
        return cell
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
