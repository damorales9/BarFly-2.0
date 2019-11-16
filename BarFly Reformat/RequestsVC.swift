//
//  RequestsVC.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/13/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class RequestsVC: UITableViewController {
    
    override func viewDidLoad() {
        tableView.rowHeight = 60
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if((AppDelegate.user?.requests.count)! == 0) {
            
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No requests you lonely piece of shit"
            noDataLabel.textColor     = UIColor.barflyblue
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: "Roboto-Thin", size: 20)
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return (AppDelegate.user?.requests.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RequestCellView
        
        User.getUser(uid: (AppDelegate.user?.requests[indexPath.row])!) { (user: User?) in
            cell.username!.text = "\(user!.username!)"
            cell.name!.text = "\(user!.name!)"
            
            cell.profileImage?.clipsToBounds = true
            cell.profileImage?.layer.cornerRadius = 24
            cell.profileImage?.layer.borderWidth = 1
            cell.profileImage?.layer.borderColor = UIColor.white.cgColor
            cell.profileImage?.contentMode = .scaleToFill
            
            cell.accept.tag = indexPath.row
            cell.decline.tag = indexPath.row

            cell.accept.addTarget(self, action: #selector(self.acceptClicked), for: .touchUpInside)
            cell.decline.addTarget(self, action: #selector(self.declineClicked), for: .touchUpInside)
            
            var placeholder: UIImage?
            if #available(iOS 13.0, *) {
                placeholder = UIImage(systemName: "person.circle")
            } else {
                // Fallback on earlier versions
                placeholder = UIImage(named: "profile")
            }

            if (user?.profileURL != "") {

                let storage = Storage.storage()
                let httpsReference = storage.reference(forURL: (user?.profileURL!)!)


                cell.profileImage?.sd_setImage(with: httpsReference, placeholderImage: placeholder)


            } else {
                cell.profileImage?.image = placeholder
            }
            
            cell.profileImage?.image = cell.profileImage?.image!.resizeImageWithBounds(bounds: CGSize(width: 50, height: 50))
        }
        
        return cell
        
    }
    
    @objc func acceptClicked(sender: UIButton) {
        
        User.getUser(uid: (AppDelegate.user?.requests[sender.tag])!) { ( user: User?) in
            
            var u = user!
            
            u.friends.append(AppDelegate.user?.uid)
            AppDelegate.user?.requests.remove(at: sender.tag)
            
            User.updateUser(user: u)
            User.updateUser(user: AppDelegate.user)
            
            self.tableView.reloadData()
            
        }
    }
    
    @objc func declineClicked(sender: UIButton) {
     
        User.getUser(uid: AppDelegate.user!.uid!) { ( user: User?) in
            
            AppDelegate.user?.requests.remove(at: sender.tag)
            User.updateUser(user: AppDelegate.user)
            
            self.tableView.reloadData()
            
        }
        
    }
    
    
    
}
