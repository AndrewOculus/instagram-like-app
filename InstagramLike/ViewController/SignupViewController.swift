//
//  SignupViewController.swift
//  
//
//  Created by Андрей Лапушкин on 11.03.2018.
//

import UIKit
import Firebase

class SignupViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var picBtn: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage : StorageReference!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("stop")

        picker.delegate = self

        let storage = Storage.storage().reference(forURL: "gs://instagramlike-80e64.appspot.com")
        userStorage = storage.child("users")
        ref = Database.database().reference()
 
    }
    @IBAction func selectImagePressed(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info [UIImagePickerControllerEditedImage] as? UIImage{
            self.imageView.image = image
            nextBtn.isHidden = false
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        
        guard nameField.text != "", emailField.text != "", passwordField.text != "" , confirmField.text != "" else {return}
        
        if passwordField.text == confirmField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in

                if let error = error {
                    print (error.localizedDescription)
                }
                
                if let user = user {
                    
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    
                    changeRequest.displayName = self.nameField.text!
                    
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print (er?.localizedDescription)
                            }
                            
                            if let url = url {
                                print ("db work")
                                let userInfo : [String:Any] = ["uid":user.uid , "full name":self.nameField.text! ,"urlToImage": url.absoluteURL]
                                
                                //self.ref.child("users").child(user.uid).setValue(userInfo)
                                self.ref.child("users").child(user.uid).setValue(["uid":user.uid,"full name":self.nameField.text!,"urlToImage": String(describing: url.absoluteURL)])

                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                                
                                self.present(vc, animated: true, completion: nil)
                            }
                            
                        })

                    })
                    
                }
                
            })
            
        }else{
            print("Password doesnt match")
        }
        
    }
}
