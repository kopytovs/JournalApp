//
//  JViewController.swift
//  JournalApp
//
//  Created by Sergey Kopytov on 10.12.2017.
//  Copyright © 2017 Sergey Kopytov. All rights reserved.
//

import UIKit
import ExpyTableView
import Alamofire
import SwiftyJSON

class JViewController: UIViewController, ExpyTableViewDelegate, ExpyTableViewDataSource {

    @IBOutlet weak var titleJournal: UILabel!
    @IBOutlet weak var anotJournal: UITextView!
    @IBOutlet weak var tableView: ExpyTableView!
    
    var sData: [String] = ["", ""]
    var myID: Int?
    
    var rubMas = [String]()
    var artMas = [[String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.titleJournal.text = sData[0]
        self.anotJournal.text = sData[1]
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadData(){
        Alamofire.request("\(url)/Rubric?select=rubric_id,rubric_title&journal_id=eq.\(myID!)").responseJSON(completionHandler: {response in
            switch response.result{
            case .success(let value):
                let myJson = JSON(value)
                let temp = myJson[myJson.count-1]["rubric_id"].intValue
                let temp2 = myJson[0]["rubric_id"].intValue
                Alamofire.request("\(url)/Article?select=article_id,article_title,rubric_id&rubric_id=lte.\(temp)&rubric_id=gte.\(temp2)").responseJSON(completionHandler: {response in
                    switch response.result{
                    case .success(let value):
                        let myJson2 = JSON(value)
                        for (_, sub):(String, JSON) in myJson{
                            self.rubMas.append(deleteTrash(from: deleteTrash(from: sub["rubric_title"].stringValue), fromSide: 0))
                        }
                        for index in temp2...temp{
                            let t = [String]()
                            self.artMas.append(t)
                            for (_, sub):(String, JSON) in myJson2{
                                if sub["rubric_id"].intValue == index{
                                    self.artMas[index-temp2].append(deleteTrash(from: sub["article_title"].stringValue))
                                }
                            }
                        }
                        
                        self.tableView.reloadData()
                        break
                    case .failure(let error):
                        print(error)
                    }
                })
                break
            case .failure(let error):
                print(error)
                break
            }
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.rubMas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.artMas[section].count+1
    }
    
    func expandableCell(forSection section: Int, inTableView tableView: ExpyTableView) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "rubricCell")! as UITableViewCell
        cell.backgroundColor = UIColor(red:0.85, green:0.91, blue:0.99, alpha:1.0)
        cell.textLabel?.text = self.rubMas[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.artMas[indexPath.section][indexPath.row-1]
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


