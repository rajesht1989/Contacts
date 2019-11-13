//
//  ContactModificationViewController.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 03/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import UIKit

enum Mode {
    case add
    case update
}
enum ModificationCellType: Int {
    case image = 0
    case firstName
    case lastName
    case mobile
    case mail
}

class ContactModificationViewController: UITableViewController {
    let indexShift = 1
    var contact: Contact?
    var mutableContact: MutableContact!
    var mode: Mode = .add

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        switch mode {
        case .add:
            mutableContact = MutableContact()
        case .update:
            if let contact = contact {
                mutableContact = MutableContact(firstName: contact.firstName, lastName: contact.lastName, email: contact.email, phoneNumber: contact.phoneNumber)
            }
        }
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        let cellType = ModificationCellType(rawValue: sender.superview?.tag ?? 0)!
        switch cellType {
        case .firstName:
            mutableContact.firstName = sender.text
        case .lastName:
            mutableContact.lastName = sender.text
        case .mobile:
            mutableContact.phoneNumber = sender.text
        case .mail:
            mutableContact.email = sender.text
        default:
            break
        }
    }
    
    @IBAction func profilePicButtonAction(_ sender: Any) {
        showToast(message: "Coming soon", time: 1)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        view.endEditing(true)
        guard mutableContact.firstName != nil && mutableContact.lastName != nil && mutableContact.phoneNumber != nil && mutableContact.email != nil  else {
            self.showToast(message: "All fields are mandatory", time: 1)
            return
        }
        let completion = { (contact: Contact?, error: Error?) in
            self.indicator(show: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { self.didEndUpdating(contact: contact, error: error) }) //delay given to get the indicator dismissed
        }
        if mode == .add {
            indicator(show: true)
            Connection.addContact(mutableContact, completion: completion)
        } else {
            indicator(show: true)
            Connection.update(contact!.id, contact: mutableContact, completion: completion)
        }
    }
    
    func didEndUpdating(contact: Contact?, error: Error?) {
        if let error = error {
            if let error = error as? ContactsError {
                self.showMessage(message: error.errorDescription)
            } else {
                self.showMessage(message: error.localizedDescription)
            }
        } else if contact != nil {
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .refresh, object: nil)
        }
    }
    
    func cell(for indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch ModificationCellType(rawValue: indexPath.row)! {
        case .image:
            cell = tableView.dequeueReusableCell(withIdentifier: "picCell", for: indexPath)
            if let imageView = (cell.contentView.viewWithTag(1) as? UIImageView) {
                imageView.layer.borderColor = UIColor.lightGray.cgColor
                imageView.layer.borderWidth = 0.5
            imageView.layer.cornerRadius = 65
            if mode == .update {
                Connection.image(for: contact!) { (data, error) in
                    guard let data = data, self.contact == data.1 else {
                        return
                    }
                    if let image = UIImage(data: data.0) {
                        imageView.image = image
                    } else {
                        imageView.image = #imageLiteral(resourceName: "placeholder_photo")
                    }
                }
            } else {
                imageView.image = #imageLiteral(resourceName: "placeholder_photo")
            }
           
            }


        case .firstName:
            cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "First Name"
            if let textField = cell.contentView.viewWithTag(2) as? UITextField {
                textField.text = mutableContact!.firstName
                textField.keyboardType = .namePhonePad
            }
        case .lastName:
            cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Last Name"
            if let textField = cell.contentView.viewWithTag(2) as? UITextField {
                textField.text = mutableContact!.lastName
                textField.keyboardType = .namePhonePad
            }
        case .mobile:
            cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Mobile"
            if let textField = cell.contentView.viewWithTag(2) as? UITextField {
                textField.text = mutableContact!.phoneNumber
                textField.keyboardType = .phonePad
            }
        case .mail:
            cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Email"
            if let textField = cell.contentView.viewWithTag(2) as? UITextField {
                textField.text = mutableContact!.email
                textField.keyboardType = .emailAddress
            }
        }
        cell.contentView.tag = indexPath.row
        return cell
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModificationCellType.mail.rawValue + indexShift
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }

}

extension ContactModificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
