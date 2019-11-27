//
//  BarDetailsVC.swift
//  BarFly Reformat
//
//  Created by Derek Morales on 11/14/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import MapKit

class BarDetailsVC: UITableViewController, UISearchResultsUpdating {
    
    static var delegate: FirstViewController?
    
    var filteredTableData = [CustomBarAnnotation]()
    var resultSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        
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
        
        resultSearchController.searchBar.becomeFirstResponder();
        
        // Reload the table
        
        tableView.rowHeight = 60
        
        tableView.reloadData()
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        BarDetailsVC.delegate?.navigationController?.isNavigationBarHidden = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let basicQuery = Firestore.firestore().collection("Bars").limit(to: 50)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allBars = snapshot.documents
            var x = 0
            for barDocument in allBars {
                let amntPeople = barDocument.data()["amountPeople"] as? Int
                let name = barDocument.data()["name"] as? String
                let latitude = barDocument.data()["latitude"] as? Double
                let longitude = barDocument.data()["longitude"] as? Double
                let imageURL = barDocument.data()["imageURL"] as? String
                let url = barDocument.data()["url"] as? String
                
                if (name!.lowercased().contains(self.resultSearchController.searchBar.text!.lowercased())) {
                    print("adding \(name!)")
                    let bar = CustomBarAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                    bar.title = NSLocalizedString(name!, comment: name!)
                    bar.imageName = imageURL!
                    bar.amntPeople = amntPeople
                    bar.url = url
                    
                    var dup = false
                    for i in self.filteredTableData {
                        if(i.title == bar.title) {
                            dup = true
                        }
                    }
                    if(!dup) {
                        self.filteredTableData.append(bar)
                        self.tableView.reloadData()
                        x = x + 1
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BarCell", for: indexPath)

        print("trying to show something!")
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row].title
            
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.cornerRadius = 24
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.white.cgColor
            cell.imageView?.contentMode = .scaleToFill
            
            var placeholder: UIImage?
            if #available(iOS 13.0, *) {
                placeholder = UIImage(systemName: "person.circle")
            } else {
                // Fallback on earlier versions
                placeholder = UIImage(named: "profile")
            }

            if (filteredTableData[indexPath.row].imageName != "nil") {
                

                cell.imageView?.getImage(ref: filteredTableData[indexPath.row].imageName!, placeholder: placeholder!, maxMB: 6)


            } else {
                cell.imageView?.image = placeholder
            }
            
            cell.imageView?.image = cell.imageView?.image!.resizeImageWithBounds(bounds: CGSize(width: 50, height: 50))
            
            
            return cell
        }
        else {
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        CustomBarAnnotation.getBar(name: filteredTableData[indexPath.row].title!, setFunction: {(bar: inout CustomBarAnnotation?) -> Void in
            BarDetails.bar = bar!
                
            self.resultSearchController.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
            BarDetailsVC.delegate!.myMapView.setCenter(bar!.coordinate, animated: true)
            
            var currentBar: MKAnnotation!
            currentBar = FirstViewController.getAnnotation(title: bar!.title!)
            BarDetailsVC.delegate!.myMapView.selectAnnotation(currentBar!, animated: true)
        })
        
        UIView.animate(withDuration: 0.5) {
            FirstViewController.centerConstraint.constant = -85
            //FirstViewController.barDetails.layoutIfNeeded()
        }
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
