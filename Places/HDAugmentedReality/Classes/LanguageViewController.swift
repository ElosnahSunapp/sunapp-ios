//
//  DataViewController.swift
//  Places
//
//  Created by Phillip Løjmand on 22/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit

class LanguageViewController: UIViewController, LanguageViewDelegate
{
  
  var languageViews = [LanguageView]()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    
    let backbutton = addTitleWithBackButton(ctrl: self, titleText: (Gb?.localizedString(forKey: "language", value: nil, table: nil))!)
    backbutton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)

    let scrollView = fadeScrollView(frame: CGRect(x: 0, y: 130, width: Globalwidth, height: Globalheight - 160))
    self.view.addSubview(scrollView)
    
    languageY = 8
    for i in 0...5{
      let element = LanguageView(lIndex: i)
      element.delegate = self
      languageViews.append(element)
      scrollView.addSubview(element)
    }
  
    scrollView.contentSize = CGSize(width: Globalwidth, height: languageY + 8)
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
}
