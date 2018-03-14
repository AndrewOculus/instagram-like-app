//
//  LoginViewController.swift
//  InstagramLike
//
//  Created by Андрей Лапушкин on 13.03.2018.
//  Copyright © 2018 Андрей Лапушкин. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onPressLogin(_ sender: UIButton) {
        guard emailField.text != "" , passwordField.text != "" else {
            return
        }
        Auth.auth().signIn(withEmail: emailField.text! , password: passwordField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
