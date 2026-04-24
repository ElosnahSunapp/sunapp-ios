//
//  StoreCom.swift
//  SunApp
//
//  Created by Phillip Løjmand on 22/01/2019.
//  Copyright © 2019 casafox. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit
import StoreKit
import Firebase

class ProductButton: UIButton{
  var saveBackgroundColor = UIColor.purple.cgColor
  
  override var isHighlighted:Bool{
    get{
      return super.isHighlighted
    }
    set{
      if(newValue != super.isHighlighted){
        if newValue{
          layer.backgroundColor = UIColor.purple.cgColor
        }else{
          layer.backgroundColor = saveBackgroundColor
        }
        super.isHighlighted = newValue
      }
    }
  }
}


class StoreCom: UIViewController{
  
  var getPremiumButton:ProductButton!
  var getPremiumButtonYearly:ProductButton!
  var getPremiumButtonLifetime:ProductButton!
  var monthlylabel:UILabel!
  var yearlylabel:UILabel!
  var lifetimelabel:UILabel!
  var savelabel:UILabel!
  var hasAppeared = false
  var restoringPurchases = 0
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
   // createGradientLayer()
    hasAppeared = true
    self.getInfo()
    tryPremiumForever()
  }
  
  override func viewDidAppear(_ animated: Bool) {
     Analytics.logEvent(AnalyticsEventScreenView,
     parameters: [AnalyticsParameterScreenName: "Premium View",
                  AnalyticsParameterScreenClass: "Storecom"])
   }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    let gl = createGradientLayer()

    let title = UILabel(frame: CGRect(x: 24, y: 64, width: Int(self.view.frame.width) - 48, height: 40))
    title.text = (Gb?.localizedString(forKey: "premium_title", value: nil, table: nil))!
    title.textColor = UIColor.white
    title.font = UIFont.systemFont(ofSize: 32)
    title.textAlignment = .center
    self.view.addSubview(title)
    
    var footerHeight = 110 + GlobalbuttonOffsetBottom
    
    var buttonMonthlyWidth = Int(Double(Globalwidth / 20) * 6)
    let buttonMonthlyHeight = 50
    var buttonMonthlyX = Globalwidth / 20 * 2 / 3
    var buttonMonthlyY = Globalheight - buttonMonthlyHeight - 16 - footerHeight
    
    var buttonYearlyWidth = buttonMonthlyWidth
    let buttonYearlyHeight = 50
    var buttonYearlyX = Int(Double(Globalwidth / 20) * 7)
    var buttonYearlyY = Globalheight - buttonMonthlyHeight - 16 - footerHeight
    
    var buttonLifetimeWidth = buttonMonthlyWidth
    var buttonLifetimeHeight = buttonMonthlyHeight
    var buttonLifetimeX = Int(Double(Globalwidth / 20) * 13.333)
    var buttonLifetimeY = buttonMonthlyY
    
    let saveLabelHeight = 16
    if(UI_USER_INTERFACE_IDIOM() == .phone){
      //Width
      buttonMonthlyWidth = Int(Double(Globalwidth / 20) * 8.5)
      buttonLifetimeWidth = buttonMonthlyWidth
      buttonYearlyWidth = Globalwidth / 20 * 18
      
      //X
      buttonMonthlyX = Globalwidth / 20
      buttonYearlyX = Globalwidth / 20
      buttonLifetimeX = Int(Double(Globalwidth / 20) * 10.5)
      
      //Y
      buttonYearlyY = buttonMonthlyY + 70
      buttonLifetimeY = buttonMonthlyY
      
      footerHeight -= (10 + saveLabelHeight)
    }
    
    //Restore segment
    let restoreSegmentHeight = 48
    buttonMonthlyY -= restoreSegmentHeight
    buttonYearlyY -= restoreSegmentHeight
    buttonLifetimeY -= restoreSegmentHeight
    
    let restore_link = UILabel(frame: CGRect(x: Int(Globalwidth / 2) - 100, y: buttonYearlyY + buttonYearlyHeight + restoreSegmentHeight / 8 * 5, width: 200, height: 30))
    restore_link.textColor = UIColor.init(red: 48 / 255, green: 0.8, blue: 60 / 255, alpha: 1)
    restore_link.textAlignment = .center
    restore_link.font = UIFont.systemFont(ofSize: 16)
    restore_link.text = lString("restore_subscription")
    restore_link.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(restoreClicked))
    restore_link.addGestureRecognizer(tap)
    self.view.addSubview(restore_link)
    
    let scrollView = fadeScrollView(frame: CGRect(x: 0, y: 128, width: Globalwidth, height: buttonMonthlyY - 128 - 16))
    
    var startY = 0
    let spaceBetween = 15
    for i in 1...10{
      let featureText = (Gb?.localizedString(forKey: "premiumDesc\(i)", value: nil, table: nil))!
      if(featureText != "premiumDesc\(i)" && featureText != ""){
        startY = addPremiumFeatureDescription(view: scrollView, text: featureText, y: startY) + spaceBetween
      }
    }

    scrollView.contentSize = CGSize(width: Globalwidth, height: startY)
    self.view.addSubview(scrollView)
    
    
    getPremiumButton = ProductButton()
    getPremiumButton.frame = CGRect(x:buttonMonthlyX,y: buttonMonthlyY, width: buttonMonthlyWidth, height: buttonMonthlyHeight)
    getPremiumButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    getPremiumButton.titleLabel?.textAlignment = .center
    getPremiumButton.setTitle("\(GlobalPremiumMonthlyPrice) / \((Gb?.localizedString(forKey: "mo", value: nil, table: nil))!)", for: .normal)
    getPremiumButton.setTitleColor(UIColor.black, for: .normal)
    getPremiumButton.backgroundColor = .clear
    getPremiumButton.layer.cornerRadius = 5
    getPremiumButton.layer.backgroundColor = UIColor.init(red: 48 / 255, green: 60 / 255, blue: 0.8, alpha: 1).cgColor
    getPremiumButton.saveBackgroundColor = getPremiumButton.layer.backgroundColor!
    getPremiumButton.addTarget(self, action: #selector(getPremium), for: .touchUpInside)
    view.addSubview(getPremiumButton)
  
    getPremiumButtonLifetime = ProductButton()
    getPremiumButtonLifetime.frame = CGRect(x:buttonLifetimeX,y: buttonLifetimeY, width: buttonLifetimeWidth, height: buttonLifetimeHeight)
    getPremiumButtonLifetime.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    getPremiumButtonLifetime.titleLabel?.textAlignment = .center
    getPremiumButtonLifetime.setTitle("", for: .normal)
    getPremiumButtonLifetime.setTitleColor(UIColor.black, for: .normal)
    getPremiumButtonLifetime.backgroundColor = .clear
    getPremiumButtonLifetime.layer.cornerRadius = 5
    getPremiumButtonLifetime.layer.backgroundColor = UIColor.init(red: 207 / 255, green: 50 / 255, blue: 207 / 255, alpha: 1).cgColor
    getPremiumButtonLifetime.saveBackgroundColor = getPremiumButtonLifetime.layer.backgroundColor!
    getPremiumButtonLifetime.addTarget(self, action: #selector(getPremiumLifetime), for: .touchUpInside)
    view.addSubview(getPremiumButtonLifetime)
    
    getPremiumButtonYearly = ProductButton()
    getPremiumButtonYearly.frame = CGRect(x:buttonYearlyX,y: buttonYearlyY, width: buttonYearlyWidth, height: buttonMonthlyHeight)
    getPremiumButtonYearly.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    getPremiumButtonYearly.titleLabel?.textAlignment = .center
    getPremiumButtonYearly.setTitle("\(GlobalPremiumYearlyPrice) / \((Gb?.localizedString(forKey: "yr", value: nil, table: nil))!)", for: .normal)
    getPremiumButtonYearly.setTitleColor(UIColor.black, for: .normal)
    getPremiumButtonYearly.backgroundColor = .clear
    getPremiumButtonYearly.layer.cornerRadius = 5
    getPremiumButtonYearly.layer.backgroundColor = UIColor.init(red: 48 / 255, green: 0.8, blue: 60 / 255, alpha: 1).cgColor
    getPremiumButtonYearly.saveBackgroundColor = getPremiumButtonYearly.layer.backgroundColor!
    getPremiumButtonYearly.addTarget(self, action: #selector(getPremiumYearly), for: .touchUpInside)
    view.addSubview(getPremiumButtonYearly)
    
    monthlylabel = UILabel(frame: CGRect(x: buttonMonthlyX, y: buttonMonthlyY + 8, width: buttonMonthlyWidth, height: 30))
    monthlylabel.text = Gb?.localizedString(forKey: "monthly", value: nil, table: nil)
    monthlylabel.textColor = UIColor.white
    monthlylabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)
    monthlylabel.textAlignment = .center
    monthlylabel.isHidden = true
    self.view.addSubview(monthlylabel)
  
    lifetimelabel = UILabel(frame: CGRect(x: buttonLifetimeX, y: buttonLifetimeY + 8, width: buttonLifetimeWidth, height: 30))
    lifetimelabel.textColor = UIColor.white
    lifetimelabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)
    lifetimelabel.textAlignment = .center
    lifetimelabel.isHidden = true
    self.view.addSubview(lifetimelabel)
    
    yearlylabel = UILabel(frame: CGRect(x: buttonYearlyX, y: buttonYearlyY + 8, width: buttonYearlyWidth, height: 30))
    yearlylabel.textColor = UIColor.white
    yearlylabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)
    yearlylabel.textAlignment = .center
    yearlylabel.isHidden = true
    self.view.addSubview(yearlylabel)
  
    savelabel = UILabel(frame: CGRect(x: buttonYearlyX - 20, y: buttonYearlyY + buttonYearlyHeight + 6, width: buttonYearlyWidth + 40, height: saveLabelHeight))
  
    savelabel.textColor = UIColor.gray
    if(UI_USER_INTERFACE_IDIOM() == .phone){
      savelabel.font = UIFont.systemFont(ofSize: CGFloat(saveLabelHeight - 2), weight: UIFont.Weight.semibold)
    }else{
      savelabel.font = UIFont.systemFont(ofSize: CGFloat(saveLabelHeight - 2) * 0.8, weight: UIFont.Weight.semibold)
    }
    
    savelabel.textAlignment = .center
    self.view.addSubview(savelabel)
    
    
    let backbutton = UIButton(frame: CGRect(x: 18, y: 36, width: 32, height: 32))
    backbutton.setImage(UIImage(named: "ic_back.png"), for: .normal)
    backbutton.imageView?.contentMode = .scaleAspectFit
    backbutton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
    self.view.addSubview(backbutton)
    
    
    
    var termsSize = 16
    var termsOffest = 4
    if(UI_USER_INTERFACE_IDIOM() == .phone){
      termsSize = 13
      termsOffest = 32
    }
    
    let termsView = fadeScrollView(frame: CGRect(x: 0, y: Globalheight - footerHeight + termsOffest, width: Globalwidth, height: footerHeight - termsOffest))
    

    
    let terms = UILabel(frame: CGRect(x: Globalwidth / 14, y: 4, width: Int(Globalwidth / 7 * 6), height: 40))
    terms.text = lString("payment_terms")
    terms.textColor = UIColor.lightGray
    terms.font = UIFont.systemFont(ofSize: CGFloat(termsSize))
    terms.numberOfLines = 0
    terms.lineBreakMode = NSLineBreakMode.byWordWrapping
    terms.textAlignment = .center
    terms.sizeToFit()
    termsView.addSubview(terms)
    
    var termsY = Int(max(terms.frame.height + 8,32))
    
    let privacy_link = UILabel(frame: CGRect(x: Int(Globalwidth / 3 * 2) - 100, y: termsY, width: 200, height: 16))
    privacy_link.textColor = UIColor.blue
    privacy_link.textAlignment = .center
    privacy_link.font = UIFont.systemFont(ofSize: 14)
    privacy_link.text = lString("privacy_policy")
    privacy_link.isUserInteractionEnabled = true
    let privacy_link_tap = UITapGestureRecognizer(target: self, action: #selector(privacy_clicked))
    privacy_link.addGestureRecognizer(privacy_link_tap)
    termsView.addSubview(privacy_link)
    
    let terms_use = UILabel(frame: CGRect(x: Int(Globalwidth / 3) - 100, y: termsY, width: 200, height: 16))
    terms_use.textColor = UIColor.blue
    terms_use.textAlignment = .center
    terms_use.font = UIFont.systemFont(ofSize: 14)
    terms_use.text = lString("terms_of_use")
    terms_use.isUserInteractionEnabled = true
    let terms_use_tap = UITapGestureRecognizer(target: self, action: #selector(terms_use_clicked))
    terms_use.addGestureRecognizer(terms_use_tap)
    termsView.addSubview(terms_use)
    
    termsView.contentSize = CGSize(width: Globalwidth, height: termsY + 16 + GlobalbuttonOffsetBottom)
    
    self.view.addSubview(termsView)
    
    
    updateButtonTexts()
  }
  
  @objc func privacy_clicked(sender:UITapGestureRecognizer){
    let url = URL(string: "http://www.casafox.dk/privacypolicy.html")
    
    if(UIApplication.shared.canOpenURL(url!)){
      UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
  }

  @objc func terms_use_clicked(sender:UITapGestureRecognizer){
    let url = URL(string: "http://www.casafox.dk/termsofuse.html")
    
    if(UIApplication.shared.canOpenURL(url!)){
      UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
  }
  
  @objc func restoreClicked(sender:UITapGestureRecognizer){
    restoringPurchases = 2
    restorePurchases()
    }
  
  func updateButtonTexts(){
    if(monthlylabel != nil){
      monthlylabel.text = Gb?.localizedString(forKey: "monthly", value: nil, table: nil)
      yearlylabel.text = Gb?.localizedString(forKey: "yearly", value: nil, table: nil)
      lifetimelabel.text = Gb?.localizedString(forKey: "lifetime", value: nil, table: nil)
      
      if(GlobalHaveRetrievedProductInfo){
        getPremiumButtonYearly.setTitle("\(GlobalPremiumYearlyPrice) / \((Gb?.localizedString(forKey: "year", value: nil, table: nil))!)", for: .normal)
        getPremiumButton.setTitle("\(GlobalPremiumMonthlyPrice) / \((Gb?.localizedString(forKey: "month", value: nil, table: nil))!)", for: .normal)
        getPremiumButtonLifetime.setTitle("\(GlobalPremiumLifetimePrice) / \((Gb?.localizedString(forKey: "lifetime", value: nil, table: nil))!)", for: .normal)
        
        getPremiumButton.setTitleColor(UIColor.white, for: .normal)
        getPremiumButtonYearly.setTitleColor(UIColor.white, for: .normal)
        getPremiumButtonLifetime.setTitleColor(UIColor.white, for: .normal)
        
        var monthlyYearlyprice = ceil(Double(GlobalPremiumYearlyInt) / 12 * 100) / 100
        var monthlyYearlyText = GlobalPremiumMonthlyPrice

        let regex = try! NSRegularExpression(pattern: "[0-9]+[,.0-9]*", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, monthlyYearlyText.count)
        monthlyYearlyText = regex.stringByReplacingMatches(in: monthlyYearlyText, options: [], range: range, withTemplate: "\(monthlyYearlyprice)")
        var percentage = Int((1.0 - Double(GlobalPremiumYearlyInt)/Double(GlobalPremiumMonthyInt * 12)) * 100)
        if(percentage >= 10){
          savelabel.text = "(\(lString("save_description")) \(monthlyYearlyText) / \(lString("mo")) \(lString("save")) \(percentage)%)"
          //"\((Gb?.localizedString(forKey: "save", value: nil, table: nil))!) \(percentage) %"
          savelabel.isHidden = false
        }else{
          savelabel.isHidden = true
        }
      }else{
        getPremiumButtonLifetime.setTitle("", for: .normal)
        getPremiumButtonYearly.setTitle("", for: .normal)
        getPremiumButton.setTitle("", for: .normal)
        savelabel.isHidden = true
      }
    }
  }
  
  func addPremiumFeatureDescription(view: UIView, text: String, y: Int) -> Int{
    var scale = 1.0
    if(UI_USER_INTERFACE_IDIOM() == .pad){
      scale = 1.5
    }
    
    var internY = y
    let image = UIImageView(frame: CGRect(x: 24, y: internY + 1, width: Int(20.0 * scale), height: Int(20.0 * scale)))
    image.image = GlobaltickImage
    view.addSubview(image)
    
    let imgDescX = Int(24 + 42 * scale)
    
    let imageDescription = UILabel(frame: CGRect(x: imgDescX, y: internY, width: Int(self.view.frame.width) - imgDescX - 24, height: Int(40.0 * scale)))
    imageDescription.text = text
    imageDescription.textColor = UIColor.white
    imageDescription.font = UIFont.systemFont(ofSize: CGFloat(18 * scale))
    imageDescription.numberOfLines = 0
    imageDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
    imageDescription.sizeToFit()
    view.addSubview(imageDescription)
    
    internY += Int(max(imageDescription.frame.height + CGFloat(8 * scale * scale),CGFloat(32 * scale)))
    return internY
  }
  
  func createGradientLayer() -> CAGradientLayer{
    let colorTop = UIColor(red: 67.0 / 255.0, green: 198.0 / 255.0, blue: 172.0 / 255.0, alpha: 1)
    let colorBottom = UIColor(red: 248.0 / 255.0, green: 255.0 / 255.0, blue: 174.0 / 255.0, alpha: 1.0)
    
    let gl = CAGradientLayer()
    gl.frame = self.view.bounds
    gl.colors = [colorTop.cgColor, colorBottom.cgColor]
    self.view.layer.addSublayer(gl)
    return gl
  }
  
  @objc func getPremium(sender: UIButton!){
    if(!GlobalPremiumForever){
      purchase(purchase: RegisteredPurchase.SunAppPremiumMonthly)
    }else{
      self.present(self.alertWithTitle(title: lString("failed"), message: lString("already_premium")), animated: true)
    }
  }
  
  @objc func getPremiumYearly(sender: UIButton!){
    if(!GlobalPremiumForever){
      purchase(purchase: RegisteredPurchase.SunAppPremiumYearly)
    }else{
      self.present(self.alertWithTitle(title: lString("failed"), message: lString("already_premium")), animated: true)
    }
  }
  
  @objc func getPremiumLifetime(sender: UIButton!){
    if(GlobalhasPremium){
      if(GlobalPremiumForever){
        self.present(self.alertWithTitle(title: lString("failed"), message: lString("already_premium")), animated: true)
        return
      }else{
        let alert = UIAlertController(title: lString("already_premium"), message: lString("make_sure_cancel"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lString("continue"), style: .default) { _ in
          self.purchase(purchase: RegisteredPurchase.SunAppPremiumLifetime)
        })
        alert.addAction(UIAlertAction(title: lString("Manage subscription"), style: .cancel) { _ in
          UIApplication.shared.openURL(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
        })
        self.present(alert, animated: true)
        return
      }
    }
    purchase(purchase: RegisteredPurchase.SunAppPremiumLifetime)
  }

  @objc func doneClicked(sender: UIButton!){
    print("Done clicked")
    GlobalArView = true
    dismiss(animated: true, completion: nil)
  }
  
  class NetworkActivityIndicatorManager : NSObject {
    
    private static var loadingCount = 0
    
    class func NetworkOperationStarted(){
      if loadingCount == 0{
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      }
      loadingCount += 1
    }
    class func networkOperationFinished(){
      if loadingCount > 0{
        loadingCount -= 1
      }
      if loadingCount == 0{
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
    }
  }
  
  public func onLaunch(){
    print("onLaunch")
    SwiftyStoreKit.completeTransactions(completion: { result in
      
      /*var state = 0
      
      for purchase in result {
        if purchase.transaction.transactionState == SKPaymentTransactionState.purchased {
          print(purchase.transaction.transactionDate)
          state = 1
          break
        }else{
          state = 2
        }
      }*/
      print("Completed")
    })
    print("Check Premium")
    self.checkPremium()
    print("Get info")
    self.getInfo()
  }
  
  public func checkPremium(){
    let savedPremiumState = UserDefaults.standard.object(forKey: "premiumEnd")
    let savedPremiumNumber = savedPremiumState as? Int64
    var canCheckPremium = false
    if(savedPremiumState != nil && savedPremiumNumber != -1){
      canCheckPremium = true
    }else if(hasAppeared){
      canCheckPremium = true
    }
    if(canCheckPremium){
      verifyNonConsumables(product: RegisteredPurchase.SunAppPremiumLifetime)
      verifySubscription(products: [RegisteredPurchase.SunAppPremiumMonthly,RegisteredPurchase.SunAppPremiumYearly])
    }
  }
  
  func getInfo(){
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    let bundleID = Bundle.main.bundleIdentifier
    let monthlyID = bundleID! + "." + RegisteredPurchase.SunAppPremiumMonthly.rawValue
    let yearlyID = bundleID! + "." + RegisteredPurchase.SunAppPremiumYearly.rawValue
    let lifetimeID = bundleID! + "." + RegisteredPurchase.SunAppPremiumLifetime.rawValue
    SwiftyStoreKit.retrieveProductsInfo([monthlyID,yearlyID,lifetimeID], completion: {
      result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      
      let products = result.retrievedProducts
      
      for product in products{
        print(product.productIdentifier)
        if (product.productIdentifier == monthlyID){
          GlobalPremiumMonthlyPrice = product.localizedPrice ?? ""
          GlobalPremiumMonthyInt = Double(product.price)
          GlobalHaveRetrievedProductInfo = true
          self.updateButtonTexts()
        }
        if (product.productIdentifier == yearlyID){
          GlobalPremiumYearlyPrice = product.localizedPrice ?? ""
          GlobalPremiumYearlyInt = Double(product.price)
          GlobalHaveRetrievedProductInfo = true
          self.updateButtonTexts()
        }
        if (product.productIdentifier == lifetimeID){
          GlobalPremiumLifetimePrice = product.localizedPrice ?? ""
          GlobalPremiumLifetimeInt = Double(product.price)
          GlobalHaveRetrievedProductInfo = true
          self.updateButtonTexts()
        }
      }
      print("presentproductretrieval")
      if(!GlobalHaveRetrievedProductInfo){
        //Display failure
        self.present(self.alertForProductRetrievalInfo(result: result), animated: false)
      }
    })
  }
  
  func purchase(purchase: RegisteredPurchase){
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    let bundleID = Bundle.main.bundleIdentifier
    SwiftyStoreKit.purchaseProduct(bundleID! + "." + purchase.rawValue, completion: {
      result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      print("ok")
      if case .success(let product) = result {
        
        if (product.productId == bundleID! + "." + RegisteredPurchase.SunAppPremiumMonthly.rawValue){
          goPremium(Calendar.current.date(byAdding: .day, value: 40, to: Date.init())!)
          print("Subscribed")
        }
        if (product.productId == bundleID! + "." + RegisteredPurchase.SunAppPremiumYearly.rawValue){
          goPremium(Calendar.current.date(byAdding: .day, value: 377, to: Date.init())!)
          print("Subscribed Yearly")
        }
        
        if (product.productId == bundleID! + "." + RegisteredPurchase.SunAppPremiumLifetime.rawValue){
          goPremiumForever()
          print("Subscribed Lifetime")
        }
        
        if product.needsFinishTransaction{
          
          SwiftyStoreKit.finishTransaction(product.transaction)
        }
       
      }
    self.present(self.alertForPurchaseResult(result: result), animated: false)
    })
  }
  
  func alertForRestorePurchases(result: RestoreResults) -> UIAlertController{
    if(result.restoreFailedPurchases.count > 0){
      print("Restore Failed: \(result.restoreFailedPurchases)")
      return alertWithTitle(title: "Restore Failed", message: "Unknown Error. Please Contact Support")
    }else if result.restoredPurchases.count > 0{
      return alertWithTitle(title: "Purchases Restored", message: "All purchases have been restored")
    }else{
      return alertWithTitle(title: "Nothing To Restore", message: "You haven't purchases anything")
    }
  }
  
  func restorePurchases(){
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    SwiftyStoreKit.restorePurchases(completion: {
      result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      for product in result.restoredPurchases{
        SwiftyStoreKit.finishTransaction(product.transaction)
        if(product.productId == "dk.casafox.sunapp.SunAppPremiumLifetime" && product.originalTransaction?.transactionState == SKPaymentTransactionState.purchased){
          goPremiumForever()
          self.present(self.alertWithTitle(title: "\(lString("success"))", message: "\(lString("restored_lifetime"))"),animated: true)
          return
        }
      }
      self.checkPremium()
     // self.present(self.alertForRestorePurchases(result: result), animated: false)
    })
  }
  
  func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
    switch result{
    case .purchased(let expiryDate, _):
      goPremium(Calendar.current.date(byAdding: .day, value: 9, to: expiryDate)!)
      return alertWithTitle(title: "\(lString("success"))", message: "\(lString("restored"))")
    case .expired(let expiryDate, _):
      losePremium()
      return alertWithTitle(title: "\(lString("failed"))",message: "\(lString("subscription_cancelled"))")
    case .notPurchased:
      losePremium()
      return alertWithTitle(title: "\(lString("failed"))", message: "\(lString("no_subscription"))")
    }
  }
  
  func verifyNonConsumables(product: RegisteredPurchase){
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: GlobalsharedSecret)
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: { result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      switch result {
      case .success(let receipt):
        //Verify the purchase of a non-consumable
        let productId = "dk.casafox.sunapp.SunAppPremiumLifetime"
        print(productId)
       
        let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productId, inReceipt: receipt)
        print(self.restoringPurchases)
        if(self.restoringPurchases > 0){
          self.restoringPurchases -= 1
          
          switch purchaseResult{
            case .purchased(let receiptItem):
              print("\(productId) is purchased: \(receiptItem)")
              goPremiumForever()
              self.present(self.alertWithTitle(title: "\(lString("success"))", message: "\(lString("restored_lifetime"))"),animated: true)
            case .notPurchased:
              print("The user has never purchased \(productId)")
              if(self.restoringPurchases == 0){
                self.present(self.alertWithTitle(title: "\(lString("failed"))", message: "\(lString("no_subscription"))"),animated: true)
              }
            }
          }

      case .error(let error):
        if(self.restoringPurchases > 0){
          self.present(self.alertWithTitle(title: lString("failed"), message: lString("could_not_verify")), animated: true)
          self.restoringPurchases -= 1
        }
        break
        //self.present(self.alertForVerifyReceipt(result: result),animated: true);
      }
      print("Premium \(GlobalhasPremium)")
    })
  }
  
  func verifySubscription(products: [RegisteredPurchase]){
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: GlobalsharedSecret)
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: { result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      switch result {
      case .success(let receipt):
        //Verify the purchase of a subscription
        let bundleID = Bundle.main.bundleIdentifier
        var productIDs = Set<String>()
        for product in products{
          productIDs.insert(bundleID! + "." + product.rawValue)
        }
        let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIDs, inReceipt: receipt)
        
       // let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: SubscriptionType.autoRenewable, productId: productID, inReceipt: receipt)
        
        let alert = self.alertForVerifySubscription(result: purchaseResult)
        if(self.restoringPurchases > 0){
          self.restoringPurchases -= 1
          if(self.restoringPurchases == 0 && !GlobalhasPremium){
            self.present(alert,animated: true);
          }else if(GlobalhasPremium){
            self.present(alert,animated: true);
          }
        }
      case .error(let error):
        if(self.restoringPurchases > 0){
          self.present(self.alertWithTitle(title: lString("failed"), message: lString("could_not_verify")), animated: true)
          self.restoringPurchases -= 1
        }
        break
        //self.present(self.alertForVerifyReceipt(result: result),animated: true);
      }
      print("Premium \(GlobalhasPremium)")
    })
  }
  
  /*func verifyReceipt(){
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: GlobalsharedSecret)
    SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: { result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      
      self.present(self.alertForVerifyReceipt(result: result), animated: false)
      
      if case .error(let error) = result{
        if case.noReceiptData = error{
          self.refreshReceipt()
        }
      }
    })
  }*/
  
  /*func refreshReceipt(){
    NetworkActivityIndicatorManager.NetworkOperationStarted()
    SwiftyStoreKit.fetchReceipt(forceRefresh: true, completion: { result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      self.present(self.alertForRefreshReceipt(result: result), animated: false)
    })
  }*/
  
  /*func alertForRefreshReceipt(result: FetchReceiptResult) -> UIAlertController{
    switch result {
    case .success(let receiptData):
      return alertWithTitle(title: "Receipt refreshed", message: "Receipt refresh success: \(receiptData.base64EncodedString)")
    case .error:
      return alertWithTitle(title: "Receipt refresh failed", message: "Receipt refresh failed")
    }
  }
  
  
  func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
    switch result {
    case.success:
      return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
    case.error(let error):
      switch error{
      case.noReceiptData:
        return alertWithTitle(title: "Receipt Verification", message: "No receipt data found. Try again")
      default:
        return alertWithTitle(title: "Receipt Verification", message: "Receipt Verification failed")
      }
    }
  }*/
  
  func alertWithTitle(title: String, message: String) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: lString("ok"), style: .cancel, handler: nil))
    return alert
  }
  
  func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
    print("alertForProductRetrievalInfo")
    if let product = result.retrievedProducts.first{
      let priceString = product.localizedPrice!
      print("\(product.localizedDescription) - \(priceString)")
      return alertWithTitle(title: product.localizedTitle,message: "\(product.localizedDescription) - \(priceString)")
    }
    else if let invalidProductID = result.invalidProductIDs.first{
      print("Invalid product identifier \(invalidProductID)")
      return alertWithTitle(title: lString("failed_to_retrieve"), message: "Invalid product identifier \(invalidProductID)")
    }else{
      let errorString = result.error?.localizedDescription ?? lString("unknownError")
      print(errorString)
      return alertWithTitle(title: lString("failed_to_retrieve"), message: errorString)
    }
  }
  
  func alertForPurchaseResult(result: PurchaseResult) -> UIAlertController {
    switch result {
    case .success(let product):
      print("Purchase successful: \(product.productId)")
      
      return alertWithTitle(title: lString("success"), message: lString("subscribed"))
      
    case .error(let error):
      print("Purchase Failed: \(error)")
      if (error.code == SKError.clientInvalid){
        return alertWithTitle(title: lString("failed"), message: lString("unknownError"))
      }
      
      if (error.code == SKError.paymentCancelled){
        return alertWithTitle(title: lString("failed"), message: lString("cancelled"))
      }
      
      if (error.code == SKError.paymentInvalid){
        return alertWithTitle(title: lString("failed"), message: lString("payment_invalid"))
      }
      
      if (error.code == SKError.paymentNotAllowed){
        return alertWithTitle(title: lString("failed"), message: lString("not_authorized"))
      }
      
      if (error as NSError).domain == SKErrorDomain{
        return alertWithTitle(title: lString("failed"), message: lString("no_internet"))
      }else{
        return alertWithTitle(title: lString("failed"), message: "Unknown error, please contact support.")
      }
    }
  }
}

fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
  return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
