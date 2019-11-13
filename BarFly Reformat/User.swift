//
//  User.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 10/31/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct User {
    var uid:String?
    var name:String?
    var username: String?
    var bar:String?
    var admin:Bool?
    var email: String?
    var friends: [String?]
    var requests: [String?]
    var profileURL: String?
    
    static func updateUser(uid: String) -> User? {
        
        var user: User?
        
        let firestore = Firestore.firestore()
        let userRef = firestore.collection(LoginVC.USER_DATABASE)
        let docRef = userRef.document("\(uid)")
        docRef.getDocument { (document, error) in
                
            if(error == nil) {
    
                let name = ((document!.get("name")) as! String)
                let username = ((document!.get("username")) as! String)
                let bar = ((document!.get("bar")) as! String)
                let admin = ((document!.get("admin")) as! Bool)
                let friends = ((document!.get("friends")) as! [String])
                let requests = ((document!.get("requests")) as! [String])
                let profileURL  = ((document!.get("profileURL")) as? String  ?? "")
                let email = ((document!.get("email")) as? String  ?? "")
                user = User(uid: uid, name: name, username: username, bar: bar, admin: admin, email: email, friends: friends, requests: requests, profileURL: profileURL)
                    
            }
                
        }
        
        return user
        
    }
    
}


