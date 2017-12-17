//
//  ArticleViewController.swift
//  JournalApp
//
//  Created by Sergey Kopytov on 12.12.2017.
//  Copyright © 2017 Sergey Kopytov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SimplePDF
import PMSuperButton
import DynamicColor

class ArticleViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var articleText: UITextView!
    @IBOutlet weak var autorsLabel: UILabel!
    @IBOutlet weak var generateButton: PMSuperButton!
    
    struct autor{
        var name = String()
        var surname = String()
        var degree = String()
        var org = String()
        
        init(name value1: String, surname value2: String, degree value3: String, org value4: String){
            name=value1
            surname=value2
            degree=value3
            org=value4
        }
    }
    
    var parametres: Dictionary<String, Any> = Dictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadData()
        self.nameLabel.text = parametres["article_title"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadData(){
        Alamofire.request("\(url)/Article?select=article_annot&article_id=eq.\(self.parametres["article_id"] as! Int)").responseJSON(completionHandler: {response in
            switch response.result{
            case .success(let value):
                let myJson = JSON(value)
                self.articleText.text = myJson[0]["article_annot"].stringValue
                self.parametres["article_annot"] = myJson[0]["article_annot"].stringValue
                Alamofire.request("\(url)/Autors?select=surname,name,degree,org&article_id=eq.\(self.parametres["article_id"] as! Int)").responseJSON(completionHandler: {response in
                    switch response.result{
                    case .success(let value):
                        let myJson2 = JSON(value)
                        var tempMas = [autor]()
                        for (_, sub):(String, JSON) in myJson2{
                            let myAutor = autor(name: sub["name"].stringValue, surname: sub["surname"].stringValue, degree: sub["degree"].stringValue, org: sub["org"].stringValue)
                            tempMas.append(myAutor)
                        }
                        self.parametres["autors"] = tempMas
                        var tempString = ""
                        for aut in tempMas{
                            tempString+=aut.surname+" "+aut.name+", "
                        }
                        tempString.remove(at: tempString.index(before: tempString.endIndex))
                        tempString.remove(at: tempString.index(before: tempString.endIndex))
                        //print(myJson[0]["article_annot"].stringValue)
                        DispatchQueue.main.async {
                            self.autorsLabel.text = tempString
                            self.articleText.text = myJson[0]["article_annot"].stringValue
                        }
                        //self.autorsLabel.text = tempString
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
        self.generateButton.titleLabel?.textColor = DynamicColor(red:0.33, green:0.51, blue:0.79, alpha:1.0)
//        self.generateButton.layer.cornerRadius = self.generateButton.frame.width/32
//        self.generateButton.clipsToBounds = true
    }
    
    private func gen() -> Data{
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize)
        pdf.setContentAlignment(.center)
        pdf.addText("\(parametres["article_title"]!)")
        pdf.addLineSpace(30)
        pdf.setContentAlignment(.center)
        var dataArr = [[String]]()
        let temp = parametres["autors"] as! [autor]
        for smth in temp{
            var mas = [String]()
            mas.append(smth.surname)
            mas.append(smth.name)
            mas.append(smth.degree)
            mas.append(smth.org)
            dataArr.append(mas)
        }
        let tableDef = TableDefinition(alignments: [.center, .center, .center, .center],
                                       columnWidths: [150, 150, 100, 100],
                                       fonts: [UIFont.systemFont(ofSize: 16),
                                               UIFont.systemFont(ofSize: 16), UIFont.systemFont(ofSize: 14), UIFont.systemFont(ofSize: 14)],
                                       textColors: [UIColor.black,
                                                    UIColor.black, UIColor.black, UIColor.black])
        pdf.addTable(dataArr.count, columnCount: dataArr[0].count, rowHeight: 20, tableLineWidth: 1, tableDefinition: tableDef, dataArray: dataArr)
        pdf.addLineSpace(30)
        pdf.setContentAlignment(.left)
        pdf.addText("\t\(self.parametres["article_annot"]!)")
        self.generateButton.showLoader(userInteraction: false)
        let pdfData = pdf.generatePDFdata()
        return pdfData
    }
    
    @IBAction func generate(_ sender: Any) {
        let pdfData = self.gen()
        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(activityVC, animated: true, completion: {
            self.generateButton.hideLoader()
        })
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
