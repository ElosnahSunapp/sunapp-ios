//
//  CalibrateViewController.swift
//  Sun App
//
//  Created by Phillip Løjmand on 13/09/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CalibrateViewController: UIViewController
{
  var calibrateTitle: UILabel!
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print("dims3")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 26, width: Globalwidth, height: 44))
    self.view.addSubview(navBar)
    let navItem = UINavigationItem(title: (Gb?.localizedString(forKey: "calibrate", value: nil, table: nil))!)
    let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneClicked))
    navItem.rightBarButtonItem = doneItem
    navBar.setItems([navItem], animated: false)
    
    calibrateTitle = UILabel(frame: CGRect(x: 16, y: 80, width: Globalwidth - 32, height: 30))
    calibrateTitle.textColor = UIColor.darkGray
    calibrateTitle.font = UIFont(name: "SofiaPro-Bold", size: CGFloat(20))
    calibrateTitle.text = (Gb?.localizedString(forKey: "compas_accuracy", value: nil, table: nil))!
    updateAccuracy()
    self.view.addSubview(calibrateTitle)
    
    let calibrateAutoDescription = UILabel(frame: CGRect(x: 16, y: 105, width: Globalwidth - 32, height: 70))
    calibrateAutoDescription.textColor = UIColor.darkGray
    calibrateAutoDescription.numberOfLines = 2
    calibrateAutoDescription.text = (Gb?.localizedString(forKey: "calibrate_the_internal_compass", value: nil, table: nil))!
    self.view.addSubview(calibrateAutoDescription)
    
    let calibrateAutoGIF = UIImage.gifImageWithName("ic_calibrate")
    let calibrateAutoView = UIImageView(image: calibrateAutoGIF)
    let autoHeight = min((Float(Globalheight) / 2 - 175) * 0.85, (Float(Globalwidth) - 80) * 3 / 5)
    let autoWidth = autoHeight * 5 / 3
    let verSpace = (Float(Globalheight) / 2 - 175) - autoHeight
    calibrateAutoView.frame = CGRect(x: Int((Float(Globalwidth) - autoWidth) / 2), y: Int(175 + verSpace / 2), width: Int(autoWidth), height: Int(autoHeight))
    view.addSubview(calibrateAutoView)
    
    let calibrateManualDescription = UILabel(frame: CGRect(x: 16, y: Globalheight / 2, width: Globalwidth - 32, height: 100))
    calibrateManualDescription.textColor = UIColor.darkGray
    calibrateManualDescription.numberOfLines = 4
    if(GlobalsunPos.alt() < 0){
      calibrateManualDescription.text = (Gb?.localizedString(forKey: "manual_calibration_night", value: nil, table: nil))!
    }else{
    calibrateManualDescription.text = (Gb?.localizedString(forKey: "you_can_also_manually_calibrate", value: nil, table: nil))!
    }
    self.view.addSubview(calibrateManualDescription)
    
    
    let buttonWidth = 120

    let manualHeight = min(((Float(Globalheight) - Float(buttonWidth) / 2 - 16) - (Float(Globalheight) / 2 + 100)) * 0.8, (Float(Globalwidth) - 80) / 2)
    
    let manualWidth = autoHeight * 2
    let manualverSpace = ((Float(Globalheight) - Float(buttonWidth) / 2 - 16) - (Float(Globalheight) / 2 + 100)) - autoHeight
    
    let calibrateManualGIF = UIImage.gifImageWithName("ic_howtocalibrate")
    let calibrateManualView = UIImageView(image: calibrateManualGIF)
    calibrateManualView.frame = CGRect(x: Int((Float(Globalwidth) - manualWidth) / 2), y: Int(Float(Globalheight) / 2 + 100 + manualverSpace / 2), width: Int(manualWidth), height: Int(manualHeight))
    view.addSubview(calibrateManualView)
    
    
    
    let calibrateManualButton = UIButton()
    var horButtonsOffset = 0
    if(GlobalazimuthOffset != 0){
      horButtonsOffset = Int(Float(buttonWidth) * 0.6)
    }
    calibrateManualButton.frame = CGRect(x: Globalwidth / 2 - buttonWidth / 2 - horButtonsOffset,y: Globalheight - buttonWidth / 2 - 16, width: buttonWidth, height: buttonWidth / 2)

    calibrateManualButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    calibrateManualButton.titleLabel?.textAlignment = .center
    calibrateManualButton.setTitle((Gb?.localizedString(forKey: "manual_calibration", value: nil, table: nil))!, for: .normal)
    calibrateManualButton.setTitleColor(UIColor.white, for: .normal)
    calibrateManualButton.backgroundColor = .clear
    calibrateManualButton.layer.cornerRadius = 5
    if(GlobalsunPos.alt() < 0){
      calibrateManualButton.layer.backgroundColor = UIColor.gray.cgColor
    }else{
    calibrateManualButton.layer.backgroundColor = UIColor.init(red: 1, green: 64 / 255, blue: 80 / 255, alpha: 1).cgColor
    }
    
    calibrateManualButton.layer.shadowOffset = CGSize(width: 0, height: 5)
    let shadowPath = UIBezierPath(roundedRect: calibrateManualButton.bounds, cornerRadius: calibrateManualButton.layer.cornerRadius)
    calibrateManualButton.layer.shadowPath = shadowPath.cgPath
    calibrateManualButton.layer.shadowOpacity = Float(0.5)
    calibrateManualButton.layer.shadowColor = UIColor.black.cgColor
    if(GlobalsunPos.alt() > 0){
    calibrateManualButton.addTarget(self, action: #selector(manualCalibrate), for: .touchUpInside)
    }
    view.addSubview(calibrateManualButton)
    if(GlobalazimuthOffset != 0  || GlobalverticalOffset != 0){
      let calibrateresetButton = UIButton()
      calibrateresetButton.frame = CGRect(x: Globalwidth / 2 - buttonWidth / 2 + horButtonsOffset,y: Globalheight - buttonWidth / 2 - 16, width: buttonWidth, height: buttonWidth / 2)
      
      calibrateresetButton.tintColor = UIColor.red
      calibrateresetButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
      calibrateresetButton.titleLabel?.textAlignment = .center
      calibrateresetButton.setTitle((Gb?.localizedString(forKey: "reset", value: nil, table: nil))!, for: .normal)
      calibrateresetButton.setTitleColor(UIColor.white, for: .normal)
      calibrateresetButton.backgroundColor = .clear
      calibrateresetButton.layer.cornerRadius = 5
      calibrateresetButton.layer.backgroundColor = UIColor.init(red: 1, green: 64 / 255, blue: 80 / 255, alpha: 1).cgColor
      
      calibrateresetButton.layer.shadowOffset = CGSize(width: 0, height: 5)
      let shadowPath = UIBezierPath(roundedRect: calibrateManualButton.bounds, cornerRadius: calibrateManualButton.layer.cornerRadius)
      calibrateresetButton.layer.shadowPath = shadowPath.cgPath
      calibrateresetButton.layer.shadowOpacity = Float(0.5)
      calibrateresetButton.layer.shadowColor = UIColor.black.cgColor
      
      calibrateresetButton.addTarget(self, action: #selector(resetManualCalibrate), for: .touchUpInside)
      view.addSubview(calibrateresetButton)
    }
  }
  
  func updateAccuracy(){
    calibrateTitle.text = "\((Gb?.localizedString(forKey: "compas_accuracy", value: nil, table: nil))!)\(getCompassReliabilityString())"
  }
  
  override func viewDidAppear(_ animated: Bool) {
    Analytics.logEvent(AnalyticsEventScreenView,
    parameters: [AnalyticsParameterScreenName: "Calibrate View",
                 AnalyticsParameterScreenClass: "CalibrateViewController"])
    
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "104",
         AnalyticsParameterItemName: "Calibrate Activity",
         AnalyticsParameterContentType: "Calibrate Opened"])
  }
  
  @objc func manualCalibrate(sender: UIButton!){
    print("Manual calibration")
    GlobalArView = true
    Globaltoolbar?.updateLabel1Text((Gb?.localizedString(forKey: "manual_calibration", value: nil, table: nil))!)
    Globalcalibrating = true
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "104",
         AnalyticsParameterItemName: "Calibrate Activity",
         AnalyticsParameterContentType: "Manual calibration selected"])
    dismiss(animated: true, completion: nil)
  }
  
  @objc func resetManualCalibrate(sender: UIButton!){
    print("Reset manual calibration")
    GlobalArView = true
    Globalcalibrating = false
    GlobalazimuthOffset = 0
    GlobalverticalOffset = 0
    updateLines3DVectors()
    dismiss(animated: true, completion: nil)
  }
  
  @objc func doneClicked(sender: UIButton!){
    print("Done clicked")
    GlobalArView = true
    dismiss(animated: true, completion: nil)
    GlobalcalibrateViewController = nil
  }
}
