//
//  UpdateViewController.swift
//  InstagramLike
//
//  Created by Андрей Лапушкин on 16.03.2018.
//  Copyright © 2018 Андрей Лапушкин. All rights reserved.
//

import UIKit
import Firebase

class UpdateViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate  {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.previewImage.image = image
            selectBtn.isHidden = true
            postBtn.isHidden = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func pressSelect(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func pressPost(_ sender: UIButton) {
        AppDelegate.instance().showActivityIndicator()
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://instagramlike-80e64.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child("uid").child("\(key).jpg")
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        let uploadTask = imageRef.putData(data!, metadata: nil){(metodata , error) in
            if error != nil{
                print(error!.localizedDescription)
                AppDelegate.instance().dismissActivityIndicators()
                return
            }
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url{
                    let feed = ["userID":uid ,
                                "pathToImage": url.absoluteString,
                                "likes": 0 ,
                                "author": Auth.auth().currentUser?.displayName,
                                "postID": key] as [String:Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    AppDelegate.instance().dismissActivityIndicators()

                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        uploadTask.resume()
    }
}
