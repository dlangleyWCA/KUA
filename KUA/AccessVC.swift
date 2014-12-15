//
//  AccessVC.swift
//  KUA
//
//  Created by Dwayne Langley on 11/19/14.
//  Copyright (c) 2014 Dwayne Langley. All rights reserved.
//

import UIKit

class AccessVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Kinvey store setup
    var uStore = KCSLinkedAppdataStore(collection: KCSCollection(fromString: "specs", ofClass: specClass.self), options: nil)
    
    // Properties
    var name = "\(KCSUser.activeUser().givenName) \(KCSUser.activeUser().surname)"
    var attributes = ["username", "email", "height", "weight"]
    var recordsListArray : NSArray = NSArray()
    
    // IBOutlets
    @IBOutlet var tableView: UITableView!
    
    // IBActions
    @IBAction func lougoutPressed(sender: UIButton) {
        KCSUser.activeUser().logout()
        println("DID Logout")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Link tableview delegation to this View Controller
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchData() //from specs collection
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    // Return the number of sections.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    // Return the number of rows in the section.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 4 }
        else {
            return self.recordsListArray.count
        }
    }
    
    //Confure and return table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as UITableViewCell
            
            // Configure the cell...
            cell.textLabel?.text = attributes[indexPath.row].capitalizedString
            
            // Detail Label can only be generically accessed for non-key fields
            switch (indexPath.row) {
            case 0:
                cell.detailTextLabel?.text = KCSUser.activeUser().username
                break
            case 1:
                cell.detailTextLabel?.text = KCSUser.activeUser().email
                break
            default:
                cell.detailTextLabel?.text = (KCSUser.activeUser().getValueForAttribute(attributes[indexPath.row]) as String)
                
                // The next step is to pull data from the "specs" collection instead of the user collection.
                break
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecordsCell", forIndexPath: indexPath) as RecordsTableViewCell
            var entity : specClass = self.recordsListArray[indexPath.row] as specClass
            
            // Configure the cell...
            cell.uWeight!.text = entity.weight;
            cell.uHeight!.text = entity.height;
            cell.uName!.text = entity.user;
           
            return cell
            
        }
    }
    
    // Set Section Titles
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        
        if section == 0 {
            title = "\(KCSUser.activeUser().givenName) \(KCSUser.activeUser().surname)"
        } else {
            title = "Data"
        }
        
        return title
    }
    
    // Set Row Heights
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var height : CGFloat
        
        if indexPath.section == 0 {
            height = 60.0
        }
        else {
            height = 72.0
        }
        
        return height
    }
    
    // Set Actions for Selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            // We can only edit the non-key fields of the Kinvey UserDB
            if indexPath.row > 1 {
                
                // Configure the alert
                var alert = UIAlertController(title: "Edit", message: "New Value", preferredStyle: UIAlertControllerStyle.Alert)
                
                // Configure the textfield for input
                alert.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
                    
                    // TextField Hint for when the field is empty
                    textField.placeholder = "New Value"
                    
                    // Default value is what's already populated
                    textField.text = (KCSUser.activeUser().getValueForAttribute(self.attributes[indexPath.row]) as String)
                }
                
                // Configure the Cancel Button
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                
                // Configure the Save button
                alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                    
                    // Pass the textfield value to the server
                    KCSUser.activeUser().setValue((alert.textFields?.first! as UITextField).text, forAttribute: self.attributes[indexPath.row])
                    
                    // Save the user
                    KCSUser.activeUser().saveWithCompletionBlock({ (NilLiteralConvertible, error : NSError?) -> Void in
                        println("No crash but new value is \((alert.textFields?.first! as UITextField).text)")
                    })
                    
                    // Update the tableview
                    tableView.reloadData()
                }))
                
                // Show the Alert
                self.presentViewController(alert, animated: true, completion: nil)
            }
                
                // Configure alert for uneditable fields
            else {
                var alert = UIAlertController(title: "Restricted", message: "You can not modify key field.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Collection Code
    
    // Fetch all data "specs" collection
    func fetchData() {
        var query = KCSQuery(onField: "user", withExactMatchForValue:KCSUser.activeUser().username)
        uStore.queryWithQuery( /*KCSQuery()*/ query, withCompletionBlock: { (objects : [AnyObject]!, error : NSError!) -> Void in
            if error != nil {
                println("KUA Error: \(error)")
            }
            else {
                self.recordsListArray = objects
                self.tableView.reloadData()
            }
            }, withProgressBlock: nil)
    }
    
    // Specs operations save data unused
    func saveData()  {
        var specs = specClass.alloc()
        specs.weight = "170"
        uStore.saveObject(specs, withCompletionBlock: { (objects : [AnyObject]!, error : NSError!) -> Void in
            if error != nil {
                println("Save failed")
            }
            else{
                println("Save record")
            }
            })
            { ([AnyObject]!, Double) -> Void in
        }
    }
}


// Kinvey reference class
class specClass : NSObject, KCSPersistable {
    var id = "", user = "", height = "", weight = ""
    
    override init() {
        super.init()
    }
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        
        return ["id" : KCSEntityKeyId, "user" : "user", "height" : "height", "weight" : "weight"]
    }
}

//TableviewCell Class
class RecordsTableViewCell: UITableViewCell{
    @IBOutlet var uName: UILabel!
    @IBOutlet var uWeight: UILabel!
    @IBOutlet var uHeight: UILabel!
    @IBOutlet var uEmail: UILabel!
}