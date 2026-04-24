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

class DataViewController: UIViewController
{
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    
    let backbutton = addTitleWithBackButton(ctrl: self, titleText: (Gb?.localizedString(forKey: "details", value: nil, table: nil))!)
    backbutton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
    let contentX = 24
    let textColor = UIColor(red: 72 / 255, green: 72 / 255, blue: 72 / 255, alpha: 1.0)
    
    let locationLabel = UILabel(frame: CGRect(x: contentX, y: 120, width: Globalwidth - 32, height: 20))
    locationLabel.textColor = textColor
    locationLabel.text = "\(GlobalwholeAddress)"
    locationLabel.font = UIFont(name: "SofiaPro-Light", size: CGFloat(14))

    self.view.addSubview(locationLabel)
    
    let scrollView = fadeScrollView(frame: CGRect(x: 0, y: 160, width: Globalwidth, height: Globalheight - 160))
    self.view.addSubview(scrollView)
    
    nextY = 8
    
    if(Globallive){
      let todayCard = CardView(titleText: (Gb?.localizedString(forKey: "today", value: nil, table: nil))!, sunline: sunline,seperator: true)
      scrollView.addSubview(todayCard)
    }else{
    let todayCard = CardView(titleText: (Gb?.localizedString(forKey: "today", value: nil, table: nil))!, sunline: getDayOfSun(date: Date(timeIntervalSince1970: TimeInterval(currentMillis() / 1000)), timeInterval: Globalprecision),seperator: true)
    scrollView.addSubview(todayCard)
    let selectedDayCard = CardView(titleText: Globaldate1, sunline: sunline,seperator: true)
    scrollView.addSubview(selectedDayCard)
    }
    if(false){
      let selectedDay2Card = CardView(titleText: Globaldate2, sunline: reverseSunline,seperator: true)
    scrollView.addSubview(selectedDay2Card)
    }
    let solsticeCard = CardView(titleText: (Gb?.localizedString(forKey: "solstice_21_june", value: nil, table: nil))!, sunline: summerline,seperator: true)
    scrollView.addSubview(solsticeCard)
    let solticeCard = CardView(titleText: (Gb?.localizedString(forKey: "soltice_21_december", value: nil, table: nil))!, sunline: winterline,seperator: false)
    scrollView.addSubview(solticeCard)
    scrollView.contentSize = CGSize(width: Globalwidth, height: nextY + 8)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    Analytics.logEvent(AnalyticsEventScreenView,
    parameters: [AnalyticsParameterScreenName: "Data View",
                 AnalyticsParameterScreenClass: "DataViewController"])
  }
  
  @objc func doneClicked(sender: UIButton!){
    print("Done clicked")
    GlobalArView = true
    dismiss(animated: true, completion: nil)
  }
}
