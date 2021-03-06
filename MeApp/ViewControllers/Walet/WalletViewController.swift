//
//  WalletViewController.swift
//  TestProject
//
//  Created by Tcacenco Daniel on 5/8/18.
//  Copyright © 2018 Tcacenco Daniel. All rights reserved.
//

import CoreData
import Crashlytics
import NVActivityIndicatorView
import Reachability
import ScrollableSegmentedControl
import SDWebImage
import Speech
import SwipeCellKit
import UIKit
import Presentr
import ScrollableSegmentedControl

enum WalletCase {
    case token
    case assets
    case passes
}

class WalletViewController: MABaseViewController, AppLockerDelegate, NVActivityIndicatorViewable {
   
    
    let reachability = Reachability()!
    @IBOutlet var tableView: UITableView!
    var vouhers: NSMutableArray! = NSMutableArray()
    var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet var emptyTextLabe: UILabel!
    @IBOutlet weak var segmentController: HBSegmentedControl!
    @IBOutlet weak var segmentView: UIView!
    var walletCase : WalletCase! = WalletCase.token
    var firstTimeEnter: Bool!
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = TransitionType.coverHorizontalFromRight
        presenter.dismissOnSwipe = true
        return presenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    fileprivate func setupView(){
       // title = "Voucher"
       // if #available(iOS 11.0, *) {
       //     self.navigationController?.navigationBar.prefersLargeTitles = true
       //     self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
       //     self.tableView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
            
      //  } else {
            // Fallback on earlier versions
      //  }
         segmentController.items = ["Valuta", "Bezit", "Vouchers"]
        segmentController.selectedIndex = 0
        segmentController.font = UIFont(name: "GoogleSans-Medium", size: 14)
        segmentController.unselectedLabelColor = #colorLiteral(red: 0.631372549, green: 0.6509803922, blue: 0.6784313725, alpha: 1)
        segmentController.selectedLabelColor = #colorLiteral(red: 0.2078431373, green: 0.3921568627, blue: 0.968627451, alpha: 1)
        segmentController.addTarget(self, action: #selector(self.segmentSelected(sender:)), for: .valueChanged)
        segmentController.borderColor = .clear
        segmentView.layer.cornerRadius = 8.0
        if !UserDefaults.standard.bool(forKey: "isStartFromScanner"){
            if UserDefaults.standard.string(forKey: ALConstants.kPincode) != "" && UserDefaults.standard.string(forKey: ALConstants.kPincode) != nil {
                var appearance = ALAppearance()
                appearance.image = UIImage(named: "lock")!
                appearance.title = "Enter login code".localized()
                appearance.isSensorsEnabled = true
                appearance.cancelIsVissible = false
                appearance.delegate = self
                
                AppLocker.present(with: .validate, and: appearance, withController: self)
            }
        }
        //        Web3Provider.getBalance()
        //        Service.sendContract { _, _ in
        //        }
//        getCurrentUser()
        
        if firstTimeEnter != nil{
            let popupTransction =  MACrashConfirmViewController(nibName: "MACrashConfirmViewController", bundle: nil)
            self.presenter.presentationType = .popup
            self.presenter.transitionType = nil
            self.presenter.dismissTransitionType = nil
            self.presenter.keyboardTranslationType = .compress
            self.customPresentViewController(self.presenter, viewController: popupTransction, animated: true, completion: nil)
        }
        
        
        let size = CGSize(width: 60, height: 60)
        
//        startAnimating(size, message: "Loading...".localized(), type: NVActivityIndicatorType(rawValue: 32)!, color: #colorLiteral(red: 0.1918309331, green: 0.3696506619, blue: 0.9919955134, alpha: 1), textColor: .black, fadeInAnimation: nil)
//        getVoucherList()
        
        if UserDefaults.standard.bool(forKey: "ISENABLESENDADDRESS"){
            IndentityRequest.requestIndentiy(completion: { (identityAddress, statuCode) in
                Crashlytics.sharedInstance().setUserIdentifier(identityAddress.address)
            }) { (error) in }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendPushNotificationToke(notification:)),
                                               name: Notification.Name("FCMToken"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        setStatusBarStyle(.default)
//        getVoucherList()
        let notifMessage: [String: Any] = [
            "to" : "fcm token you need to send the notification",
            "notification" :
                ["title" : "title you want to display", "body": "content you need to display", "badge" : 1, "sound" : "default"]
        ]
        
        sendPushNotification(notData: notifMessage)
        
        
    }
    
    @objc func segmentSelected(sender:HBSegmentedControl) {
       
        if (sender.selectedIndex == 0 ){
            walletCase = WalletCase.token
            self.tableView.reloadData()
        }else if (sender.selectedIndex == 1){
            walletCase = WalletCase.assets
            self.tableView.reloadData()
        }else if (sender.selectedIndex == 2){
            walletCase = WalletCase.passes
            self.tableView.reloadData()
        }
    }
    
    @objc fileprivate func sendPushNotificationToke(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        IndentityRequest.sendTokenNotification(token: (userInfo["token"] as? String)! ,completion: { (statusCode) in
            
        }) { (error) in }
    }
    
    func getVoucherList() {
        VoucherRequest.getVoucherList(completion: { response, _ in
            self.vouhers.removeAllObjects()
            for voucher in response {
                if (voucher as! Voucher).product != nil {
                    if (voucher as! Voucher).transactions.count == 0 {
                        self.vouhers.add(voucher)
                    }
                } else {
                    self.vouhers.add(voucher)
                }
            }
            if self.vouhers.count == 0 {
                self.emptyTextLabe.isHidden = true
            } else {
                self.emptyTextLabe.isHidden = true
            }
            self.tableView.reloadData()
            self.stopAnimating(nil)
        }) { _ in
            self.stopAnimating(nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToKindPaket" {
            let passVC = segue.destination as! MAGeneralPassViewController
            (passVC.contentViewController as! PassViewController).voucher = vouhers[(self.tableView.indexPathForSelectedRow?.row)!] as? Voucher
            (passVC.bottomViewController as! MABottomVoucherViewController).voucher = vouhers[(self.tableView.indexPathForSelectedRow?.row)!] as? Voucher
        } else if segue.identifier == "goToVoucherProduct" {
            let passVC = segue.destination as! MAContenProductVoucherViewController
            (passVC.contentViewController as! MAProductVoucherViewController).voucher = vouhers[(self.tableView.indexPathForSelectedRow?.row)!] as? Voucher
            (passVC.bottomViewController as! MABottomProductViewController).voucher = vouhers[(self.tableView.indexPathForSelectedRow?.row)!] as? Voucher
        }
    }
}

// MARK: UITableViewDelegate

extension WalletViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if walletCase != .token {
            return 2
        }else if walletCase == .passes{
            return 2
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
        
        switch walletCase {
        case .token?:
            let cellWalletSecond = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! WalletSecondTableViewCell
            if indexPath.row == 0{
                cellWalletSecond.priceLabel.text = "10,509876"
                cellWalletSecond.typeCoinLabel.text = "ETH"
            } else if indexPath.row == 1{
                cellWalletSecond.priceLabel.text = "200,85"
                cellWalletSecond.typeCoinLabel.text = "BAT"
                cellWalletSecond.typeCoinImageView.image = UIImage.init(named: "bat")
            }else if indexPath.row == 2{
                cellWalletSecond.priceLabel.text = "225,57"
                cellWalletSecond.typeCoinLabel.text = "ERC-20 Token"
                cellWalletSecond.typeCoinImageView.image = UIImage.init(named: "erc")
            }
            
            cell = cellWalletSecond
            break
            
        case .assets?:
            let cellWalletOwner = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! MAWalletOwnerTableViewCell
            cellWalletOwner.delegate = self
            if indexPath.row == 0{
                cellWalletOwner.headNameLabel.text = "APPARTEMENT"
                cellWalletOwner.productNameLabel.text = "Groningen"
                cellWalletOwner.marcLabel.text = "Ulgersmaweg 35, 9731BK"
            }else if indexPath.row == 1{
                cellWalletOwner.headNameLabel.text = "AUTO"
                cellWalletOwner.productNameLabel.text = "Tesla Model 3"
                cellWalletOwner.marcLabel.text = "9731 EU"
                cellWalletOwner.typeIconImage.image = UIImage.init(named: "sportsCar")
            }
            cell = cellWalletOwner
            
        default:
            let cellWallet = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! MAWaletVoucherTableViewCell
            if indexPath.row == 0{
                cellWallet.voucherTitleLabel.text = "Zwemregeling"
                cellWallet.priceLabel.text = "€ 122,67"
            }else if indexPath.row == 1{
                cellWallet.voucherTitleLabel.text = "Meedoen"
                cellWallet.voucherImage.image = #imageLiteral(resourceName: "Logo-Nijmgen-4-3")
            }
            cell = cellWallet
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let voucher = vouhers[indexPath.row] as! Voucher
//        if voucher.product != nil {
//            performSegue(withIdentifier: "goToVoucherProduct", sender: nil)
//        } else {
//            performSegue(withIdentifier: "goToKindPaket", sender: nil)
//        }
//        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: SwipeTableViewCellDelegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let transctionAction = SwipeAction(style: .default, title: "Transaction") { _, _ in
        }
        transctionAction.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1.0)
        transctionAction.textColor = UIColor.lightGray
        transctionAction.image = UIImage(named: "transactionIcon")
        transctionAction.font = UIFont(name: "SFUIText-Bold", size: 10.0)
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, _ in
        }
        deleteAction.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1.0)
        deleteAction.textColor = UIColor.lightGray
        deleteAction.image = UIImage(named: "removeIcon")
        deleteAction.font = UIFont(name: "SFUIText-Bold", size: 10.0)
        
        if orientation == .left {
            return [transctionAction]
        } else {
            return [deleteAction]
        }
        
    }
    
    func closePinCodeView(typeClose: typeClose) {
        if typeClose == .logout{
            logOutProfile()
        }
    }
    
    func logOutProfile(){
        UserDefaults.standard.set("", forKey: ALConstants.kPincode)
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController:HiddenNavBarNavigationController = storyboard.instantiateInitialViewController() as! HiddenNavBarNavigationController
        let firstPageVC:UIViewController = storyboard.instantiateViewController(withIdentifier: "firstPage") as UIViewController
        navigationController.viewControllers = [firstPageVC]
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension UIViewController {
    func createAnimationLoader() {
        view.backgroundColor = UIColor(red: CGFloat(237 / 255.0), green: CGFloat(85 / 255.0), blue: CGFloat(101 / 255.0), alpha: 1)
        
        let cols = 4
        let rows = 8
        let cellWidth = Int(view.frame.width / CGFloat(cols))
        let cellHeight = Int(view.frame.height / CGFloat(rows))
        (NVActivityIndicatorType.ballPulse.rawValue ... NVActivityIndicatorType.circleStrokeSpin.rawValue).forEach {
            let x = ($0 - 1) % cols * cellWidth
            let y = ($0 - 1) / cols * cellHeight
            let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                type: NVActivityIndicatorType(rawValue: $0)!)
            let animationTypeLabel = UILabel(frame: frame)
            
            animationTypeLabel.text = String($0)
            animationTypeLabel.sizeToFit()
            animationTypeLabel.textColor = UIColor.white
            animationTypeLabel.frame.origin.x += 5
            animationTypeLabel.frame.origin.y += CGFloat(cellHeight) - animationTypeLabel.frame.size.height
            
            activityIndicatorView.padding = 20
            if $0 == NVActivityIndicatorType.orbit.rawValue {
                activityIndicatorView.padding = 0
            }
            self.view.addSubview(activityIndicatorView)
            self.view.addSubview(animationTypeLabel)
            activityIndicatorView.startAnimating()
        }
    }
    
}


extension WalletViewController{
    func sendPushNotification(notData: [String: Any]) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAd3YHFHw:APA91bGQlkoMIc4n0fCMK2d6J0GpH-tqOeDOBGTj1c2xvEVUuc9Ap1-F7exHdDKeyE7FHQn1egXTWVLNq-0ePYg7S-oGJrlQCaNqbZhyTUwZBUeS6m0akbspfX8cPP_dxGBUWdllFDdB", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: notData, options: [])
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response ?? "")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print(responseString ?? "")
        }
        task.resume()
    }
}
