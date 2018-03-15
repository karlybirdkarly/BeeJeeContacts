//
//  ViewController.swift
//  BeeJeeContacts
//
//  Created by Karlygash Zhuginissova on 3/15/18.
//  Copyright © 2018 Karlygash Zhuginissova. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ContactAddDeleteUpdate {
    

    @IBOutlet var tableView: UITableView!
    var contacts: [NSManagedObject] = []
    var selectedIndexPath: IndexPath?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if selectedIndexPath != nil {
            tableView.deselectRow(at: selectedIndexPath!, animated: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        DataManager.fetchContacts { (contacts, errorMessage) in
            if contacts != [] {
                self.contacts = contacts.sorted(by: { ($0.value(forKey: Constants.LAST_NAME) as! String) < ($1.value(forKey: Constants.LAST_NAME) as! String) })
                self.tableView.reloadData()
            } else {
                //show errorMessage
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    @IBAction func onAddContact(_ sender: Any) {
      
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: .main)
        let detailsVC = storyBoard.instantiateViewController(withIdentifier: "detailsVC") as! DetailsViewController
        let navigationC = UINavigationController(rootViewController: detailsVC)
        navigationC.modalTransitionStyle = .coverVertical
        detailsVC.tripleDelegate = self
        self.present(navigationC, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            let detailsVC = segue.destination as! DetailsViewController
            detailsVC.contact = self.contacts[selectedIndexPath!.row]
            detailsVC.tripleDelegate = self
        }

    }
    
    func onDeletedContact() {
        self.contacts.remove(at: (self.selectedIndexPath?.row)!)
        self.tableView.deleteRows(at: [self.selectedIndexPath!], with: .none)
    }
    
    func onSavedNewContact(contact: NSManagedObject) {
        self.contacts.append(contact)
        self.contacts = self.contacts.sorted(by: { ($0.value(forKey: Constants.LAST_NAME) as! String) < ($1.value(forKey: Constants.LAST_NAME) as! String) })
        self.tableView.reloadData()
    }
    
    func onUpdatedContact(contact: NSManagedObject) {
        self.contacts[(self.selectedIndexPath?.row)!] = contact
        self.tableView.reloadRows(at: [self.selectedIndexPath!], with: .none)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
        let currentContact = self.contacts[indexPath.row]
        cell.firstNameLabel.text = currentContact.value(forKey: Constants.FIRST_NAME) as? String
        cell.lastNameLabel.text = currentContact.value(forKey: Constants.LAST_NAME) as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "toDetails", sender: self)
    }
}

