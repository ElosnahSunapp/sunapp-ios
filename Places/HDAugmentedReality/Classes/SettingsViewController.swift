//
//  DataViewController.swift
//  Places
//
//  Created by Phillip Løjmand on 22/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SettingsViewController: UIViewController, LanguageViewDelegate, CameraButtonOptionViewDelegate, UnitsViewDelegate
{
  var languageViews = [LanguageView]()
  var cameraOptionViews = [CameraButtonOptionView]()
  var unitViews = [UnitsView]()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    Globalcamerafunctions[0] = (Gb?.localizedString(forKey: "takescreenshot", value: nil, table: nil))!
    Globalcamerafunctions[1] = (Gb?.localizedString(forKey: "recordvideo", value: nil, table: nil))!
    Globalunits[0] = lString("hourunit")
    Globalunits[1] = "\(lString("solarirradiance")) (kWh/m\u{00B2})"
    
    let contentX = 24
    let backbutton = addTitleWithBackButton(ctrl: self, titleText: (Gb?.localizedString(forKey: "settings", value: nil, table: nil))!)
    backbutton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
    
    let scrollView = fadeScrollView(frame: CGRect(x: 0, y: 130, width: Globalwidth, height: Globalheight - 130))
    self.view.addSubview(scrollView)
    
    let subtitleFont = UIFont(name: "SofiaPro-Bold", size: CGFloat(20))
    
    let textColor = UIColor(red: 72 / 255, green: 72 / 255, blue: 72 / 255, alpha: 1.0)
    var y = 0
    let languageTitle = UILabel(frame: CGRect(x: contentX, y: y, width: Globalwidth - 32, height: 40))
    languageTitle.text = (Gb?.localizedString(forKey: "language", value: nil, table: nil))!
    languageTitle.textColor = textColor
    languageTitle.font = subtitleFont
    scrollView.addSubview(languageTitle)
    
    y += 25
    let languageScrollView = fadeScrollView(frame: CGRect(x: 0, y: y, width: Globalwidth, height: 240))
    scrollView.addSubview(languageScrollView)
    
    y += 240
    let cameraButtonTitle = UILabel(frame: CGRect(x: contentX, y: y, width: Globalwidth - 32, height: 40))
    cameraButtonTitle.text = Gb?.localizedString(forKey: "camerafunction", value: nil, table: nil)
    cameraButtonTitle.textColor = textColor
    cameraButtonTitle.font = subtitleFont
    scrollView.addSubview(cameraButtonTitle)
    
    let subsubFont = UIFont(name: "SofiaPro-Light", size: CGFloat(14))
    y += 25
    let cameraButtonSubTitle = UILabel(frame: CGRect(x: contentX, y: y, width: Globalwidth - 32, height: 40))
    cameraButtonSubTitle.text = Gb?.localizedString(forKey: "cameraTitle", value: nil, table: nil)
    cameraButtonSubTitle.textColor = textColor
    cameraButtonSubTitle.font = subsubFont
    scrollView.addSubview(cameraButtonSubTitle)
    
    camereOptionY = y + 35
    for i in 0...1{
      let element = CameraButtonOptionView(lIndex: i)
      element.delegate = self
      cameraOptionViews.append(element)
      scrollView.addSubview(element)
    }
    y = camereOptionY
    
    let unitsButtonTitle = UILabel(frame: CGRect(x: contentX, y: y, width: Globalwidth - 32, height: 40))
    unitsButtonTitle.text = Gb?.localizedString(forKey: "sununits", value: nil, table: nil)
    unitsButtonTitle.textColor = textColor
    unitsButtonTitle.font = subtitleFont
    scrollView.addSubview(unitsButtonTitle)
    
    y += 25
    let unitsButtonSubTitle = UILabel(frame: CGRect(x: contentX, y: y, width: Globalwidth - 32, height: 40))
    unitsButtonSubTitle.text = Gb?.localizedString(forKey: "unitsTitle", value: nil, table: nil)
    unitsButtonSubTitle.textColor = textColor
    unitsButtonSubTitle.font = subsubFont
    scrollView.addSubview(unitsButtonSubTitle)
    UnitsViewY = y + 35

    for i in 0...1{
      let element = UnitsView(lIndex: i)
      element.delegate = self
      unitViews.append(element)
      scrollView.addSubview(element)
    }
    
    //Language
    languageY = 8
    for i in 0...5{
      let element = LanguageView(lIndex: i)
      element.delegate = self
      languageViews.append(element)
      languageScrollView.addSubview(element)
    }
    
    languageScrollView.contentSize = CGSize(width: Globalwidth, height: languageY + 8)
    scrollView.contentSize = CGSize(width: Globalwidth, height: UnitsViewY + 8)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    Analytics.logEvent(AnalyticsEventScreenView,
    parameters: [AnalyticsParameterScreenName: "Settings View",
                 AnalyticsParameterScreenClass: "SettingsViewController"])
  }
  
  @objc func doneClicked(sender: UIButton!){
    print("Done clicked")
    GlobalArView = true
    dismiss(animated: true, completion: nil)
  }
  
  func onLanguageClicked(sender: AnyObject){
    for languageView in self.languageViews{
      languageView.updateTick()
    }
  }
  
  func onCameraOptionsClicked(sender: AnyObject){
    for cameraOptionView in self.cameraOptionViews{
       cameraOptionView.updateTick()
    }
  }
  
  func onUnitsViewClicked(sender: AnyObject) {
    for unitView in self.unitViews{
      unitView.updateTick()
    }
  }
  
  func cameraButtonGotoStore(sender: AnyObject){
    gotoStore()
  }
  func unitsViewGotoStore(sender: AnyObject){
    gotoStore()
  }
  
  func gotoStore() {
    self.present(Globalstore, animated: true)
  }
}
