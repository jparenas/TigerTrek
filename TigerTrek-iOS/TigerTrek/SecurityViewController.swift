//
//  SecurityViewController.swift
//  TigerTrek
//
//  Created by Juan Pablo Arenas on 5/7/17.
//  Copyright © 2017 Juan Pablo Arenas. All rights reserved.
//

import UIKit
import MapKit

class SecurityViewController: UITableViewController {
    
    //MARK: Properties
    
    var queue = [QueueItem]()
    weak var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(SecurityViewController.updateQueue), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotification(notification:)), name: Notification.Name("update notification"), object: nil)
        
        updateQueue()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Update functions
    
    func updateQueue() {
        NotificationCenter.default.post(name: Notification.Name("update queue"), object: nil, userInfo: nil)
    }
    
    func updateNotification(notification: Notification) {
        let data = notification.userInfo?["data"] as? [[String:String]]
        queue.removeAll()
        for item in data! {
            guard let queueItem = QueueItem(name: item["name"]!, email: item["email"]!, latitude:Double(item["latitude"]!)!,   longitude: Double(item["longitude"]!)!) else {
                fatalError("Unable to instantiate a queue item")
            }
            queue.append(queueItem)
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "QueueTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? QueueTableViewCell  else {
            fatalError("The dequeued cell is not an instance of QueueTableViewCell.")
        }
        
        let queueItem = queue[indexPath.row]
        
        cell.nameLabel.text = queueItem.name
        cell.emailLabel.text = queueItem.email
        cell.showLocation(location: CLLocation(latitude: queueItem.latitude, longitude: queueItem.longitude))

        // Configure the cell...

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "segueToInformation", sender: self)
        
        print("BUTTON PRESSED")
        
        print(self.tableView.indexPathForSelectedRow?.row as Any)
        
        let row = indexPath.row
        print("Row: \(row)")
        
        print(queue[row].name)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToInformation" {
            // Setup new view controller
            
            let vc = segue.destination as! InformationViewController
            vc.information["email"] = queue[(self.tableView.indexPathForSelectedRow?.row)!].email
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
}
