//
//  MATransactionBlueViewController.swift
//  MeApp
//
//  Created by Tcacenco Daniel on 5/21/18.
//  Copyright © 2018 Tcacenco Daniel. All rights reserved.
//

import UIKit

class MATransactionBlueViewController: MABasePopUpViewController {
    
    @IBOutlet weak var viewBody: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBody.layer.masksToBounds = true
        viewBody.layer.cornerRadius = 8.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
