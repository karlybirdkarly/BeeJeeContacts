//
//  DetailsViewController.swift
//  BeeJeeContacts
//
//  Created by Karlygash Zhuginissova on 3/15/18.
//  Copyright © 2018 Karlygash Zhuginissova. All rights reserved.
//

import UIKit
import CoreData
protocol ClearButtonTappable {
    func clear(cell: AddressCell)
}

protocol TextFieldDidChange {
    func textFieldDidChange(cell: UITableViewCell)
}

protocol ContactAddDeleteUpdate {
    func onDeletedContact()
    func onUpdatedContact(contact: NSManagedObject)
    func onSavedNewContact(contact: NSManagedObject)
}
class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ClearButtonTappable, TextFieldDidChange {

    @IBOutlet var addressTableView: UITableView!
    @IBOutlet var phoneTableView: UITableView!
    @IBOutlet var nameTableView: UITableView!
    
    var contact: NSManagedObject?
    var tripleDelegate: ContactAddDeleteUpdate?

    var firstName = ""
    var lastName = ""
    var phone = ""
    var street1 = ""
    var street2 = ""
    var city = ""
    var country = ""
    var state = ""
    var zip = ""
    
    @IBOutlet var deleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegates()
        if let contact = contact {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))
            firstName = contact.value(forKey: Constants.FIRST_NAME) as! String
            lastName = contact.value(forKey: Constants.LAST_NAME) as! String
            phone = contact.value(forKey: Constants.PHONE) as! String
            street1 = contact.value(forKey: Constants.STREET1) as! String
            street1 = contact.value(forKey: Constants.STREET2) as! String
            city = contact.value(forKey: Constants.CITY) as! String
            state = contact.value(forKey: Constants.STATE) as! String
            country = contact.value(forKey: Constants.COUNTRY) as! String
            zip = contact.value(forKey: Constants.ZIPCODE) as! String
        } else {
            self.deleteButton.isHidden = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))
        }

//        self.navigationItem.title = "New Contact"
        // Do any additional setup after loading the view.
    }
    
    func setDelegates() {
        nameTableView.dataSource = self
        phoneTableView.dataSource = self
        addressTableView.dataSource = self
        
        nameTableView.delegate = self
        phoneTableView.delegate = self
        addressTableView.delegate = self
        
    }
    
    func generateUID() -> String {
        var fourUniqueDigits = ""
        repeat {
            fourUniqueDigits = String(format:"%04d", arc4random_uniform(10000) )
        } while fourUniqueDigits.count < 4

        return fourUniqueDigits
    }
    

    @objc func onCancel(_ sender: UIBarButtonItem) {
        if contact != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func onDone(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        if contact != nil {
            if firstName != "" || lastName != "" || phone != "" || street1 != "" || street2 != "" || city != "" || state != "" || country != "" || zip != "" {
                let params = [Constants.ID: contact?.value(forKey: Constants.ID) as! String,
                              Constants.FIRST_NAME: firstName,
                              Constants.LAST_NAME: lastName,
                              Constants.PHONE: phone,
                              Constants.STREET1: street1,
                              Constants.STREET2: street2,
                              Constants.CITY: city,
                              Constants.STATE: state,
                              Constants.COUNTRY: country,
                              Constants.ZIPCODE: zip]
                DataManager.saveContact(contactParams: params, contact: self.contact!, completion: { (contact) in
                    if let contact = contact {
                        self.tripleDelegate?.onUpdatedContact(contact: contact)
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            } else {
               print("empty contact cannot be saved")
            }

        } else {
            
            let params = [Constants.ID: self.generateUID(),
                          Constants.FIRST_NAME: firstName,
                          Constants.LAST_NAME: lastName,
                          Constants.PHONE: phone,
                          Constants.STREET1: street1,
                          Constants.STREET2: street2,
                          Constants.CITY: city,
                          Constants.STATE: state,
                          Constants.COUNTRY: country,
                          Constants.ZIPCODE: zip]
            DataManager.saveContact(contactParams: params, contact: nil, completion: { (contact) in
                if let contact = contact {
                    self.tripleDelegate?.onSavedNewContact(contact: contact)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    @IBAction func onDeleteContact(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .default) { (_) in
            DataManager.deleteContact(contact: self.contact!) { (success) in
                if !success {
                    //do something
                } else {
                    self.tripleDelegate?.onDeletedContact()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case nameTableView:
            return 2
        case phoneTableView:
            return 1
        case addressTableView:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == nameTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! NameCell

            cell.textDelegate = self
            if indexPath.row == 0 {

                cell.textField.placeholder = "First Name"
                guard let contact = contact else {
                    return cell
                }
                cell.textField.text = contact.value(forKey: Constants.FIRST_NAME) as? String
            } else {
                cell.textField.placeholder = "Last Name"
                guard let contact = contact else {
                    return cell
                }
                cell.textField.text = contact.value(forKey: Constants.LAST_NAME) as? String

            }
            return cell
        } else if tableView == addressTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
            guard let contact = contact else {
                return cell
            }
            cell.textDelegate = self
            cell.s1TextField.text = contact.value(forKey: Constants.STREET1) as? String
            cell.s2TextField.text = contact.value(forKey: Constants.STREET2) as? String
            cell.cityTextField.text = contact.value(forKey: Constants.CITY) as? String
            cell.stateTextField.text = contact.value(forKey: Constants.STATE) as? String
            cell.countryTextField.text = contact.value(forKey: Constants.COUNTRY) as? String
            cell.zipTextField.text = contact.value(forKey: Constants.ZIPCODE) as? String
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath) as! PhoneCell
            guard let contact = contact else {
                return cell
            }
            cell.textDelegate = self
            cell.textField.text = contact.value(forKey: Constants.PHONE) as? String
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == addressTableView || tableView == phoneTableView {
            return tableView.frame.height
        } else {
            return tableView.frame.height / 2
        }
    }
}

extension DetailsViewController {
    func clear(cell: AddressCell) {
        let alert = UIAlertController(title: "Are you sure you want to clean address fields", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            cell.s1TextField.text = ""
            cell.s2TextField.text = ""
            cell.cityTextField.text = ""
            cell.stateTextField.text = ""
            cell.countryTextField.text = ""
            cell.zipTextField.text = ""
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    func textFieldDidChange(cell: UITableViewCell) {
        if let nCell = cell as? NameCell {
            let row = nameTableView.indexPath(for: nCell)?.row
            if row == 0 {
                firstName = nCell.textField.text ?? ""
            } else {
                lastName = nCell.textField.text ?? ""
            }
        } else if let pCell = cell as? PhoneCell {
            phone = pCell.textField.text ?? ""
        } else if let aCell = cell as? AddressCell {
            street1 = aCell.s1TextField.text ?? ""
            street2 = aCell.s2TextField.text ?? ""
            city = aCell.cityTextField.text ?? ""
            state = aCell.stateTextField.text ?? ""
            country = aCell.countryTextField.text ?? ""
            zip = aCell.zipTextField.text ?? ""

        }
    }
    
}
