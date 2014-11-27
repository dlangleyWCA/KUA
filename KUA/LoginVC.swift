//
//  LoginVC.swift
//  KUA
//
//  Created by Dwayne Langley on 11/19/14.
//  Copyright (c) 2014 Dwayne Langley. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // IBOutlets
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    // Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        if (KCSUser.activeUser() != nil) {
            println("Current User = \(KCSUser.activeUser().surname)")
            self.performSegueWithIdentifier("aSegue", sender: self)
        }
        else {
            println("There is no active User")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // IBActions
    @IBAction func submitPressed(sender: UIButton) {
        
        // Attempt Login with Provided Credentials from Texfields
        KCSUser.loginWithUsername(usernameField.text, password: passwordField.text) { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
            
            // Successful Login
            if (errorOrNil == nil) {
                self.performSegueWithIdentifier("aSegue", sender: self)
            }
                
                // Unsuccessful Login
            else {
                let alertAction = { (action:UIAlertAction!) -> Void in
                    println("\n \n \(errorOrNil.localizedDescription).  Login Again \n \n")
                }
                
                var alert = UIAlertController(title: "Login Error", message:errorOrNil.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: alertAction))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func newUserPressed(sender: AnyObject) {
        // Temporary store for New User variables
        var uName = "NA", uPwd = "NA", uEmail = "NA", uFirst = "NA", uLast = "NA", uHeight = "NA", uWeight = "NA"
        
        
        // Create New User
        var alert = UIAlertController(title: "New User", message:"Create New User", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "username"
        }
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "password"
        }
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Email Address"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            
            // Store the entered values
            uName = (alert.textFields?[0] as UITextField).text
            uPwd = (alert.textFields?[1] as UITextField).text
            uEmail = (alert.textFields?[2] as UITextField).text
            
            var alert = UIAlertController(title: "User Details", message:"Enter Info", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "First Name"
            }
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Last Name"
            }
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Height"
            }
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Weight"
            }
            alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
                
                // Store the entered values
                uFirst = (alert.textFields?[0] as UITextField).text
                uLast = (alert.textFields?[1] as UITextField).text
                uHeight = (alert.textFields?[2] as UITextField).text
                uWeight = "\((alert.textFields?[3] as UITextField).text) lbs"
                
                // Create the new user
                KCSUser.userWithUsername(uName, password: uPwd, fieldsAndValues: [KCSUserAttributeEmail : uEmail, KCSUserAttributeGivenname : uFirst, KCSUserAttributeSurname : uLast, "height" : uHeight, "weight" : uWeight], withCompletionBlock: { (newUser : KCSUser!, errorOrNil : NSError!, result : KCSUserActionResult) -> Void in
                    if errorOrNil != nil {
                        println("Error: \(errorOrNil)")
                    }
                    else {
                        if (KCSUser.activeUser() != nil) {
                            println("Current User = \(KCSUser.activeUser().surname)")
                            self.performSegueWithIdentifier("aSegue", sender: self)
                        }
                        else {
                            println("There is no active User")
                        }
                    }
                    
                })
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK : UITextField Logic
    
    // Get rid of the keyboard on return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // Get rid of the keyboard on deselection of the textfield
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if !(event.allTouches()?.anyObject() as UITouch).view.isKindOfClass(UITextField) {
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()
        }
    }
    
    
    // MARK: - Navigation
    
    // Preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(AccessVC) {
            
            // Get the new view controller using segue.destinationViewController.
            var nextVC : AccessVC = segue.destinationViewController as AccessVC
            
            // Pass a value/message to the nextVC.
            nextVC.name = "\(KCSUser.activeUser().givenName) \(KCSUser.activeUser().surname)"
            // The value for nextVC.name is currently not even being used because the nextVC pulls the value directly from the Kinvey SDK.
        }
    }
}
