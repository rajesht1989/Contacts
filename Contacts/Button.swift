//
//  Button.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 02/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import UIKit

class Button: UIButton {
    var imageVw: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    var rawImage: UIImage?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(imageVw)
        imageVw.contentMode = .scaleAspectFit
        imageVw.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            imageVw.leftAnchor.constraint(equalTo: leftAnchor),
            imageVw.topAnchor.constraint(equalTo: topAnchor),
            imageVw.rightAnchor.constraint(equalTo: rightAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            imageVw.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -3)
        ])
    }
    
    @IBInspectable var image: UIImage {
         get {
            return imageVw.image ?? UIImage()
         } set {
           imageVw.image = newValue
            rawImage = newValue
         }
    }
    
    @IBInspectable var text: String {
          get {
            return label.text ?? ""
          }
          set {
            label.text = newValue
          }
    }
    /*
    override var isEnabled: Bool {
        set {
            super.isEnabled = newValue
            if newValue {
                imageVw.image = rawImage
            } else {
                imageVw.image = rawImage?.withRenderingMode(.alwaysTemplate)
                imageVw.tintColor = UIColor.gray
            }
        } get {
            super.isEnabled
        }
    }
    */
    
}
