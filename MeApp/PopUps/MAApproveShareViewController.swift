//
//  MAApproveShareViewController.swift
//  Me
//
//  Created by Tcacenco Daniel on 6/22/19.
//  Copyright © 2019 Foundation Forus. All rights reserved.
//


protocol MAApproveShareViewControllerDelegate: class {
    
    func share()
    
}

import UIKit

class MAApproveShareViewController: UIViewController {
    
    var token: String!
    var delegate: MAApproveShareViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func approve(_ sender: UIButton) {
        
        RecordsRequest.shareValidationTokenRecord(token: token, completion: { ( statusCode) in
            
            
            let alert: UIAlertController
            alert = UIAlertController(title: "Success".localized(), message: "A record has been shared!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true)
            }))
            self.delegate.share()
        }, failure: { (error) in
            self.delegate.share()
            let alert: UIAlertController
            alert = UIAlertController(title: "Error!".localized(), message: "Unknown QR-code!".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true)
            }))
        })
        
    }

    
    @IBAction func cancel(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        
    }

}
