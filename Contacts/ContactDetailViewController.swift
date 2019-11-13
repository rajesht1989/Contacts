//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 02/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import UIKit

enum ButtonType: Int {
    case message = 0
    case call
    case mail
    case favorite
}

enum CellType: Int {
    case mobile = 0
    case mail
    case delete
}

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageButton: Button!
    @IBOutlet weak var callButton: Button!
    @IBOutlet weak var mailButton: Button!
    @IBOutlet weak var favoriteButton: Button!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var contactId: Int?
    var contact: Contact?
    var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.cornerRadius = imageView.bounds.size.height / 2
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: isIpad() ? 0 : max(view.bounds.size.height, view.bounds.size.width) - 250 - 150, right: 0)
        imageView.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        navigationItem.rightBarButtonItem?.isEnabled = false
        observer = NotificationCenter.default.addObserver(forName: .refresh, object: nil, queue: nil) { (notification) in
            self.loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if contact == nil {
            self.indicator(show: true)
            NotificationCenter.default.post(name: .refresh, object: nil)
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            imageView.layer.cornerRadius = imageView.bounds.size.height / 2
        }
    }
    
    @IBAction func buttonAction(_ sender: Button) {
        let type = ButtonType(rawValue: sender.tag) ?? .message
        switch type {
        case .message:
            UIApplication.shared.open(URL(string: "sms://".appending(contact!.phoneNumber!))!)
        case .call:
            UIApplication.shared.open(URL(string: "tel://".appending(contact!.phoneNumber!))!)
        case .mail:
            UIApplication.shared.open(URL(string: "mailto://".appending(contact!.email!))!)
        case .favorite:
            if let contact = contact {
                if contact.favorite {
                    sender.imageVw.image = #imageLiteral(resourceName: "favourite_button")
                } else {
                    sender.imageVw.image = #imageLiteral(resourceName: "favourite_button_selected")
                }
                Connection.inverseFavorite(contact) { (contact, error) in
                    if error != nil {
                        if self.contact!.favorite {
                            sender.imageVw.image = #imageLiteral(resourceName: "favourite_button_selected")
                        } else {
                            sender.imageVw.image = #imageLiteral(resourceName: "favourite_button")
                        }
                    } else {
                        NotificationCenter.default.post(name: .refresh, object: nil)
                    }
                }
            }
        }
    }
    
    
}

extension ContactDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func cell(for indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        switch CellType(rawValue: indexPath.row)! {
        case .mobile:
            cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Mobile"
            (cell.contentView.viewWithTag(2) as? UILabel)?.text = contact!.phoneNumber
        case .mail:
            cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Mail"
            (cell.contentView.viewWithTag(2) as? UILabel)?.text = contact!.email
        case .delete:
            cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath)
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return (contact != nil) ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if CellType(rawValue: indexPath.row) == .delete {
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete contact?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.indicator(show: true)
                Connection.delete(self.contact!) { (err) in
                    self.indicator(show: false)
                    if err == nil {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showToast(message: err!.localizedDescription, time: 3)
                    }
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isIpad() == false && traitCollection.verticalSizeClass == .regular {
            if scrollView.contentOffset.y <= -50 {
                heightConstraint.constant = 250
            } else if scrollView.contentOffset.y >= 0 {
                heightConstraint.constant = 200
            } else {
                heightConstraint.constant = 200 + -(scrollView.contentOffset.y)
            }
        }
    }
}



// MARK: - Webcall extension

extension ContactDetailViewController {
    func loadData() {
        Connection.contactDetails(contactId!) { (contactReceived, err) in
            self.indicator(show: false)
            if let error = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.showMessage(message: error.localizedDescription)
            } else if let contactReceived = contactReceived {
                self.contact = contactReceived
                self.configure(for: contactReceived)
            }
        }
    }
    
    func configure(for contact: Contact) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.gradientView.isHidden = false
        self.tableView.isHidden = false
        Connection.image(for: contact) { (data, error) in
            if let imageData = data?.0 {
                self.imageView.image = UIImage(data: imageData)
            }
        }
        self.nameLabel.text = contact.firstName + " " + contact.lastName
        messageButton.isEnabled = contact.phoneNumber != nil
        callButton.isEnabled = contact.phoneNumber != nil
        mailButton.isEnabled = contact.email != nil
        if contact.favorite {
            favoriteButton.imageVw.image = #imageLiteral(resourceName: "favourite_button_selected")
        } else {
            favoriteButton.imageVw.image = #imageLiteral(resourceName: "favourite_button")
        }
        tableView.reloadData()
    }
}

// MARK: - Segue extension

extension ContactDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = (segue.destination as! UINavigationController).topViewController as? ContactModificationViewController {
            destination.mode = .update
            destination.contact = contact
        }
    }
}
