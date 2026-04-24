//
//  CardView.swift
//  Places
//
//  Created by Phillip Løjmand on 22/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import UIKit

var nextY = 8

@IBDesignable class CardView: UIView {

  let seperator = CALayer()
  let titleFont = UIFont(name: "SofiaPro-Medium", size: CGFloat(17))
  let smallTitleFont = UIFont(name: "SofiaPro-Medium", size: CGFloat(14))
  let textFont = UIFont(name: "SofiaPro-Light", size: CGFloat(14))
  let textColor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1.0)
  
  init(titleText: String, helpNO: Int){
    super.init(frame: CGRect(x: 16, y: nextY, width: Globalwidth - 32, height: 136))
    
    var internY = 8
    
    let title = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 16, height: 30))
    self.backgroundColor = UIColor.white
    title.text = titleText
    title.textColor = textColor
    title.font = titleFont
    title.numberOfLines = 0
    title.lineBreakMode = NSLineBreakMode.byWordWrapping
    self.addSubview(title)
    internY = Int(title.frame.maxY) + 8
    
    switch helpNO {
    case 0:
      addStarToLabel(label: title)
      let answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      answer.text = (Gb?.localizedString(forKey: "where_the_sun_is_answer", value: nil, table: nil))!
      answer.textColor = textColor
      answer.font = textFont
      answer.numberOfLines = 0
      answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      answer.sizeToFit()
      self.addSubview(answer)
      internY = Int(answer.frame.maxY) + 8
      break
      
    case 1:
      let yellow = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      yellow.text = (Gb?.localizedString(forKey: "yellow_line", value: nil, table: nil))!
      yellow.textColor = textColor
      yellow.font = smallTitleFont
      yellow.numberOfLines = 0
      yellow.lineBreakMode = NSLineBreakMode.byWordWrapping
      yellow.sizeToFit()
      self.addSubview(yellow)
      internY = Int(yellow.frame.maxY) + 4
      
      let yellow_answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      yellow_answer.text = (Gb?.localizedString(forKey: "yellow_line_answer", value: nil, table: nil))!
      yellow_answer.textColor = textColor
      yellow_answer.font = textFont
      yellow_answer.numberOfLines = 0
      yellow_answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      yellow_answer.sizeToFit()
      self.addSubview(yellow_answer)
      internY = Int(yellow_answer.frame.maxY) + 8
      
      
      
      let redAndOrange = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      redAndOrange.text = (Gb?.localizedString(forKey: "red_and_orange_line", value: nil, table: nil))!
      redAndOrange.textColor = textColor
      redAndOrange.font = smallTitleFont
      redAndOrange.numberOfLines = 0
      redAndOrange.lineBreakMode = NSLineBreakMode.byWordWrapping
      redAndOrange.sizeToFit()
      self.addSubview(redAndOrange)
      internY = Int(redAndOrange.frame.maxY) + 4
      
      let redAndOrange_answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      redAndOrange_answer.text = (Gb?.localizedString(forKey: "red_orange_answer", value: nil, table: nil))!
      redAndOrange_answer.textColor = textColor
      redAndOrange_answer.font = textFont
      redAndOrange_answer.numberOfLines = 0
      redAndOrange_answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      redAndOrange_answer.sizeToFit()
      self.addSubview(redAndOrange_answer)
      internY = Int(redAndOrange_answer.frame.maxY) + 8
      
      
      let grayLine = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      grayLine.text = (Gb?.localizedString(forKey: "gray_line", value: nil, table: nil))!
      grayLine.textColor = textColor
      grayLine.font = smallTitleFont
      grayLine.numberOfLines = 0
      grayLine.lineBreakMode = NSLineBreakMode.byWordWrapping
      grayLine.sizeToFit()
      self.addSubview(grayLine)
      internY = Int(grayLine.frame.maxY) + 4
      
      let grayLine_answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      grayLine_answer.text = (Gb?.localizedString(forKey: "gray_line_answer", value: nil, table: nil))!
      grayLine_answer.textColor = textColor
      grayLine_answer.font = textFont
      grayLine_answer.numberOfLines = 0
      grayLine_answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      grayLine_answer.sizeToFit()
      self.addSubview(grayLine_answer)
      internY = Int(grayLine_answer.frame.maxY) + 8
      
      let blueLine = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      blueLine.text = (Gb?.localizedString(forKey: "blue_line", value: nil, table: nil))!
      blueLine.textColor = textColor
      blueLine.font = smallTitleFont
      blueLine.numberOfLines = 0
      blueLine.lineBreakMode = NSLineBreakMode.byWordWrapping
      
      self.addSubview(blueLine)
      addStarToLabel(label: blueLine)
      blueLine.sizeToFit()
      
      internY = Int(blueLine.frame.maxY) + 4
      
      let blueLine_answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      blueLine_answer.text = (Gb?.localizedString(forKey: "blue_line_answer", value: nil, table: nil))!
      blueLine_answer.textColor = textColor
      blueLine_answer.font = textFont
      blueLine_answer.numberOfLines = 0
      blueLine_answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      blueLine_answer.sizeToFit()
      self.addSubview(blueLine_answer)
      internY = Int(blueLine_answer.frame.maxY) + 8
      
      
      break
      
    case 2:
      addStarToLabel(label: title)
      internY += 8
      internY = addButtonWithDescription(img: GlobalfreezeImage!, text: (Gb?.localizedString(forKey: "freeze_button_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalcameraImage!, text: (Gb?.localizedString(forKey: "screenshot_help", value: nil, table: nil))!,y: internY)
    
      let main_mode = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      main_mode.text = (Gb?.localizedString(forKey: "main_mode", value: nil, table: nil))!
      main_mode.textColor = textColor
      main_mode.font = smallTitleFont
      main_mode.numberOfLines = 0
      main_mode.lineBreakMode = NSLineBreakMode.byWordWrapping
      main_mode.sizeToFit()
      self.addSubview(main_mode)
      internY = Int(main_mode.frame.maxY) + 8
  
      internY = addButtonWithDescription(img: GloballiveImage!, text: (Gb?.localizedString(forKey: "live_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalcalendarImage!, text: (Gb?.localizedString(forKey: "day_select_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobaldrawImage!, text: (Gb?.localizedString(forKey: "draw_mode_help", value: nil, table: nil))!,y: internY)

      let draw_mode = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      draw_mode.text = (Gb?.localizedString(forKey: "draw_mode", value: nil, table: nil))!
      draw_mode.textColor = textColor
      draw_mode.font = smallTitleFont
      draw_mode.numberOfLines = 0
      draw_mode.lineBreakMode = NSLineBreakMode.byWordWrapping
      draw_mode.sizeToFit()
      self.addSubview(draw_mode)
      internY = Int(draw_mode.frame.maxY) + 8
      
      internY = addButtonWithDescription(img: GloballineImage!, text: (Gb?.localizedString(forKey: "straight_line_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalundoImage!, text: (Gb?.localizedString(forKey: "undo_line_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobaldeleteImage!, text: (Gb?.localizedString(forKey: "clear_everything_help", value: nil, table: nil))!,y: internY)
      
      let map_mode = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      map_mode.text = (Gb?.localizedString(forKey: "map_mode", value: nil, table: nil))!
      map_mode.textColor = textColor
      map_mode.font = smallTitleFont
      map_mode.numberOfLines = 0
      map_mode.lineBreakMode = NSLineBreakMode.byWordWrapping
      map_mode.sizeToFit()
      self.addSubview(map_mode)
      internY = Int(map_mode.frame.maxY) + 8
      
      //internY = addButtonWithDescription(img: GlobalcurrentLocationImage!, text: (Gb?.localizedString(forKey: "here_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalmapFollowImage!, text: (Gb?.localizedString(forKey: "center_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalmarkerImage!, text: (Gb?.localizedString(forKey: "placed_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalmapImage!, text: (Gb?.localizedString(forKey: "map_help", value: nil, table: nil))!,y: internY)
      internY = addButtonWithDescription(img: GlobalsearchImage!, text: (Gb?.localizedString(forKey: "search_help", value: nil, table: nil))!,y: internY)
      break
      
    case 3:
      let answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      answer.text = (Gb?.localizedString(forKey: "the_sun_isnt_at_the_shown_position_answer", value: nil, table: nil))!
      answer.textColor = textColor
      answer.font = textFont
      answer.numberOfLines = 0
      answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      answer.sizeToFit()
      self.addSubview(answer)
      internY = Int(answer.frame.maxY) + 8
      break
  
    case 4:
      addStarToLabel(label: title)
      let answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      answer.text = (Gb?.localizedString(forKey: "how_drawing_mode_works_answer", value: nil, table: nil))!
      answer.textColor = textColor
      answer.font = textFont
      answer.numberOfLines = 0
      answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      answer.sizeToFit()
      self.addSubview(answer)
      internY = Int(answer.frame.maxY) + 8
      break
      
    case 5:
      addStarToLabel(label: title)
      let answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      answer.text = (Gb?.localizedString(forKey: "two_dates_at_the_top_answer", value: nil, table: nil))!
      answer.textColor = textColor
      answer.font = textFont
      answer.numberOfLines = 0
      answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      answer.sizeToFit()
      self.addSubview(answer)
      internY = Int(answer.frame.maxY) + 8
      break
      
    case 6:
      let answer = UILabel(frame: CGRect(x: 8, y: internY, width: Globalwidth - 48, height: 30))
      answer.text = (Gb?.localizedString(forKey: "contact_description", value: nil, table: nil))!
      answer.textColor = textColor
      answer.font = textFont
      answer.numberOfLines = 0
      answer.lineBreakMode = NSLineBreakMode.byWordWrapping
      answer.sizeToFit()
      internY = Int(answer.frame.maxY) + 16
      
      let contact_address = UILabel(frame: CGRect(x: Int(frame.width / 2) - 100, y: internY, width: 200, height: 30))
      contact_address.textColor = UIColor.blue
      contact_address.textAlignment = .center
      contact_address.font = UIFont.systemFont(ofSize: 16)
      contact_address.text = "support@casafox.dk"
      contact_address.isUserInteractionEnabled = true
      let tap = UITapGestureRecognizer(target: self, action: #selector(contactSupport))
      contact_address.addGestureRecognizer(tap)


      self.addSubview(answer)
      self.addSubview(contact_address)
      internY = Int(contact_address.frame.maxY) + 8
      seperator.isHidden = true
      break
      
    default:
      break
    }
    title.sizeToFit()
    nextY += internY + 8
    self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: CGFloat(nextY - Int(self.frame.minY)))
    
    nextY = Int(self.frame.maxY) + 8
  }
  @objc func contactSupport(sender:UITapGestureRecognizer){
    let url = URL(string: "mailto:support@casafox.dk")
    
    if(UIApplication.shared.canOpenURL(url!)){
      UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
  }
  
  func addStarToLabel(label: UILabel){
    if(!GlobalhasPremium){
      label.text = "\(label.text!)*"
    }
  }
  
  func addButtonWithDescription(img: UIImage, text: String, y: Int) -> Int{
    var internY = y
    
    let image = UIImageView(frame: CGRect(x: 8, y: internY, width: 50, height: 50))
    image.image = img
    self.addSubview(image)
    
    let imageDescription = UILabel(frame: CGRect(x: 66, y: internY + 8, width: Int(self.frame.width - 66 - 8), height: 30))
    imageDescription.text = text
    imageDescription.textColor = textColor
    imageDescription.font = textFont
    imageDescription.numberOfLines = 0
    imageDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
    imageDescription.sizeToFit()
    self.addSubview(imageDescription)
    internY += Int(max(imageDescription.frame.height + 8,50) + 8)
    return internY
  }
  
  init(titleText: String, sunline: Sunline, seperator: Bool){
    if(!seperator){
      self.seperator.isHidden = true
    }
    
    
    let cardHeight = 152
    let yOffset = 8
    
    super.init(frame: CGRect(x: 16, y: nextY, width: Globalwidth - 32, height: cardHeight))
    nextY += cardHeight + yOffset
    self.backgroundColor = UIColor.white
    
    let yBetween = 22
    var y = 39
    
    let title = UILabel(frame: CGRect(x: 8, y: 9, width: 200, height: 30))
    title.text = titleText
    title.textColor = textColor
    title.font = titleFont
    self.addSubview(title)
   
    let timeStrings = sunline.getSunrisePeakSunset()
    
    let sunrise = UILabel(frame: CGRect(x: 8, y: y, width: 200, height: 20))
    sunrise.text = (Gb?.localizedString(forKey: "sunrise", value: nil, table: nil))!
    sunrise.textColor = textColor
    sunrise.font = textFont
    self.addSubview(sunrise)
   
    let rightX = self.bounds.width - 8 - 50
    let sunriseTime = UILabel(frame: CGRect(x: rightX, y: CGFloat(y), width: 50, height: 20))
    sunriseTime.text = timeStrings[0]
    sunriseTime.textColor = textColor
    sunriseTime.textAlignment = .right
    sunriseTime.font = textFont
    self.addSubview(sunriseTime)
    
    y += yBetween
    let sunset = UILabel(frame: CGRect(x: 8, y: y, width: 200, height: 20))
    sunset.text = (Gb?.localizedString(forKey: "sunset", value: nil, table: nil))!
    sunset.textColor = textColor
    sunset.font = textFont
    self.addSubview(sunset)

    let sunsetTime = UILabel(frame: CGRect(x: rightX, y: CGFloat(y), width: 50, height: 20))
    sunsetTime.text = timeStrings[1]
    sunsetTime.textColor = textColor
    sunsetTime.textAlignment = .right
    sunsetTime.font = textFont
    self.addSubview(sunsetTime)
    
    y += yBetween
    let solarNoon = UILabel(frame: CGRect(x: 8, y: y, width: 200, height: 20))
    solarNoon.text = (Gb?.localizedString(forKey: "solar_noon", value: nil, table: nil))!
    solarNoon.textColor = textColor
    solarNoon.font = textFont
    self.addSubview(solarNoon)
    
    let solarNoonTime = UILabel(frame: CGRect(x: rightX, y: CGFloat(y), width: 50, height: 20))
    solarNoonTime.text = timeStrings[2]
    solarNoonTime.textColor = textColor
    solarNoonTime.textAlignment = .right
    solarNoonTime.font = textFont
    self.addSubview(solarNoonTime)
    
    y += yBetween
    let dayLength = UILabel(frame: CGRect(x: 8, y: y, width: 200, height: 20))
    dayLength.text = (Gb?.localizedString(forKey: "day_length", value: nil, table: nil))!
    dayLength.textColor = textColor
    dayLength.font = textFont
    self.addSubview(dayLength)
    
    let dayLengthTime = UILabel(frame: CGRect(x: rightX, y: CGFloat(y), width: 50, height: 20))
    dayLengthTime.text = timeStrings[3]
    dayLengthTime.textColor = textColor
    dayLengthTime.textAlignment = .right
    dayLengthTime.font = textFont
    self.addSubview(dayLengthTime)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.white
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

  }
  
  @IBInspectable var cornerradius: CGFloat = 2
  @IBInspectable var shadowOffsetWidth: CGFloat = 0
  @IBInspectable var shadowOffsetHeight: CGFloat = 5
  @IBInspectable var shadowColor: UIColor = UIColor.black
  @IBInspectable var shadowOpacity: CGFloat = 0.5
  
  override func layoutSubviews() {
    
    let width = CGFloat(1.0)
    let intensity = CGFloat(235.0 / 255.0)
    seperator.borderColor = UIColor(red: intensity, green: intensity, blue: intensity, alpha: 1.0).cgColor
    seperator.frame = CGRect(x: 0, y: frame.size.height - width,width:frame.size.width,height: frame.size.height)
    seperator.borderWidth = width
    layer.addSublayer(seperator)
    layer.masksToBounds = true
  }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
