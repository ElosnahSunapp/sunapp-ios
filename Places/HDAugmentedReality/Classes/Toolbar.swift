//
//  Toolbar.swift
//  Places
//
//  Created by Phillip Løjmand on 15/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit

class Toolbar: UIView {

  let label1 = UILabel()
  
  var label1Text: String = ""//"\((Gb?.localizedString(forKey: "loading", value: nil, table: nil))!)..."
  let label2 = UILabel()
  
  var label2Text: String = ""
  var GlobalBlockSunHours = ""
  
  var lastLabel1Millis = 0
  var lastLabel2Millis = 0
  
  var gl = CAGradientLayer()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    //self.backgroundColor = UIColor(white: 0, alpha: 0.3)
    dBug("Toolbar Init Size \(frame.width),\(frame.height)")
    let colorTop = UIColor(white: 0, alpha: 0.85)
    let colorBottom = UIColor(white: 0, alpha: 0)
    
    
    
    gl.frame = CGRect.init(x: frame.minX, y: frame.minY, width: frame.maxX - frame.minX, height: (frame.maxY - frame.minY) * 2)
    gl.colors = [colorTop.cgColor, colorBottom.cgColor]
    gl.locations = [0,0.85]
    self.layer.addSublayer(gl)
    
    print(frame.minY + CGFloat(Globalnotchsize))
    setLabelsFramePortrait()
    label1.text = label1Text
    label1.textColor = .white
    label1.font = UIFont(name: "SofiaPro-SemiBold", size: CGFloat(20))
    label2.text = label2Text
    label2.textColor = .white
    label2.font = UIFont(name: "SofiaPro-SemiBold", size: CGFloat(20))
    
    self.addSubview(label1)
    self.addSubview(label2)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: AnyObject? = touches.first
    if(Globalshowbothtimes && GlobalhasPremium){
      Globaltouching = true
      let point = touch!.location(in: self)
      if(point.x > label1.frame.minX && point.x < label1.frame.maxX){
        
        label2.isHidden = true
        Globalshowbothtimes = false
      }else{
        
        updateTime(GlobalfakeMillis2)
        updateDayLine()
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    dBug("Toolbar Required Init")
  }
  
  public func hide(_ val: Bool){
    isHidden = val
    dBug("Toolbar Hide \(val)")
  }
  
  public func setLabelsFramePortrait(){
    let startX = frame.minX + 12
    let endX = frame.width - 40
    var midX = (startX + endX) / 2
    if(Globaldrawing){
    label1.frame = CGRect(x: startX,y: frame.minY + CGFloat(GlobalmenuButtonOffset) / 2 + CGFloat(Globalnotchsize), width: endX - startX - 4, height: frame.height - CGFloat(Globalnotchsize))
    }else{
    label1.frame = CGRect(x: startX,y: frame.minY + CGFloat(GlobalmenuButtonOffset) / 2 + CGFloat(Globalnotchsize), width: midX - startX - 4, height: frame.height - CGFloat(Globalnotchsize))
    }
    label2.frame = CGRect(x: midX,y: frame.minY + CGFloat(GlobalmenuButtonOffset) / 2 + CGFloat(Globalnotchsize), width: endX - midX, height: frame.height - CGFloat(Globalnotchsize))
  }
  
  public func setLabelsFrameLandscape(){
    label1.frame = CGRect(x: frame.minX + 12,y: frame.minY + CGFloat(GlobalmenuButtonOffset) / 2, width: frame.width / 2, height: frame.height)
    label2.frame = CGRect(x: frame.minX + frame.width / 2 + 12,y: frame.minY + CGFloat(GlobalmenuButtonOffset) / 2, width: frame.width / 2, height: frame.height)
  }
  
  public func updateOrientation(){
    dBug("Toolbar updateOrientation")
    if(Globalorientation == Orientation.PORTRAIT){
      dBug("Toolbar updateOrientation PORTRAIT")
      self.transform = CGAffineTransform.identity
     
      
      self.frame = CGRect(x: frame.origin.x,y: frame.origin.y, width: CGFloat(Globalwidth), height: CGFloat(48 + max(Globalnotchsize - 10,0)))
      setLabelsFramePortrait()
      
      gl.frame = CGRect(x: frame.minX,y: frame.minY, width: frame.width, height: frame.height * 2 - CGFloat(Globalnotchsize))
      
      GlobalmenuButton?.transform = CGAffineTransform.identity
      GlobalmenuButton?.frame = CGRect(x: Globalwidth - (40 + GlobalmenuButtonOffset), y: GlobalmenuButtonOffset + max(Globalnotchsize - 10, 0), width: 40,height: 40)
    }
    if(Globalorientation == Orientation.LANDSCAPE){
      dBug("Toolbar updateOrientation LANDSCAPE")
      self.frame = CGRect(x: frame.origin.x,y: frame.origin.y, width: CGFloat(Globalheight), height: 48)
      setLabelsFrameLandscape()
      
      gl.frame = CGRect(x: frame.minX,y: frame.minY, width: frame.width, height: frame.height * 2)
      
      var transform = CGAffineTransform.identity.rotated(by: CGFloat(Float.pi / 2))
      transform = transform.translatedBy(x: CGFloat(CGFloat(Globalheight) / 2 - frame.height / 2), y: CGFloat(Globalheight) / 2 - CGFloat(Globalwidth) + frame.height / 2)
      self.transform = transform
      
      
      transform = CGAffineTransform.identity.rotated(by: CGFloat(Float.pi / 2))
      transform = transform.translatedBy(x: CGFloat(Globalheight - GlobalbuttonHeight), y: CGFloat(0))
      GlobalmenuButton?.frame = CGRect(x: Globalwidth - (40 + GlobalmenuButtonOffset), y: -GlobalmenuButtonOffset, width: 40,height: 40)
      GlobalmenuButton?.transform = transform
    }
   
   // gl.frame = self.frame
  }
  
  public func updateLabel1Text(_ text: String)->Bool{
    if(!Globalcalibrating){
    self.label1Text = text
    label1.text = label1Text
    label2.isHidden = true
    Globalshowbothtimes = false
      return true
    }
    return false
  }
  
  public func updateLabel2Text(_ text: String){
    self.label2Text = text
    label2.text = label2Text
    label2.isHidden = false
    Globalshowbothtimes = true
  }
  
  var lastMillis = 0
  public func updateLabel1FromMillis(_ label1Millis: Int){
    dBug("Toolbar updateLabel1FromMillis \(label1Millis)")
    if(abs(lastMillis - label1Millis) > 1000 && !Globaldrawing){
    lastLabel1Millis = label1Millis
    let date = Date(timeIntervalSince1970: TimeInterval(label1Millis / 1000))
    let dateFormatter = getDateFormatterTimezone()
    var stringBuilder = ""
    if(Globallive){
      dateFormatter.dateFormat = "HH:mm - dd."
    }else{
      dateFormatter.dateFormat = "HH:mm - dd."
    }
    stringBuilder = dateFormatter.string(from: date)
    dateFormatter.dateFormat = "MM"
    stringBuilder = "\(stringBuilder) \(mmtoMMM(dateFormatter.string(from: date)))"
    if(updateLabel1Text(stringBuilder)){
      lastMillis = label1Millis
    }
    
    
    dateFormatter.dateFormat = "HH:mm"
    Globaltime1 = dateFormatter.string(from: date)
      
    dateFormatter.dateFormat = "dd."
    stringBuilder = dateFormatter.string(from: date)
    dateFormatter.dateFormat = "MM"
    stringBuilder = "\(stringBuilder) \(mmtoMMMM(dateFormatter.string(from: date)))"
    Globaldate1 = stringBuilder
      
      dateFormatter.dateFormat = "HH:mm - dd."
    stringBuilder = dateFormatter.string(from: date)
    dateFormatter.dateFormat = "MM"
    stringBuilder = "\(stringBuilder) \(mmtoMMMM(dateFormatter.string(from: date)))"
    GlobalscreenshotTime1 = stringBuilder
    
      
    var days = floor(abs(date.timeIntervalSince(GlobalsummerDate)) / (60 * 60 * 24))
    GlobalcloseToSummer = false
    if(days < 25 || days > 365 - 25){
      GlobalcloseToSummer = true
    }
    
    GlobalreallycloseToSummer = false
    if(days < 5){
      GlobalreallycloseToSummer = true
    }
    
      
    days = floor(abs(date.timeIntervalSince(GlobalwinterDate)) / (60 * 60 * 24))
    GlobalcloseToWinter = false
    if(days < 25  || days > 365 - 25){
      GlobalcloseToWinter = true
    }
    
    GlobalreallycloseToWinter = false
    if(days < 5){
      GlobalreallycloseToWinter = true
    }
    }
  }
  
  public func updateLabel2FromMillis(_ label1Millis: Int){
      lastLabel2Millis = label1Millis
      let date = Date(timeIntervalSince1970: TimeInterval(label1Millis / 1000))
      let dateFormatter = getDateFormatterTimezone()
      var stringBuilder = ""
      dateFormatter.dateFormat = "HH:mm - dd."
      stringBuilder = dateFormatter.string(from: date)
      dateFormatter.dateFormat = "MM"
      stringBuilder = "\(stringBuilder) \(mmtoMMM(dateFormatter.string(from: date)))"
      updateLabel2Text(stringBuilder)
    
      dateFormatter.dateFormat = "dd."
      stringBuilder = dateFormatter.string(from: date)
      dateFormatter.dateFormat = "MM"
      stringBuilder = "\(stringBuilder) \(mmtoMMM(dateFormatter.string(from: date)))"
      Globaldate2 = stringBuilder
    
      dateFormatter.dateFormat = "HH:mm"
      Globaltime2 = dateFormatter.string(from: date)
    
      dateFormatter.dateFormat = "HH:mm - dd."
      stringBuilder = dateFormatter.string(from: date)
      dateFormatter.dateFormat = "MM"
      stringBuilder = "\(stringBuilder) \(mmtoMMMM(dateFormatter.string(from: date)))"
      GlobalscreenshotTime2 = stringBuilder
  }
  
  func updateLanguageChange(){
    dBug("Toolbar updateLanguageChange")
    lastMillis = -1
    let label2vis = label2.isHidden
    updateLabel1FromMillis(lastLabel1Millis)
    updateLabel2FromMillis(lastLabel2Millis)
    label2.isHidden = label2vis
  }
  
  public func setBlockedSunHours(_ label: String){
    GlobalBlockSunHours = label
    updateLabel1Text(label)
  }
}
