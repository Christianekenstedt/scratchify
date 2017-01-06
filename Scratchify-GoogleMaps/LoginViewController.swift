//
//  LoginViewController.swift
//  Scratchify
//
//  Created by Christian Ekenstedt on 2016-12-13.
//  Copyright © 2016 Christian Ekenstedt. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if (nameField.text?.characters.count)! < 3 {
            errorLabel.text = "Name needs to be at least three characters."
            return
        }
        
        
        if nameField.text != ""{
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "Main View", sender: self)
            })
        }else{
            errorLabel.text = "Please set a name."
        }
    }
}
