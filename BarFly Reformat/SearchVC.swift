//
//  SearchVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/3/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class SearchVC: UITableViewController, UISearchResultsUpdating {

    
    var filteredTableData = [User]()
    var resultSearchController = UISearchController()

    
    override func viewDidLoad() {
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = .black
            controller.searchBar.searchTextField.textColor = UIColor(red:0.71, green:1.00, blue:0.99, alpha:1.0)
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        
        tableView.rowHeight = 50
        
        tableView.reloadData()
        
    }
    
    func updateSearchResults(for searchController:
        UISearchController) {
        
        filteredTableData.removeAll(keepingCapacity: false)

        
        let db = Firestore.firestore()
        db.collection(LoginVC.USER_DATABASE).getDocuments { (snapshot, error) in
            
            if error != nil {
                print(error as Any)
                print("Error when getting UID list from firebase")
            }
            
            var x = 0
            for document in (snapshot?.documents)!{
                let userRef = db.collection(LoginVC.USER_DATABASE)
                let docRef = userRef.document("\(document.documentID)")
                docRef.getDocument { (document, error) in
                    let name = ((document!.get("name")) as! String)
                    let username = ((document!.get("username")) as! String)
                    let bar = ((document!.get("bar")) as! String)
                    let friends = ((document!.get("friends")) as! [String])
                    let profileURL = ((document!.get("profileURL")) as! String)
                    let requests = [String]()
                    
                    if (username.contains(self.resultSearchController.searchBar.text!.lowercased())) {
                        print("adding \(username)")
                        let u = User(uid: document?.documentID, name: name, bar: bar, friends: friends, requests: requests, profileURL: profileURL)
                        
                        var dup = false
                        for i in self.filteredTableData {
                            if(i.uid == u.uid) {
                                dup = true
                            }
                        }
                        if(!dup) {
                            self.filteredTableData.append(u)
                            self.tableView.reloadData()
                            x = x + 1
                        }
                        
                    }
                }
                
                if(x > 20) {
                    break
                }
            }
        }
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        print("trying to show something!")
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row].username
            cell.detailTextLabel?.text = filteredTableData[indexPath.row].name
            
            let placeholder = UIImage( named: "person.circle.fill")
            
            if (filteredTableData[indexPath.row].profileURL != "") {
            
                let storage = Storage.storage()
                let httpsReference = storage.reference(forURL: filteredTableData[indexPath.row].profileURL!)
                
                cell.imageView?.sd_setImage(with: httpsReference, placeholderImage: placeholder)
                    
            } else {
                cell.imageView?.image = placeholder
            }
            
            cell.imageView?.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = 20
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.white.cgColor
            cell.imageView?.layer.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
            
            return cell
        }
        else {
            return cell
        }
    }
}
