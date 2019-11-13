//
//  ContactCell.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 01/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    static let identifier = "ContactCell"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var cellContact: Contact?

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        
    }
    
    func configure(contact: Contact) {
        cellContact = contact
        nameLabel.text = contact.firstName + " " + contact.lastName
        favoriteButton.isSelected = contact.favorite
        indicator.startAnimating()
        Connection.image(for: contact) { (data, error) in
            guard let data = data, contact == data.1 else {
                return
            }
            self.indicator.stopAnimating()
            if let image = UIImage(data: data.0) {
                self.profileImageView.image = image
            } else {
                self.profileImageView.image = #imageLiteral(resourceName: "placeholder_photo")
            }
        }
    }
}
