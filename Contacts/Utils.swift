//
//  Utils.swift
//  Contacts
//
//  Created by Rajesh Thangaraj on 01/11/19.
//  Copyright © 2019 Rajesh. All rights reserved.
//

import Foundation
import UIKit

func isIpad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

extension UIViewController {
    func indicator(show: Bool) {
        if show {
            let hudController = HUDController.instance
            hudController.modalPresentationStyle = .overCurrentContext
            hudController.modalTransitionStyle = .crossDissolve
            present(hudController, animated: true, completion: nil)
        } else {
            (presentedViewController as? HUDController)?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showToast(message: String, time: Int) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(time)) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
