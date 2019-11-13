//
//  GradientView.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 02/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        configureLayer()
    }
    
    func configureLayer() {
        let colorTop =  UIColor.systemBackground.cgColor
        let colorBottom = UIColor(red: 73/255.0, green: 238/255.0, blue: 198/255.0, alpha: 0.4).cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.2, 1.0]
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }

}
