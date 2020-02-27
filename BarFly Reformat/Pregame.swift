//
//  Pregame.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 2/24/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Pregame {
    
    var uid: String?
    var date:Date?
    var createdBy: String?
    var bar: String?
    var location: String?
    var description: String?
    var invited: [String?]
    var accepted: [String?]
    var declined: [String?]
    
    static func getPregame(uid: String, setFunction: @escaping (_ pregame: Pregame?) -> Void) {
        
        var pregame: Pregame?
        
        let firestore = Firestore.firestore()
        let userRef = firestore.collection(LoginVC.PREGAME_DATABASE)
        let docRef = userRef.document("\(uid)")
        docRef.getDocument { (document, error) in
                
            if(error == nil) {
    
                let date = ((document!.get("date")) as! Date)
                let createdBy = ((document!.get("createdBy")) as! String)
                let location = ((document!.get("location")) as! String)
                let description = ((document!.get("description")) as! String)
                let invited = ((document!.get("invited")) as? [String] ?? [String]())
                let accepted = ((document!.get("invited")) as? [String] ?? [String]())
                let declined = ((document!.get("invited")) as? [String] ?? [String]())
                let bar = ((document!.get("bar")) as! String)

                
                pregame = Pregame(uid: uid, date: date, createdBy: createdBy, bar: bar, location: location, description: description, invited: invited, accepted: accepted, declined: declined)
                
                setFunction(pregame)
                
            }
                
        }
    }
        
    
    static func updatePregame(pregame: Pregame?) {
        
        if let pregame = pregame, let date = pregame.date, let cB = pregame.createdBy, let uid = pregame.uid, let location = pregame.location, let description = pregame.description {
        
            let docData: [String: Any] = [
                "date" : date,
                "createdBy": cB,
                "bar" : pregame.bar ?? "",
                "location" : location,
                "description" : description,
                "invited" : pregame.invited,
                "accepted" : pregame.accepted,
                "declined" : pregame.declined
            ]

            Firestore.firestore().collection(LoginVC.PREGAME_DATABASE).document(uid).setData(docData) {err in
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



