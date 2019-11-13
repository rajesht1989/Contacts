//
//  ContactsViewController.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 01/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let refresh = Notification.Name("refresh")
}

class ContactsViewController: UITableViewController {
    var contacts: SortedContacts?
    var groups: GroupedContacts?
    var alphabets: SortedAlphabets?
    var observer: NSObjectProtocol?
    
    let tutorialShown = "tutorialShown"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        observer = NotificationCenter.default.addObserver(forName: .refresh, object: nil, queue: nil) { (notification) in
            self.loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if  contacts == nil {
            indicator(show: true)
            NotificationCenter.default.post(name: .refresh, object: nil)
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func contact(forIndexPath: IndexPath) -> Contact? {
        return groups?[alphabets![forIndexPath.section]]?[forIndexPath.row]
    }

    // MARK: - Table view data source & delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return alphabets?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?[alphabets![section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell
        if let contact = contact(forIndexPath: indexPath) {
            cell.configure(contact: contact)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alphabets![section]
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            let contact = self.contact(forIndexPath: indexPath)
            let favorite = contact?.favorite ?? false
            let actionTitle = favorite ? "Remove Favorite" : "Mark as Favorite"
            return UIMenu(title: "", children:
                [UIAction(title: actionTitle, handler: { (action) in
                    self.indicator(show: true)
                    Connection.inverseFavorite(contact!) { (contact, error) in
                        self.indicator(show: false)
                        if error == nil {
                            NotificationCenter.default.post(name: .refresh, object: nil)
                        } else {
                            self.indicator(show: false)
                            self.showMessage(message: error!.localizedDescription)
                        }
                    }
                }),
                 UIAction(title: "Delete", attributes: .destructive, handler: { (action) in
                    self.indicator(show: true)
                    Connection.delete(contact!) { (error) in
                        if error == nil {
                            NotificationCenter.default.post(name: .refresh, object: nil)
                        } else {
                            self.indicator(show: false)
                            self.showMessage(message: error!.localizedDescription)
                        }
                    }
                 })])
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return alphabets
    }
    
    @IBAction func groupAction(_ sender: Any) {
        showToast(message: "Coming Soon", time: 1)
    }
    
}

// MARK: - Webcall extension

extension ContactsViewController {
    func loadData() {
        Connection.contacts { (contactsReceived, error) in
            self.indicator(show: false)
            if let error = error {
                self.showMessage(message: error.localizedDescription)
            } else if let contactsReceived = contactsReceived {
                self.contacts = contactsReceived.0
                self.groups = contactsReceived.1
                self.alphabets = contactsReceived.2
                self.tableView.reloadData()
                
                if UserDefaults.standard.bool(forKey: self.tutorialShown) == false {
                    let alertController = UIAlertController(title: "", message: "Welcome, \n ------\n I'm 'Contacts' app & find my special capabilities here\n------\n 1) I support iOS 13 and above\n------\n2) I support both Light and Dark mode\n------\n3) Capable of inverting favorite from list as well as in detail view\n------\n4) Capable of deleting a contact from list as well as in detail view\n------\n5) Implemented my own indicator view\n------\n6) Don't miss my parallax effect on the detail view\n------\n7) I have handled all the error scenarios\n------\n8) Not used any 3rd party components\n------\n9) Finally all my testcases are succeeded 😊", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Show on next Launch", style: .default))
                    alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (action) in
                        UserDefaults.standard.set(true, forKey: self.tutorialShown)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - Segue extension

extension ContactsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ContactCell, let contact = cell.cellContact, let destination = segue.destination as? ContactDetailViewController {
            destination.contactId = contact.id
        } else if let destination = segue.destination as? ContactModificationViewController {
            destination.mode = .add
        }
    }
}

