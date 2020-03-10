//
//  CreatePregame.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 3/7/20.
//  Copyright © 2020 LoFi Games. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import FirebaseFirestore
import UIKit

class CreatePregame: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var date: UITextField!
    
    @IBOutlet weak var desc: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var createButtonView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var indicator: NVActivityIndicatorView?
    
    
    
    override func viewDidLoad() {
        
        date.layer.cornerRadius = 5
        date.layer.borderWidth = 0
        date.layer.borderColor = UIColor.barflyblue.cgColor
        
        location.layer.cornerRadius = 5
        location.layer.borderWidth = 0
        location.layer.borderColor = UIColor.barflyblue.cgColor
        
        desc.layer.cornerRadius = 5
        desc.layer.borderWidth = 0
        desc.layer.borderColor = UIColor.barflyblue.cgColor
        
        createButton.layer.borderWidth = 3
        createButton.layer.borderColor = UIColor.black.cgColor
        
        createButton.layer.cornerRadius = 10
        createButtonView.layer.cornerRadius = 10
        
        self.date.delegate = self
        self.date.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        
        indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.width / 2 - 50, y: view.frame.height / 2 - 50, width: 100, height: 100), type: .circleStrokeSpin, color: .barflyblue, padding: 0)
        
        
    }
    
    @objc func tapDone() {
        if let datePicker = self.date.inputView as? UIDatePicker { // 2-1
            let dateformatter = DateFormatter() // 2-2
            dateformatter.dateStyle = .medium // 2-3
            dateformatter.timeStyle = .short
            self.date.text = dateformatter.string(from: datePicker.date) //2-4
        }
        self.date.resignFirstResponder() // 2-5
    }
    
    @IBAction func createButtonClicked(_ sender: Any) {
        
        if let location = location.text, let date = date.text, let description = desc.text {
            
            var uid = Firestore.firestore().collection(LoginVC.PREGAME_DATABASE).addDocument(data: [
                "location" : location,
                "description" : description,
                "date" : date,
                "createdBy" : AppDelegate.user?.username
                
            ] ).documentID
            
            
            
            
        } else {
            
            errorLabel.text = "Must provide all fields"
            errorLabel.isHidden = false
            
        }
    }
    
}
