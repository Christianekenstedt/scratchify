//
//  ScratchEngine.swift
//  Scratchify-GoogleMaps
//
//  Created by Christian Ekenstedt on 2017-01-08.
//  Copyright © 2017 Christian Ekenstedt. All rights reserved.
//

import Foundation
import Firebase

class ScratchEngine {
    
    /* Firebase references. */
    
   static func getUserImage(){
        let userId = FIRAuth.auth()?.currentUser?.uid
        let imagesRef: FIRDatabaseReference = FIRDatabase.database().reference().child("images")
    
        imagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var dict = snapshot.value as! Dictionary<String, AnyObject>
            var test : String
            if let test = dict[userId!] as! String! {
                print("DATA \(test.characters.count)")
                //self.initImage(savedImage: )
                let image = convertToImage(from: test);
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateOverlay"), object: nil, userInfo: ["image":image])
                return
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newOverlay"), object: nil)
            }
        })
    }
    
    static func forceSaveImage(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveOverlay"), object: nil)
    }
    
    static func saveUserImage(image: UIImage){
        let userId = FIRAuth.auth()?.currentUser?.uid
        let imagesRef: FIRDatabaseReference = FIRDatabase.database().reference().child("images")
        let userRef = imagesRef.child(userId!)
        userRef.setValue(convertToNSString(from: image))
        print("Image saved.")
    }
   static func convertToNSString(from image : UIImage) -> NSString {
        let imageData = UIImagePNGRepresentation(image)
        let imageString : NSString = imageData!.base64EncodedString(options: .init(rawValue: 0)) as NSString
        return imageString
    }
    
    static func convertToImage(from string: String) -> UIImage{
        let encodedData = string
        let imageData = NSData(base64Encoded: encodedData, options: .init(rawValue: 0))
        return UIImage(data: imageData as! Data)!
    }
}
