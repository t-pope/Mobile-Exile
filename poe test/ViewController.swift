//
//  ViewController.swift
//  poe test
//
//  Created by Student Worker Checkout on 9/30/18.
//  Copyright © 2018 t-pope. All rights reserved.
//

import UIKit
import Foundation
import Kanna

struct item: Decodable {
    //let identified: String//Bool?
    let ilvl: String//int?
    //let icon: String//url of icon, nice to have
    let name: String//simple enough
    //let frameType: String//2 for rare, so maybe int, idk
    //let category: IDK, need to get the item type through this
    //let x: String//int? X coord
    //let y: String//int? Y coord
    //let inventoryId: String//Could be used to see items from all tabs
    //let category: Array<Array<String>>
}

struct leagueStruct: Decodable {
    let id: String
    let description: String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tabl: UITableView!
    @IBOutlet weak var xileLabel: UILabel!
    
    @IBOutlet weak var User: UITextField!
    @IBOutlet weak var Pass: UITextField!
    @IBOutlet weak var userbutton: UIButton!
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var SessID: UITextField!
    @IBOutlet weak var SessButton: UIButton!
    var leagues:Array = [leagueStruct]()
    var items:Array = [item]()
    var username: String = "doctorhaxor@gmail.com"
    var password: String = "t0mm0t0mm0t"
    var character: String = "Stumpless"
    var hashVal: String = ""
    let session = URLSession.shared
    //PARSE HTML
    func parseHtml(html: String) {
        var tempArray = [String]()
        
        do{
            if let doc = try? Kanna.HTML(html:html, encoding: String.Encoding.utf8) {
                for name in doc.css("input[name='hash']"){
                    tempArray.append(name["value"]!)
                    print(name["value"]!)
                    hashVal = name["value"]!
                }
            }
        }
    }
    //MAIN/VIEW LOADER
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Above should have the login page session. Need to preserve!
        //let url = "http://api.pathofexile.com/leagues?type=main"
        //let urlObj = URL(string: url)
       /** session.dataTask(with: urlObj!) {(data, response, error) in
        
            do {
                self.leagues = try JSONDecoder().decode([leagueStruct].self, from: data!)
                for league in self.leagues{
                    print(league.id)
                }
                
            } catch {
                print("Error")
            }
        
        }.resume()**/
    }
    //MOVE LOGIN ANIMATIONS
    func moveLogin(){
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveLinear, animations: {
            self.xileLabel.center.y -= 25
            
            self.User.center.x -= 400
            self.Pass.center.x -= 400
            self.userbutton.center.x -= 400
            
            self.orLabel.center.x -= 400
            self.SessID.center.x -= 400
            self.SessButton.center.x -= 400
        }, completion: {finished in
           self.hideLogin()
        })
        
    }
    //HIDE LOGIN FIELDS
    func hideLogin(){
        User.isHidden = true
        Pass.isHidden = true
        userbutton.isHidden = true
        
        orLabel.isHidden = true
        SessID.isHidden = true
        SessButton.isHidden = true
        tabl.isHidden = false
        self.tabl.reloadData()
    }
    
    //SUBMIT BUTTON//
    @IBAction func userSubmit(_ sender: Any) {
        let loginUrl = "http://www.pathofexile.com/login"
        let loginObj = URL(string: loginUrl)
        var request = URLRequest(url: loginObj!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let html = try? String(contentsOf: loginObj!, encoding: .ascii)
        parseHtml(html: html!)
        let html2 = try? String(contentsOf: loginObj!, encoding: .ascii)
        parseHtml(html: html2!)
        let parameters = ["hash":hashVal,
                          "login":          "Login",
                          "login_email":    "EMAIL",
                          "login_password": "PASS",
                          "remember_me":    "0"]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error{
            print(error.localizedDescription)
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                    print(json)
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
        moveLogin()
        self.tabl.reloadData()
        self.tabl.reloadData()
        self.tabl.reloadData()
    }
    //SESSION SUBMIT BUTTON
    @IBAction func sessSubmit(_ sender: Any) {
        let loginUrl = "https://pathofexile.com/character-window/get-stash-items?league=Delve&tabIndex=1&tabs=0&accountName=stumpless"
        let loginObj = URL(string: loginUrl)
        var request = URLRequest(url:loginObj!)
        request.httpMethod = "POST"
        request.setValue("POESESSID=22cf3ef1962ff6f69051a8883dc66391", forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                    print(json)
                    do {
                        self.items = try JSONDecoder().decode([item].self, from: data)
                        for item in self.items{
                            print(item.name)
                        }
                        
                    } catch {
                        print("Error ERR RRRERWERA AEWSRAWER")
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        moveLogin()
    }
    
    //TABLE VIEW HANDLER, MUST BE REFRESHED TO SHOW DATA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(self.items.count)
    }
    
    //CELL HANDLER
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let rowid = self.items[indexPath.row]
        print(rowid)
        cell.textLabel?.text = rowid.name + ": " + rowid.ilvl
        return(cell)
    }
}

