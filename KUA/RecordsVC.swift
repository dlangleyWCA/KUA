//
//  RecordsVC.swift
//  KUA
//
//  Created by Sudip Mishra on 12/1/14.
//  Copyright (c) 2014 Dwayne Langley. All rights reserved.
//

import Foundation
import UIKit

class RecordsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Properties
    var recordsListArray : NSArray = NSArray()
    
    // Kinvey store setup
    var uStore = KCSLinkedAppdataStore(collection: KCSCollection(fromString: "specs", ofClass: specClass.self), options: nil)
 
    // IBOutlets
    @IBOutlet var tableView: UITableView!
    
    
    
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
    }
    
    
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}
    
 //Fetch all data "specs" collection
func fetchData() {
   // var query = KCSQuery(onField: "user", withExactMatchForValue:"User1")//KCSUser.activeUser().username)
    uStore.queryWithQuery( KCSQuery(), withCompletionBlock: { (objects : [AnyObject]!, error : NSError!) -> Void in
            if error != nil {
                println("KUA Error: \(error)")
            }
            else {
                self.recordsListArray = objects
                self.tableView.reloadData()
            }
        }, withProgressBlock: nil)
}

// MARK: - Table view data source

// Return the number of rows in the section.
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.recordsListArray.count
}

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("RecordsCell", forIndexPath: indexPath) as RecordsTableViewCell
    var entity : specClass = self.recordsListArray[indexPath.row] as  specClass
    cell.uWeight!.text = entity.weight;
    cell.uHeight!.text = entity.height;
    cell.uName!.text = entity.user;
    return cell
    }
}

//TableviewCell Class
//class RecordsTableViewCell: UITableViewCell{
//    @IBOutlet var uName: UILabel!
//    @IBOutlet var uWeight: UILabel!
//    @IBOutlet var uHeight: UILabel!
//    @IBOutlet var uEmail: UILabel!
//}
