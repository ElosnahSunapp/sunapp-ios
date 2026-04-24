//
//  UILabelEXT.swift
//  Sun App
//
//  Created by Phillip Løjmand on 15/09/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit

class UILabelEXT: UILabel{
  var isLabel1 = true
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if(isLabel1){
    print("touch")
    updateTime(usingMillis())
    }else{
    print("touch2")
    updateTime(GlobalfakeMillis2)
    }
  }
  
  public func islabel1(_ i: Bool){
    isLabel1 = i
  }
}
