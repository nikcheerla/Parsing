//
//  LoginViewController.swift
//  Parsing
//
//  Created by Nikhil Cheerla on 1/1/15.
//  Copyright (c) 2015 Haxors. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var SignUpUserText: UITextField!
    @IBOutlet weak var SignUpPassText: UITextField!
    @IBOutlet weak var SignUpPass2Text: UITextField!
    @IBOutlet weak var LoginUserText: UITextField!
    @IBOutlet weak var LoginPassText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func SignUpClicked(sender: AnyObject) {
        print("thing");
        if(SignUpUserText.text==""||SignUpPassText.text==""||SignUpPass2Text.text==""||(SignUpPassText.text != SignUpPass2Text.text))
        {
            println("error signing up");
        }
        else{
            
            var user = PFUser()
            user.username = SignUpUserText.text
            user.password = SignUpPassText.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool!, error: NSError!) -> Void in
                if error == nil {
                    print("Sign In Succeeded");
                } else {
                    print("parse signing up error");
                }
            }
        self.performSegueWithIdentifier("loginView", sender: self)
        }
    }
    
   
    @IBAction func LoginClicked(sender: UIButton) {
        if(LoginUserText.text != ""&&LoginPassText.text != ""){
            PFUser.logInWithUsernameInBackground(LoginUserText.text, password:LoginPassText.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    self.performSegueWithIdentifier("loginView", sender: self)
                    // Do stuff after successful login.
                } else {
                    // The login failed. Check error to see why.
                }
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
