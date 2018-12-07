//
//  ViewController.swift
//  poe test
//
//  Created by Student Worker Checkout on 9/30/18.
//  Copyright © 2018 t-pope. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

struct item: Decodable {
    //let identified: String//Bool?
    let ilvl: Int//int?
    //let icon: String//url of icon, nice to have
    let typeLine: String//simple enough
    //let frameType: String//2 for rare, so maybe int, idk
    //let category: IDK, need to get the item type through this
    let x: Int//int? X coord
    let y: Int//int? Y coord
    //let inventoryId: String//Could be used to see items from all tabs
    //let category: String
}


//temp for debuggin
struct leagueStruct: Decodable {
    let id: String
    let description: String
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tabl: UITableView!
    @IBOutlet weak var xileLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idSwitch: UISwitch!
    
    @IBOutlet weak var CharName: UITextField!
    @IBOutlet weak var League: UITextField!
    @IBOutlet weak var TabIndex: UITextField!
    
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
    var notHome = 0
    
    
    //PARSE HTML
    //probably not needed anymore
    func parseHtml(html: String) {
        //var tempArray = [String]()
    }
    
    @objc
    func RefreshData(_ control: UIRefreshControl){
        parseJSONandURL()
        self.tabl.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
            control.endRefreshing()
        })
        self.tabl.reloadData()
    }
    
    //MAIN/VIEW LOADER
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        tabl.addSubview(refff)
        
    }
    //MOVE LOGIN ANIMATIONS
    func moveLogin(){
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveLinear, animations: {
            self.xileLabel.center.y -= 25
            self.orLabel.center.x -= 400
            self.CharName.center.x -= 400
            self.SessID.center.x -= 400
            self.League.center.x -= 400
            self.TabIndex.center.x -= 400
            self.SessButton.center.x -= 400
            self.idLabel.center.x -= 400
            self.idSwitch.center.x -= 400
        }, completion: {finished in
           //stop rendering the moved items, since they are offscreen
           self.hideLogin()
        })
        
    }
    //HIDE LOGIN FIELDS
    func hideLogin(){
        orLabel.isHidden = true
        CharName.isHidden = true
        SessID.isHidden = true
        SessButton.isHidden = true
        League.isHidden = true
        TabIndex.isHidden = true
        tabl.isHidden = false
        idLabel.isHidden = true
        idSwitch.isHidden = true
        notHome = 1
        //This should probably be somewhere else
        self.tabl.reloadData()
    }
    
    @IBAction func returnHome(_ sender: Any) {
        if notHome == 0{ return }
        orLabel.isHidden = false
        CharName.isHidden = false
        SessID.isHidden = false
        SessButton.isHidden = false
        League.isHidden = false
        TabIndex.isHidden = false
        tabl.isHidden = true
        idLabel.isHidden = false
        idSwitch.isHidden = false
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveLinear, animations: {
            self.xileLabel.center.y += 25
            self.orLabel.center.x += 400
            self.CharName.center.x += 400
            self.SessID.center.x += 400
            self.League.center.x += 400
            self.TabIndex.center.x += 400
            self.SessButton.center.x += 400
            self.idLabel.center.x += 400
            self.idSwitch.center.x += 400
        }, completion: {finished in
            //stop rendering the moved items, since they are offscreen
        })
    }
    //Parse url, then use session to get and parse json
    func parseJSONandURL(){
        let Char = CharName.text
        let SESS = SessID.text
        let ID = idSwitch.isOn
        var URLLeague = "standard"
        var TabNumber = 1
        if (Char == ""){
            orLabel.text = "Please enter a character name"
            return
        }
        if (SESS == ""){
            orLabel.text = "Please enter a character name"
            return
        }
        if (League.text != ""){
            URLLeague = League.text!
        }
        if (Int(TabIndex.text!) != nil){
            TabNumber = Int(TabIndex.text!)!
        }
        var loginUrl = "https://pathofexile.com/character-window/get-stash-items?league="
        loginUrl += URLLeague + "&tabIndex="
        loginUrl += String(TabNumber) + "&tabs=0&accountName="
        loginUrl += Char!
        print(loginUrl)
        let loginObj = URL(string: loginUrl)
        var request = URLRequest(url:loginObj!)
        request.httpMethod = "POST"
        var sessVal = "POESESSID="
        sessVal += SESS!
        request.setValue(sessVal, forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil{
                    self.JSONParse(data: data, ID: ID)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    
    
    //Parse JSON from above
    func JSONParse(data: Data, ID: Bool){
        //JSON HANDLING WITH SWIFTYJSON
        items.removeAll()
        var WeaponCount = 0
        var RingCount = 0
        var haveAmulet = false
        var haveBody = false
        var haveBoot = false
        var haveGlove = false
        var haveHead = false
        var haveBelt = false
        
        let myJson = try? JSON(data: data)
        var conditionalIter = 0
        
        for currItem in myJson!["items"].arrayValue {
            if(currItem["frameType"].stringValue == "2"//qualifies for set
                && currItem["ilvl"].exists()
                && currItem["ilvl"].intValue >= 60
                && currItem["identified"].exists()
                && (currItem["identified"].stringValue == "false" || !ID)){
                
                //Get category string
                let categoryString = currItem["category"].rawString()
                
                
                //Parse rings, belts and amulets//
                if categoryString!.range(of:"accessories") != nil {
                    if(currItem["category"]["accessories"][0].stringValue=="amulet"
                        && !haveAmulet){
                        print("Amulet!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveAmulet = true
                    }
                    else if(currItem["category"]["accessories"][0].stringValue=="belt"
                        && !haveBelt){
                        print("Belt!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveBelt = true
                    }
                    else if(currItem["category"]["accessories"][0].stringValue=="ring"
                        && RingCount < 2){
                        print("Ring!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        RingCount += 1
                    }
                }
                //Parse armour//
                if categoryString!.range(of:"armour") != nil {
                    if(currItem["category"]["armour"][0].stringValue=="boots"
                        && !haveBoot){
                        print("Boots!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveBoot = true
                    }
                    else if(currItem["category"]["armour"][0].stringValue=="helmet"
                        && !haveHead){
                        print("Helmet!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveHead = true
                    }
                    else if(currItem["category"]["armour"][0].stringValue=="chest"
                        && !haveBody){
                        print("Body!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveBody = true
                    }
                    else if(currItem["category"]["armour"][0].stringValue=="gloves"
                        && !haveGlove){
                        print("Gloves!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveGlove = true
                    }
                    else if(currItem["category"]["armour"][0].stringValue=="gloves"
                        && !haveGlove){
                        print("Gloves!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        haveGlove = true
                    }
                }
                //Parse weapons//
                if categoryString!.range(of:"weapons") != nil {
                    let currWep = currItem["category"]["weapons"][0].stringValue
                    if(currWep == "claw"
                        || currWep == "wand"
                        || currWep == "dagger"
                        || currWep == "onesword"
                        || currWep == "oneaxe"
                        || currWep == "sceptre"
                        || currWep == "onemace"
                        && WeaponCount < 2){
                        print("One Handed!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        WeaponCount += 1
                    }
                    else if(currWep == "twosword"
                        || currWep == "bow"
                        || currWep == "staff"
                        || currWep == "twoaxe"
                        || currWep == "twomace"
                        && WeaponCount < 2){
                        print("Two Handed!")
                        self.items.append(item(ilvl: currItem["ilvl"].intValue,
                                               typeLine: currItem["typeLine"].stringValue,
                                               x: currItem["x"].intValue,
                                               y: currItem["y"].intValue))
                        conditionalIter = conditionalIter + 1
                        WeaponCount += 2
                    }
                }
                
            }
        }
        //do checks here for items not present for a set
        if (WeaponCount < 2){
            //not enough weapons
            self.items.append(item(ilvl: 0,
                                   typeLine: "Not Enough Weapons",
                                   x: -1,
                                   y: -1))
        }
        if (RingCount < 2){
            //not enough rings
            self.items.append(item(ilvl: 0,
                                   typeLine: "Not Enough Rings",
                                   x: -1,
                                   y: -1))
        }
        if haveAmulet == false{
            //need amulet
            self.items.append(item(ilvl: 0,
                                   typeLine: "Need Amulet",
                                   x: -1,
                                   y: -1))
        }
        if haveBody == false{
            //need chest armour
            self.items.append(item(ilvl: 0,
                                   typeLine: "Need Chest",
                                   x: -1,
                                   y: -1))
        }
        if haveBoot == false{
            //need boot
            self.items.append(item(ilvl: 0,
                                   typeLine: "Need Boots",
                                   x: -1,
                                   y: -1))
        }
        if haveGlove == false{
            //need glove
            self.items.append(item(ilvl: 0,
                                   typeLine: "Need Gloves",
                                   x: -1,
                                   y: -1))
        }
        if haveHead == false{
            //need head
            self.items.append(item(ilvl: 0,
                                   typeLine: "Need Helmet",
                                   x: -1,
                                   y: -1))
        }
        if haveBelt == false{
            //need belt
            self.items.append(item(ilvl: 0,
                                   typeLine: "Need Belt",
                                   x: -1,
                                   y: -1))
        }
    }
    
    //SESSION SUBMIT BUTTON
    @IBAction func sessSubmit(_ sender: Any) {
        parseJSONandURL()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.moveLogin()
        })
        
    }
    
    //TABLE VIEW HANDLER, MUST BE REFRESHED TO SHOW DATA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(self.items.count)
    }
    
    //CELL HANDLER
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let rowid = self.items[(items.count-indexPath.row)-1]
        //print(rowid)
        cell.textLabel!.font = UIFont(name:"Fontin", size:22)
        if rowid.x == -1{
            cell.textLabel?.text = rowid.typeLine
            cell.backgroundColor = UIColor.red
            return(cell)
        }
        cell.textLabel?.text = rowid.typeLine + ": " + String(rowid.x) + "," + String(rowid.y)
        return(cell)
    }
    
    
    
    var refff: UIRefreshControl{
        let ref = UIRefreshControl()
        ref.addTarget(self, action: #selector(RefreshData(_:)), for: .valueChanged)
        return ref
    }
    
    
    
    
    
    
}

