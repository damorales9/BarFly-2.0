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
    var timestamp: NSNumber?
    var admin:Bool?
    var email: String?
    var friends: [String?]
    var requests: [String?]
    var profileURL: String?
    
    static func getUser(uid: String, setFunction: @escaping (_ user: inout User?) -> Void) {
        
        var user: User?
        
        let firestore = Firestore.firestore()
        let userRef = firestore.collection(LoginVC.USER_DATABASE)
        let docRef = userRef.document("\(uid)")
        docRef.getDocument { (document, error) in
                
            if(error == nil) {
    
                let name = ((document!.get("name")) as! String)
                let username = ((document!.get("username")) as! String)
                let bar = ((document!.get("bar")) as! String)
                let timestamp = ((document!.get("timestamp")) ?? 0) as! NSNumber
                let admin = ((document!.get("admin")) as! Bool)
                let friends = ((document!.get("friends")) as! [String])
                let requests = ((document!.get("requests")) as! [String])
                let profileURL  = ((document!.get("profileURL")) as? String  ?? "")
                let email = ((document!.get("email")) as? String  ?? "")
                
                user = User(uid: uid, name: name, username: username, bar: bar, timestamp: timestamp, admin: admin, email: email, friends: friends, requests: requests, profileURL: profileURL)
                
                setFunction(&user)
                
            }
                
        }
    }
        
    
    static func updateUser(user: User?) {
        
        if let user = user {
        
            let docData: [String: Any] = [
                "uid" : user.uid!,
                "name": user.name ?? "nil",
                "bar" : user.bar ?? "nil",
                "username" : user.username!,
                "admin" : user.admin ?? false,
                "profileURL": user.profileURL ?? "",
                "email": user.email!,
                "friends": user.friends,
                "timestamp": user.timestamp ??  0,
                "requests":user.requests
            ]

            Firestore.firestore().collection(LoginVC.USER_DATABASE).document(user.uid!).setData(docData) {err in
                //TODO handle error
            }
            
        }
        
    }
    
    
    
}


