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
    
    static var LOOKING = "looking for someone"
    static var SINGLE = "single"
    static var RELATIONSHIP = "in a relationship"
    static var FRIENDS = "just out with friends"
    static var COMPLICATED = "complicated"
    static var JEALOUS = "trying to make them jealous"
    static var NIL = "eating ice cream in their pjs"
    static var SEXILED = "probably gonna get sexiled"
    static var CLAM = "free clammin It"
    static var POPPIN = "poppin bottles"
    static var JESUS = "calling jesus on the porcelin telephone"
    static var MOMS = "looking for single moms"
    static var WIZARD = "playing wizard staff"
    static var DRINKING = "drinking"


    
    
    var uid:String?
    var name:String?
    var username: String?
    var bar:String?
    var timestamp: NSNumber?
    var admin: Bool?
    var email: String?
    var friends: [String?]
    var followers: [String?]
    var blocked: [String?]
    var requests: [String?]
    var pregames: [String?]
    var favorites: [String?]
    var profileURL: String?
    var galleryURLs: [String?]
    var messagingID: String?
    var profileImage: UIImage?
    var galleryImages: [UIImage]?
    var status: String?

    
    static func getUser(uid: String, setFunction: @escaping (_ user: User?) -> Void) {
        
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
                let friends = ((document!.get("friends")) as? [String] ?? [String]())
                let requests = ((document!.get("requests")) as? [String] ?? [String]())
                let favorites = ((document!.get("favorites")) as? [String] ?? [String]())
                let followers = ((document!.get("followers")) as? [String] ?? [String]())
                let pregames = ((document!.get("pregames")) as? [String] ?? [String]())
                let blocked = ((document!.get("blocked")) as? [String] ?? [String]())
                let profileURL  = ((document!.get("profileURL")) as? String  ?? "")
                let galleryURLs = ((document!.get("galleryURLs")) as? [String] ?? [String]())
                let email = ((document!.get("email")) as? String  ?? "")
                let msgID = ((document!.get("messagingID")) as? String ?? "")
                let status = ((document!.get("status")) as? String ?? User.NIL)
                
                user = User(uid: uid, name: name, username: username, bar: bar, timestamp: timestamp, admin: admin, email: email, friends: friends, followers: followers, blocked: blocked, requests: requests, pregames: pregames, favorites: favorites, profileURL: profileURL, galleryURLs: galleryURLs, messagingID: msgID, status: status)
                
//                UIImageView.downloadImage(from: URL(string: user!.profileURL!)!, completion: { (image) in
//                    user?.profileImage = image
//
//                    var x = 0
//                    for i in user!.galleryURLs {
//
//                        UIImageView.downloadImage(from: URL(string: i!)!, completion: { (image) in
//                            user?.galleryImages?.append(image)
//                            x+=1
//
//                            if x == user!.galleryURLs.count {
//                                setFunction(user)
//                            }
//                        }) {
//                            print("this image twas fucked")
//                            x+=1
//
//                            if x == user!.galleryURLs.count {
//                                setFunction(user)
//                            }
//                        }
//                    }
//                }) {
//                    setFunction(user)
//                }
//
                setFunction(user)
               
                
            }
                
        }
    }
    
    static func getUserInfo(uid: String, setFunction: @escaping (_ user: User?) -> Void) {
            
            var user: User?
            
            let firestore = Firestore.firestore()
            let userRef = firestore.collection("User Info")
            let docRef = userRef.document("\(uid)")
            docRef.getDocument { (document, error) in
                    
                if(error == nil) {
        
                    let name = ((document!.get("name")) as! String)
                    let username = ((document!.get("username")) as! String)
                    let bar = ((document!.get("bar")) as! String)
                    let timestamp = ((document!.get("timestamp")) ?? 0) as! NSNumber
                    let admin = ((document!.get("admin")) as! Bool)
                    let friends = ((document!.get("friends")) as? [String] ?? [String]())
                    let requests = ((document!.get("requests")) as? [String] ?? [String]())
                    let pregames = ((document!.get("pregames")) as? [String] ?? [String]())
                    let favorites = ((document!.get("favorites")) as? [String] ?? [String]())
                    let followers = ((document!.get("followers")) as? [String] ?? [String]())
                    let blocked = ((document!.get("blocked")) as? [String] ?? [String]())
                    let profileURL  = ((document!.get("profileURL")) as? String  ?? "")
                    let galleryURLs = ((document!.get("galleryURLs")) as? [String] ?? [String]())
                    let email = ((document!.get("email")) as? String  ?? "")
                    let msgID = ((document!.get("messagingID")) as? String ?? "")
                    let status =  ((document!.get("status")) as? String ?? User.NIL)
                    
                    user = User(uid: uid, name: name, username: username, bar: bar, timestamp: timestamp, admin: admin, email: email, friends: friends, followers: followers, blocked: blocked, requests: requests, pregames: pregames, favorites: favorites, profileURL: profileURL, galleryURLs: galleryURLs, messagingID: msgID, status: status)
                    
    //                UIImageView.downloadImage(from: URL(string: user!.profileURL!)!, completion: { (image) in
    //                    user?.profileImage = image
    //
    //                    var x = 0
    //                    for i in user!.galleryURLs {
    //
    //                        UIImageView.downloadImage(from: URL(string: i!)!, completion: { (image) in
    //                            user?.galleryImages?.append(image)
    //                            x+=1
    //
    //                            if x == user!.galleryURLs.count {
    //                                setFunction(user)
    //                            }
    //                        }) {
    //                            print("this image twas fucked")
    //                            x+=1
    //
    //                            if x == user!.galleryURLs.count {
    //                                setFunction(user)
    //                            }
    //                        }
    //                    }
    //                }) {
    //                    setFunction(user)
    //                }
    //
                    setFunction(user)
                   
                    
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
                "galleryURLs" : user.galleryURLs,
                "email": user.email!,
                "friends": user.friends,
                "followers": user.followers,
                "blocked": user.blocked,
                "favorites": user.favorites,
                "timestamp": user.timestamp ??  0,
                "requests":user.requests,
                "pregames":user.pregames,
                "messagingID":user.messagingID ?? "",
                "status" : user.status ??  User.NIL
            ]

            Firestore.firestore().collection(LoginVC.USER_DATABASE).document(user.uid!).setData(docData) {err in
                //TODO handle error
            }
            
        }
        
    }
    
    static func sendPushNotification(payloadDict: [String: Any]) {
        
       let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
       var request = URLRequest(url: url)
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       // get your **server key** from your Firebase project console under **Cloud Messaging** tab
       request.setValue("key=AAAAhZZfG5M:APA91bH6TqPsduknnpvs7zzS8OqDmtH6I3iANtdLMlvinJ2jH2ZTYPaBax2cnVZc9nxWtoqX1WEIJob7TZqd5istnQwDz3u0Eo8rft_97BuyHqixs3fA9Q6U1Wj62hbkqGKLV6rMWl3n", forHTTPHeaderField: "Authorization")
       request.httpMethod = "POST"
       request.httpBody = try? JSONSerialization.data(withJSONObject: payloadDict, options: [])
       let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "")
            return
          }
          if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print(response ?? "")
          }
          print("Notfication sent successfully.")
          let responseString = String(data: data, encoding: .utf8)
          print(responseString ?? "")
       }
       task.resume()
    }
    
    
    
}


