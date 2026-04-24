//
//  CardView.swift
//  Places
//
//  Created by Phillip Løjmand on 22/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import UIKit

var camereOptionY = 8
protocol CameraButtonOptionViewDelegate{
  func onCameraOptionsClicked(sender: AnyObject)
  func cameraButtonGotoStore(sender: AnyObject)
}

@IBDesignable class CameraButtonOptionView: UIView {
  var delegate: CameraButtonOptionViewDelegate?
  
  let seperator = CALayer()
  let titleFont = UIFont(name: "SofiaPro-Medium", size: CGFloat(17))
  let textColor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1.0)
  var tickImageView = UIImageView()
  var lIndex = -1
  init(lIndex: Int){
    self.lIndex = lIndex
    let cardHeight = 32
    let yOffset = 5
    
    super.init(frame: CGRect(x: 24, y: camereOptionY, width: Globalwidth - 32, height: cardHeight))
    camereOptionY += cardHeight + yOffset
    self.backgroundColor = UIColor.white
    
    let title = UILabel(frame: CGRect(x: 0, y: 0, width: Globalwidth - 32, height: cardHeight))
    title.textColor = textColor
    title.font = titleFont
    title.text = Globalcamerafunctions[lIndex]
    self.addSubview(title)
    
    let tickSize = 20
    tickImageView = UIImageView(frame: CGRect(x: Int(self.frame.width) - tickSize, y: Int(self.frame.height / 2) - tickSize / 2, width: tickSize, height: tickSize))
    
    updateTick()
    
    self.addSubview(tickImageView)
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onCameraOptionsClicked (_:)))
    addGestureRecognizer(gesture)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.white
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
  }
  
  override func layoutSubviews() {
    let width = CGFloat(1.0)
    let intensity = CGFloat(235.0 / 255.0)
    seperator.borderColor = UIColor(red: intensity, green: intensity, blue: intensity, alpha: 1.0).cgColor
    seperator.frame = CGRect(x: 0, y: frame.size.height - width,width:frame.size.width,height: frame.size.height)
    seperator.borderWidth = width
    layer.addSublayer(seperator)
    layer.masksToBounds = true
  }
  
  @IBAction func onCameraOptionsClicked(_ sender:UITapGestureRecognizer){
    if(GlobalhasPremium){
      setCameraFunction(row: self.lIndex)
      delegate?.onCameraOptionsClicked(sender: sender)
    }else{
      delegate?.cameraButtonGotoStore(sender: sender)
    }
  }
  
  public func updateTick(){
    if(GlobalcameraisScreenshot == (self.lIndex == 0) && GlobalhasPremium){
      tickImageView.image = imgActive
    }else{
      tickImageView.image = imgInactive
    }
  }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
  return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
