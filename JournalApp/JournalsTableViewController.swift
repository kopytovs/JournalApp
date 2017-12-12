//
//  JournalsTableViewController.swift
//  JournalApp
//
//  Created by Sergey Kopytov on 10.12.2017.
//  Copyright © 2017 Sergey Kopytov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class myCell: UITableViewCell{
    @IBOutlet weak var Timage: UILabel!
    @IBOutlet weak var descr: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var safeView: UIView!
}

class JournalsTableViewController: UITableViewController {
    
    var journalsTitle: [String] = [String]()
    var journalsDescr: [String] = [String]()
    var journalsID: [Int] = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadData(){
        Alamofire.request("\(url)/Journal?select=journal_title,anot,journal_id").responseJSON(completionHandler: {response in
            switch response.result{
            case .success(let value):
                let myJson = JSON(value)
                for index in 0...myJson.count-1{
                    let title = deleteTrash(from: myJson[index]["journal_title"].stringValue)
                    let descr = deleteTrash(from: myJson[index]["anot"].stringValue)
                    let ID = myJson[index]["journal_id"].intValue
                    self.journalsTitle.append(title)
                    self.journalsDescr.append(descr)
                    self.journalsID.append(ID)
                }
                self.tableView.reloadData()
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return journalsTitle.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: myCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! myCell
        
        cell.safeView.layer.cornerRadius = cell.safeView.frame.size.width/32
        cell.Timage.layer.cornerRadius = cell.Timage.frame.size.width/8
        cell.safeView.clipsToBounds = true
        cell.Timage.clipsToBounds = true
        
        let name = self.journalsTitle[indexPath.row]
        cell.name.text = name
        cell.descr.text = self.journalsDescr[indexPath.row]
        let fullName = name.components(separatedBy: " ")
        var imText = ""
        if (fullName.count < 2){
            let temp = fullName[0]
            imText = (String(temp[temp.startIndex])+String(temp[temp.index(after: temp.startIndex)])).uppercased()
        } else {
            let temp = fullName[0]
            let temp2 = fullName[1]
            imText = "\(temp[temp.startIndex])\(temp2[temp2.startIndex])".uppercased()
        }
        cell.Timage.text = imText
        
        cell.Timage.backgroundColor = UIColor(red:0.85, green:0.91, blue:0.99, alpha:1.0)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationController = segue.destination as! JViewController
            destinationController.myID = self.journalsID[indexPath.row]
            destinationController.sData[0] = self.journalsTitle[indexPath.row]
            destinationController.sData[1] = self.journalsDescr[indexPath.row]
            self.tableView.cellForRow(at: indexPath)?.isSelected = false
        }
    }
 

}
