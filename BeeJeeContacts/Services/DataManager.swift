//
//  DataManager.swift
//  BeeJeeContacts
//
//  Created by Karlygash Zhuginissova on 3/15/18.
//  Copyright © 2018 Karlygash Zhuginissova. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class DataManager {
    static func fetchContacts(completion: @escaping ([NSManagedObject], String?) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let contactEntity = NSEntityDescription.entity(forEntityName: Constants.CONTACT_OBJECT, in: managedContext)!
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.CONTACT_OBJECT)
        var contacts: [Contact] = []

        do {
            contacts = try managedContext.fetch(fetchRequest) as! [Contact]
            if contacts == [] {
                if let jsonPath = Bundle.main.path(forResource: "contacts", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                        guard let jsonArray = JSON(data: data).array else {
                            
                            return
                        }
                        
                        for json in jsonArray {
                            guard let id = json["id"].string,
                                let firstName = json["first_name"].string,
                                let lastName = json["last_name"].string,
                                let phoneNumber = json["phone_number"].string,
                                let street1 = json["street_1"].string,
                                let street2 = json["street_2"].string,
                                let city = json["city"].string,
                                let state = json["state"].string,
                                let country = json["country"].string,
                                let zip = json["zip"].string else {
                                    return
                            }
                            
                            let contact = NSManagedObject(entity: contactEntity, insertInto: managedContext)
                            contact.setValue(id, forKey: Constants.ID)
                            contact.setValue(firstName, forKey: Constants.FIRST_NAME)
                            contact.setValue(lastName, forKey: Constants.LAST_NAME)
                            contact.setValue(phoneNumber, forKey: Constants.PHONE)
                            contact.setValue(street1, forKey: Constants.STREET1)
                            contact.setValue(street2, forKey: Constants.STREET2)
                            contact.setValue(city, forKey: Constants.CITY)
                            contact.setValue(state, forKey: Constants.STATE)
                            contact.setValue(country, forKey: Constants.COUNTRY)
                            contact.setValue(zip, forKey: Constants.ZIPCODE)
                            
                            do {
                                try managedContext.save()
                                contacts.append(contact as! Contact)
                            } catch let error {
                                return completion([], error.localizedDescription)
                            }
                            
                        }
                        
                        completion(contacts, nil)
                        
                        
                    } catch let error {
                        completion([], error.localizedDescription)
                    }
                    
                }
            } else {
                completion(contacts, nil)
            }
        } catch {
            //Running app for the first time - No data is saved yet

        }
    }
    
    static func deleteContact(contact: NSManagedObject, completion: @escaping (Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(contact)
        do {
            try managedContext.save()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    static func saveContact(contactParams: [String: String], contact: NSManagedObject?, completion: @escaping (NSManagedObject?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        var contactToSave = NSManagedObject()
        if contact == nil {
            let contactEntity = NSEntityDescription.entity(forEntityName: Constants.CONTACT_OBJECT, in: managedContext)!
            contactToSave = NSManagedObject(entity: contactEntity, insertInto: managedContext)
            
        } else {
            contactToSave = contact!
        }
        
        contactToSave.setValue(contactParams[Constants.ID], forKey: Constants.ID)
        contactToSave.setValue(contactParams[Constants.FIRST_NAME], forKey: Constants.FIRST_NAME)
        contactToSave.setValue(contactParams[Constants.LAST_NAME], forKey: Constants.LAST_NAME)
        contactToSave.setValue(contactParams[Constants.PHONE], forKey: Constants.PHONE)
        contactToSave.setValue(contactParams[Constants.STREET1], forKey: Constants.STREET1)
        contactToSave.setValue(contactParams[Constants.STREET2], forKey: Constants.STREET2)
        contactToSave.setValue(contactParams[Constants.CITY], forKey: Constants.CITY)
        contactToSave.setValue(contactParams[Constants.STATE], forKey: Constants.STATE)
        contactToSave.setValue(contactParams[Constants.COUNTRY], forKey: Constants.COUNTRY)
        contactToSave.setValue(contactParams[Constants.ZIPCODE], forKey: Constants.ZIPCODE)
        
        do {
            try managedContext.save()
            completion(contactToSave)
        } catch {
            completion(nil)
        }
    }
}
