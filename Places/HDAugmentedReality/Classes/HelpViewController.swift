//
//  helpViewController.swift
//  Sun App
//
//  Created by Phillip Løjmand on 14/09/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HelpViewController: UIViewController
{
  let textFont = UIFont(name: "SofiaPro-Light", size: CGFloat(14))
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white

    let backbutton = addTitleWithBackButton(ctrl: self, titleText: (Gb?.localizedString(forKey: "help", value: nil, table: nil))!)
    backbutton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
    
    nextY = 8
    var scrollViewY = 140
    if(!GlobalhasPremium){
      scrollViewY += 10
      let premiumtext = UILabel(frame: CGRect(x: 24, y: 120, width: 200, height: 21))
      premiumtext.textColor = UIColor.gray
      premiumtext.font = textFont
      premiumtext.text = "(*) Premium required"
      self.view.addSubview(premiumtext)
    }
    
    let scrollView = fadeScrollView(frame: CGRect(x: 0, y: scrollViewY, width: Globalwidth, height: Globalheight - 70))
  //  scrollView.autoresizingMask = UInt8(UIViewAutoresizing.FlexibleWidth.rawValue) | UIViewAutoresizing.FlexibleHeight
    
    let first = CardView(titleText: (Gb?.localizedString(forKey: "where_is_the_sun_at_a_given_time", value: nil, table: nil))!, helpNO: 0)
    scrollView.addSubview(first)
    
    let second = CardView(titleText: (Gb?.localizedString(forKey: "what_does_the_lines_represent", value: nil, table: nil))!, helpNO: 1)
    scrollView.addSubview(second)
    
    let third = CardView(titleText: (Gb?.localizedString(forKey: "button_descriptions", value: nil, table: nil))!, helpNO: 2)
    scrollView.addSubview(third)
    
    let fourth = CardView(titleText: (Gb?.localizedString(forKey: "the_sun_isn_t_at_the_shown_position", value: nil, table: nil))!, helpNO: 3)
    scrollView.addSubview(fourth)
    
    let fifth = CardView(titleText: (Gb?.localizedString(forKey: "how_does_the_drawing_mode_work", value: nil, table: nil))!, helpNO: 4)
    scrollView.addSubview(fifth)
    
    let sixth = CardView(titleText: (Gb?.localizedString(forKey: "why_are_there_two_dates_at_the_top", value: nil, table: nil))!, helpNO: 5)
    scrollView.addSubview(sixth)
    
    let seventh = CardView(titleText: (Gb?.localizedString(forKey: "contact_title", value: nil, table: nil))!, helpNO: 6)
    scrollView.addSubview(seventh)
    
    nextY += 6

    let casafoxDev = UILabel(frame: CGRect(x: Int(scrollView.frame.width / 2) - 100, y: nextY, width: 200, height: 21))
    casafoxDev.textColor = UIColor.gray
    casafoxDev.textAlignment = .center
    casafoxDev.font = UIFont.systemFont(ofSize: 14)
    casafoxDev.text = "Casafox Development"
    scrollView.addSubview(casafoxDev)
    nextY = Int(casafoxDev.frame.maxY)
    
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      let versionNumber = UILabel(frame: CGRect(x: Int(scrollView.frame.width / 2) - 100, y: nextY, width: 200, height: 21))
      versionNumber.textColor = UIColor.gray
      versionNumber.textAlignment = .center
      versionNumber.font = UIFont.systemFont(ofSize: 10)
      versionNumber.text = "v. \(version)"
      scrollView.addSubview(versionNumber)
      nextY = Int(versionNumber.frame.maxY + 8)
    }
    
    scrollView.contentSize = CGSize(width: Globalwidth, height: nextY + 70)
    self.view.addSubview(scrollView)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    Analytics.logEvent(AnalyticsEventScreenView,
    parameters: [AnalyticsParameterScreenName: "Help View",
                 AnalyticsParameterScreenClass: "HelpViewController"])
  }
  
  @objc func doneClicked(sender: UIButton!){
    print("Done clicked")
    GlobalArView = true
    dismiss(animated: true, completion: nil)
  }
  
}
