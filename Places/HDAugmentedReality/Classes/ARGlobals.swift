//
//  ARGlobals.swift
//  Places
//
//  Created by Phillip Løjmand on 20/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import GLKit
import CoreMotion
import SwiftyStoreKit
import StoreKit
import SpriteKit
import CoreLocation
import Firebase

public var FPS : Double = 60
public var targetFPS : Double = 60

public var GlobaldebugSpeed = false

public var GlobalsunPos = Polar()
private var GlobalsunPosMinus = Polar()
private var GlobalsunPosPlus = Polar()
private var GlobalsunPos3D = Vector()
private var GlobalsunPos3DMinus = Vector()
private var GlobalsunPos3DPlus = Vector()

public var GlobalprojectionMatrix:GLKMatrix4?
public var GlobalrotationMatrix = GLKMatrix4()
public var GlobalRequiredReadings = 10

public var GlobalinversedprojectionMatrix = GLKMatrix4()
public var Globalwidth = 0
public var Globalheight = 0

public var Globalboundary = Vector(0.08,0.17)
public var Globalheading : Float = 0
public var Globalalt: Float = 0
public var GlobalhorizonAngle: Float = 0
public var GlobalhorizonAngleAvailable = false
public let GlobalhorizonVector = Vector()
public var GlobalelevationAngle : Float = 0

public var GlobaltodayLabel = ""
public var GlobalreverseLabel = ""
public var GlobalsolsticeLabel = "21. \((Gb?.localizedString(forKey: "june", value: nil, table: nil))!)"
public var GlobalsolticeLabel = "21. \((Gb?.localizedString(forKey: "dec", value: nil, table: nil))!)"


public var GlobalparagraphStyleCenter = NSMutableParagraphStyle()
public var GlobalparagraphStyleLeft = NSMutableParagraphStyle()

public var GlobalmanualCalibration = false

public var GlobalfakeMillis1 = 0
public var GlobalfakeMillis2 = 0
public var Globallive = true

public let Globalprecision = 0.25/3

//Buttons
public var GloballiveButton: UIButton! = nil
public var GlobalcalendarButton: UIButton! = nil
public var GlobalcameraButton: UIButton! = nil
public var GlobalfreezeButton: UIButton! = nil
public var GlobaldrawButton: UIButton! = nil
public var GlobaldeleteButton: UIButton! = nil
public var GloballineButton: UIButton! = nil
public var GlobalundoButton: UIButton! = nil
public var GlobaloverlayTrackingModeButton: UIButton! = nil
public var GlobalmapButton: UIButton! = nil
public var GlobalsearchButton: UIButton! = nil
public var GlobalpremiumButton: UIButton! = nil

//Button
public var GlobalAllButtons = [UIButton]()

//Label Map
public var GlobalbuttonLabels = [UIButton : UILabel]()

//Button images
public let GloballiveImage = UIImage(named: "ic_now.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalnotliveImage = UIImage(named: "ic_notnow.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalcalendarImage = UIImage(named: "ic_calendar.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalcameraImage = UIImage(named: "ic_camera.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalrecordImage = UIImage(named: "ic_record.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalfreezeImage = UIImage(named: "ic_freeze.png")?.withRenderingMode(.alwaysTemplate)
public let GlobaldrawImage = UIImage(named: "ic_draw.png")?.withRenderingMode(.alwaysTemplate)
public let GlobaldeleteImage = UIImage(named: "ic_delete.png")?.withRenderingMode(.alwaysTemplate)
public let GloballineImage = UIImage(named: "ic_line.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalundoImage = UIImage(named: "ic_undo.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalsearchImage = UIImage(named: "ic_search.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalcurrentLocationImage = UIImage(named: "ic_location.png")?.withRenderingMode(.alwaysTemplate)
public var GlobaloverlayTrackingModeButtonCurImg = UIImage(named: "ic_location.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalmapFollowImage = UIImage(named: "ic_follow.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalmarkerImage = UIImage(named: "ic_marker.png")?.withRenderingMode(.alwaysTemplate)
public let GlobalmapImage = UIImage(named: "ic_map.png")?.withRenderingMode(.alwaysTemplate)
public let GlobaltickImage = UIImage(named: "ic_tick.png")
public let GlobalcloseImage = UIImage(named: "hdar_close.png")
public let GlobaliconImage = UIImage(named: "ic_launcher.png")
public let GlobalpremiumImage = UIImage(named: "ic_star.png")?.withRenderingMode(.alwaysTemplate)

public var GlobaloverlayImage: UIImage!
//States
public var Globalfrozen = false
public var Globaldrawing = false
public var GlobalisDrawingLine = false

var GloballineWidth: CGFloat = 4

let GlobalbuttonHeight = 40
var GlobalbuttonOffsetBottom = 25
var GlobalbuttonOffsetLeft = 10

var Globaltoolbar: Toolbar? = nil
var GlobalToolbarHeight:Int!

var Globaltime1 = ""
var Globaltime2 = ""

var Globaldate1 = ""
var Globaldate2 = ""

var GlobalreadyToStartDraw = false
var GlobalreadyToDraw = false

public var Globalstrokes = 0

public var Globalshowbothtimes = false

public var GlobalcloseToSummer = false
public var GlobalcloseToWinter = false

public var GlobalreallycloseToSummer = false
public var GlobalreallycloseToWinter = false

public var GlobalsummerDate = Date()
public var GlobalwinterDate = Date()

public var GlobaltakingscreenshotWhole = false
public var Globaltakingscreenshot = false
public var GlobalisRecording = false
public var Globalscale: Float = 1

public var GlobalmagAcc = 0
public var GlobalmagAccAvailable = false

public var GlobalRotM11: Float = 0
public var GlobalRotM12: Float = 0
public var GlobalRotM13: Float = 0

public var GlobalRotM21: Float = 0
public var GlobalRotM22: Float = 0
public var GlobalRotM23: Float = 0

public var GlobalRotM31: Float = 0
public var GlobalRotM32: Float = 0
public var GlobalRotM33: Float = 0

//public let GlobalcolorAccent = UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 255/255)

public let GlobalcolorAccent = UIColor(red: 1, green: 0, blue: 0, alpha: 1)


public let GlobalstandardFontSize: Float = 12
public let GlobalmediumFontSize: Float = 18
public let GlobalbigFontSize: Float = 20

public var Globalcountrycode = ""
public var Globalcountry = ""
public var Globalpostalcode = ""
public var Globalcity = ""
public var Globalstreet = ""
public var Globalstreetnumber = ""
public var GlobalwholeAddress = ""
public var GlobalshortAddress = ""

public var GlobalscreenshotTime1 = ""
public var GlobalscreenshotTime2 = ""

public var GlobalArView = true

public var Gb: Bundle!
public var GloballanguageCode = ""

public var Globalorientation = Orientation.PORTRAIT

public var GlobalmenuButton: UIButton?
public var GlobalmenuButtonOffset = 15

public var Globalcalibrating = false
public var GlobalazimuthOffset:Float = 0
public var GlobalsavedAzimuthOffset:Float = 0

public var GlobalverticalOffset:Float = 0
public var GlobalsavedVerticalOffset:Float = 0

public var GlobalshowCalMSG = true

public var GlobalshowYearline  = false

public var GloballastUpdateSunYearline = 0

public var Globaltouching = false

public var Globalsunlineadder = 0
public var Globalmultiplier = 1

public var GlobalmenuActive = false

public var GlobalcompassAccuracy = 2

public var GlobalDTextWidth = 500

public var GlobalBlockedIshours = true

public var Globalunits = ["Sun hours", "Solar irradiance (kWh/m\u{00B2})"]

public var Globalcamerafunctions = ["Overlayed screenshot", "Record video"]

public var GlobalcameraisScreenshot = true

public var GlobalupdateCameraButton = false
public var GlobalupdateAllButtons = false

public var GlobalhasPremium = false
public var GlobalPremiumForever = false

public var GlobalPremiumMonthlyPrice = ""

public var GlobalPremiumYearlyPrice = ""

public var GlobalPremiumLifetimePrice = ""

public var GlobalPremiumMonthyInt = 20.0

public var GlobalPremiumYearlyInt = 85.0

public var GlobalPremiumLifetimeInt = 199.0

public var GlobalwaitAndSave = 0
public var GlobalcapturedImage: UIImage!
public var Globalunhide = false
public var GlobalsaveImage: UIImage!
public var inFrontView:UIImageView!

public var sceneView: SKView!

public var GlobalsW:Float = 90.0

public var GlobalcurveGradientShader = SKShader()

public var GlobalCurrentView = 0

public var GlobaltrackingOverlayMode = 0

public var GlobalMapType = 0

public var GlobalMapTimeZone:TimeZone!

public var GlobalButtonCol = UIColor.white

public var mapViewParagraphStyle = NSMutableParagraphStyle()
public var mapViewStringattributes:[NSAttributedString.Key : Any]!

var Globalinstance:ARViewController!

var Globalstore: StoreCom!

var GlobalcalibrateViewController:CalibrateViewController!

var GlobalcalibrationWarningLabel:UILabel!

var Globalnotchsize = 0

var GlobalsharedSecret = "534cc87f005a4a53b2818b9cf55e2728"

var GlobalHaveRetrievedProductInfo = false

var GlobalupdateUnits = false

var GlobaltimeSlider:UISlider!
var GlobaltimeSliderOffset = 0 //Also timestamp in seconds of sunrise

var GlobalMapSearchActive = false

public enum RegisteredPurchase : String {
  case SunAppPremiumMonthly = "SunAppPremium"
  case SunAppPremiumYearly = "SunAppPremiumYearly"
  case SunAppPremiumLifetime = "SunAppPremiumLifetime"
}

public func showMediaView() -> Bool{
  if(GlobalisRecording){
    return true
  }
  
  if(Globaltakingscreenshot){
    return true
  }
  
  //Uncomment this if we want media view for external screen recorder
  /*if #available(iOS 11.0, *) {
    if(UIScreen.main.isCaptured){
      return true
    }
  }*/
  return false
}

public func scaleX() -> Float{
  let resolution = UIScreen.main.nativeBounds
  return Float(resolution.width) / Float(Globalwidth)
}

public func scaleY() -> Float{
  let resolution = UIScreen.main.nativeBounds
  return Float(resolution.height) / Float(Globalheight)
}

public func mmtoMMM(_ mm: String)->String{
  switch mm {
  case "01":
    return (Gb?.localizedString(forKey: "jan", value: nil, table: nil))!
  case "02":
    return (Gb?.localizedString(forKey: "feb", value: nil, table: nil))!
  case "03":
    return (Gb?.localizedString(forKey: "mar", value: nil, table: nil))!
  case "04":
    return (Gb?.localizedString(forKey: "apr", value: nil, table: nil))!
  case "05":
    return (Gb?.localizedString(forKey: "may", value: nil, table: nil))!
  case "06":
    return (Gb?.localizedString(forKey: "jun", value: nil, table: nil))!
  case "07":
    return (Gb?.localizedString(forKey: "jul", value: nil, table: nil))!
  case "08":
    return (Gb?.localizedString(forKey: "aug", value: nil, table: nil))!
  case "09":
    return (Gb?.localizedString(forKey: "sep", value: nil, table: nil))!
  case "10":
    return (Gb?.localizedString(forKey: "oct", value: nil, table: nil))!
  case "11":
    return (Gb?.localizedString(forKey: "nov", value: nil, table: nil))!
  case "12":
    return (Gb?.localizedString(forKey: "dec", value: nil, table: nil))!
  default:
    break
  }
  return ""
}

public func mmtoMMMM(_ mm: String)->String{
  switch mm {
  case "01":
    return (Gb?.localizedString(forKey: "january", value: nil, table: nil))!
  case "02":
    return (Gb?.localizedString(forKey: "february", value: nil, table: nil))!
  case "03":
    return (Gb?.localizedString(forKey: "marts", value: nil, table: nil))!
  case "04":
    return (Gb?.localizedString(forKey: "april", value: nil, table: nil))!
  case "05":
    return (Gb?.localizedString(forKey: "may", value: nil, table: nil))!
  case "06":
    return (Gb?.localizedString(forKey: "june", value: nil, table: nil))!
  case "07":
    return (Gb?.localizedString(forKey: "july", value: nil, table: nil))!
  case "08":
    return (Gb?.localizedString(forKey: "august", value: nil, table: nil))!
  case "09":
    return (Gb?.localizedString(forKey: "september", value: nil, table: nil))!
  case "10":
    return (Gb?.localizedString(forKey: "october", value: nil, table: nil))!
  case "11":
    return (Gb?.localizedString(forKey: "november", value: nil, table: nil))!
  case "12":
    return (Gb?.localizedString(forKey: "december", value: nil, table: nil))!
  default:
    break
  }
  return ""
}

public func getAppStoreReceipt() -> Bool{
  dBug("GetAppStoreReceipt()")
  dBug("\(Bundle.main.appStoreReceiptURL)")
  
  if let appReceipt = Bundle.main.appStoreReceiptURL{
    guard let data = try? Data(contentsOf: appReceipt) else {
      dBug("No receipt data")
      return false
    }
    
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: GlobalsharedSecret)
    appleValidator.validate(receiptData: data, completion: { result in
      dBug("Receipt Result")
      switch result {
      case .success(let receipt):
       // print(receipt.debugDescription)
        let info = receipt["receipt"] as! ReceiptInfo
        if let original_version_number = info["original_application_version"]{
          let acceptable_versions = ["1.0.14","1.0.15","1.0.16","1.0.17","1.0.18","1.0.20","1.0.22","1.0.23","1","2","3","4","5","6","7","8","9","10","11","1.0","2.0","3.0","4.0","5.0","6.0","7.0","8.0","9.0","10.0","11.0","12"]
          if(acceptable_versions.contains(original_version_number as! String)){
            dBug("Original version")
            goPremiumForever()
          }else{
            UserDefaults.standard.set(false, forKey: "premiumForever")
          }
        }
        break
      case .error(let error):
        dBug("Could not validate local receipt")
      }
    })
    return true
  }
  return false
}

public func tryPremiumForever(){
  dBug("Maybe Permanent Premium()")
  /*GlobalPremiumForever = true
  GlobalhasPremium = true
  GlobalupdateAllButtons = true
  goPremiumForever()
  return*/
  if (UserDefaults.standard.object(forKey: "premiumForever") == nil){
    getAppStoreReceipt()
  }else if UserDefaults.standard.bool(forKey: "premiumForever"){
    dBug("Has Permanent Premium()")
    GlobalPremiumForever = true
    GlobalhasPremium = true
    GlobalupdateAllButtons = true
  }
}

public func finilizeGlobals(){
  //Check if original user

  if let premiumEnd = UserDefaults.standard.object(forKey: "premiumEnd") as? Int64 {
    print(premiumEnd)
    if premiumEnd > Int64(Date.init().timeIntervalSince1970){
      GlobalhasPremium = true //Should be true, testing
      GlobalupdateAllButtons = true
    }
  }
  tryPremiumForever()
  if(!GlobalPremiumForever){
    Globalstore = StoreCom()
    Globalstore.onLaunch()
    dBug("Premium \(GlobalhasPremium)")
  }

  
  Gb = Bundle.main
  
  GlobalBlockedIshours = (UserDefaults.standard.integer(forKey: "units") == 0)
  GlobalcameraisScreenshot = (UserDefaults.standard.integer(forKey: "camerafunction") == 0)
  
  setLanguage(lCode: UserDefaults.standard.string(forKey: "lc"))

  GlobalparagraphStyleCenter.alignment = .center
  GlobalparagraphStyleLeft.alignment = .left
  
  //Shaders
  GlobalcurveGradientShader = SKShader(fileNamed: "curveGradientShader.fsh")
  GlobalcurveGradientShader.attributes = [
    SKAttribute(name: "center_point", type: .vectorFloat2),
    SKAttribute(name: "minmax_dist", type: .vectorFloat2)
  ]
  
  mapViewParagraphStyle.alignment = .center
  mapViewStringattributes = [
      NSAttributedString.Key.foregroundColor: UIColor.yellow,
      NSAttributedString.Key.paragraphStyle: mapViewParagraphStyle,
      NSAttributedString.Key.font: UIFont(name: "SofiaPro-Bold", size: CGFloat(20))!
  ]
}

public func goPremium(_ expiry: Date){
  dBug("Premium untill \(expiry)")
  GlobalhasPremium = true //Should be true, testing
  DispatchQueue.main.async {
  updateAllButtons()
  }
  GlobalupdateAllButtons = true
  
  dBug("Go Premium \(GlobalhasPremium)")
  UserDefaults.standard.set(Int64(expiry.timeIntervalSince1970), forKey: "premiumEnd")
}

public func goPremiumForever(){
    dBug("Premium Forever")
    GlobalhasPremium = true //Should be true, testing
    GlobalPremiumForever = true
    GlobalupdateAllButtons = true
    DispatchQueue.main.async {
      updateAllButtons()
    }
    UserDefaults.standard.set(true, forKey: "premiumForever")
}


public func losePremium(){
  if(!GlobalPremiumForever){
    GlobalhasPremium = false
    GlobalupdateAllButtons = true
    DispatchQueue.main.async {
      updateAllButtons()
    }
    print("Premium \(GlobalhasPremium)")
    UserDefaults.standard.set(Int64(-1), forKey: "premiumEnd")
  }
}

func adjustAzimuth(heading:Float)->Float{
  return heading-GlobalazimuthOffset
}

func setLanguage(lCode: String?){
  dBug("Set Language")
  if(lCode != nil){
  let saveShowBothTimes = Globalshowbothtimes
  GloballanguageCode = lCode!
  UserDefaults.standard.set(GloballanguageCode, forKey: "lc")
  
  let path = Bundle.main.path(forResource: GloballanguageCode, ofType: "lproj")
  Gb = Bundle(path: path!)
  updateAllButtons()
  Globaltoolbar?.updateLanguageChange()
    if(GlobalcalibrationWarningLabel != nil){
      GlobalcalibrationWarningLabel.text = "\((Gb?.localizedString(forKey: "compass_warning", value: nil, table: nil))!)\(getCompassReliabilityString())"
      if(GlobalcompassAccuracy == 2){
        GlobalcalibrationWarningLabel.isHidden = true
      }
    }
    GlobalsolsticeLabel = "21. \((Gb?.localizedString(forKey: "june", value: nil, table: nil))!)"
    GlobalsolticeLabel = "21. \((Gb?.localizedString(forKey: "dec", value: nil, table: nil))!)"
    if(Globaltoolbar != nil){
    updateSunTimeLabel(label1Millis: (Globaltoolbar?.lastLabel1Millis)!)
    updateSunTime2Label(label2Millis: (Globaltoolbar?.lastLabel2Millis)!)
      print(Globalshowbothtimes)
    }
    Globalshowbothtimes = saveShowBothTimes
  }
}

func getCompassReliabilityString() ->String{
  var acc_string = ""
  if(GlobalcompassAccuracy == -1){
    acc_string = (Gb?.localizedString(forKey: "unreliable", value: nil, table: nil))!
  }
  if(GlobalcompassAccuracy == 0){
    acc_string = (Gb?.localizedString(forKey: "low", value: nil, table: nil))!
  }
  if(GlobalcompassAccuracy == 1){
    acc_string = (Gb?.localizedString(forKey: "medium", value: nil, table: nil))!
  }
  if(GlobalcompassAccuracy == 2){
    acc_string = (Gb?.localizedString(forKey: "high", value: nil, table: nil))!
  }
  dBug("GetCompassReliabilityString \(acc_string)")
  return acc_string
}

public func setProjectionMatrix(matrix: GLKMatrix4?){
  dBug("SetProjectionMatrix")
  GlobalprojectionMatrix = matrix
  if(matrix == nil){
    return
  }
  let isInvertible = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
  GlobalinversedprojectionMatrix = GLKMatrix4Invert(matrix!, isInvertible)
  let polar = convertToPolar(pointXY: Vector(0,0))
  Globalheading = polar.az()
  Globalalt = polar.alt()
  updateHorizonAngle()
}

public func setRotationMatrix(matrix: GLKMatrix4){
  GlobalrotationMatrix = matrix
  dBug("SetRotationMatrix")
}

public func updateHorizonAngle(){
  dBug("UpdateHorizonAngle")
  let values = getOrientation()
  GlobalhorizonAngle = addAZ(values.z(), Float.pi / 2)
  GlobalhorizonAngleAvailable = true
 // GlobalhorizonAngle = values.z()
  GlobalelevationAngle = -values.y()
  GlobalhorizonVector.setX(-sin(GlobalhorizonAngle))
  GlobalhorizonVector.setY(cos(GlobalhorizonAngle))
}

public func getOrientation() -> Vector{
//  let yaw = atan(GlobalrotationMatrix.m01 / GlobalrotationMatrix.m00)
//  let pitch = atan(-GlobalrotationMatrix.m02 / sqrt(pow(GlobalrotationMatrix.m12,2) + pow(GlobalrotationMatrix.m22,2)))
//  let roll = atan(GlobalrotationMatrix.m12 / GlobalrotationMatrix.m22)
  
  let yaw = atan2(GlobalrotationMatrix.m02, GlobalrotationMatrix.m12)
  let pitch = acos(GlobalrotationMatrix.m22)
  let roll = -atan2(GlobalrotationMatrix.m20, GlobalrotationMatrix.m21)
  return Vector(yaw, pitch, roll)
}

public func setSunPos(millis: Int){
  GlobalsunPos = sunPositionOwnMath(millis: millis)
  GlobalsunPosPlus = sunPositionOwnMath(millis: millis + 200 * 1000 * Globalmultiplier)
  GlobalsunPosMinus = sunPositionOwnMath(millis: millis - 200 * 1000 * Globalmultiplier)
  updateSunPos3D()
}

public func updateSunTimeLabel(label1Millis: Int){
  dBug("UpdateSunTimeLabel \(label1Millis)")
  let date = Date(timeIntervalSince1970: TimeInterval(label1Millis / 1000))
  let dateFormatter = getDateFormatterTimezone()

  var stringBuilder = ""
  dateFormatter.dateFormat = "dd."
  stringBuilder = dateFormatter.string(from: date)
  dateFormatter.dateFormat = "MM"
  stringBuilder = "\(stringBuilder) \(mmtoMMM(dateFormatter.string(from: date)))"
  GlobaltodayLabel = stringBuilder
}

public func updateSunTime2Label(label2Millis: Int){
  let date = Date(timeIntervalSince1970: TimeInterval(label2Millis / 1000))
  let dateFormatter = getDateFormatterTimezone()
  var stringBuilder = ""
  dateFormatter.dateFormat = "dd."
  stringBuilder = dateFormatter.string(from: date)
  dateFormatter.dateFormat = "MM"
  stringBuilder = "\(stringBuilder) \(mmtoMMM(dateFormatter.string(from: date)))"
  GlobalreverseLabel = stringBuilder
  
}

public func getHourStringFromMillis(millis: Int) -> String {
  let date = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
  let dateFormatter = getDateFormatterTimezone()
  dateFormatter.dateFormat = "HH"
  return dateFormatter.string(from: date)
}

public func getHourMinStringFromMillis(millis: Int) -> String {
  let date = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
  let dateFormatter = getDateFormatterTimezone()
  dateFormatter.dateFormat = "HH:mm"
  return dateFormatter.string(from: date)
}

public func getSunPos() -> Polar{
  return GlobalsunPos
}

public func getSunPos3D() -> Vector{
  return GlobalsunPos3D
}

public func getSunPos3DPlus() -> Vector{
  return GlobalsunPos3DPlus
}

func updateSunPos3D(){
  dBug("UpdateSunPos3D")
  GlobalsunPos3D = polarTo3D(polar: GlobalsunPos)
  GlobalsunPos3DMinus = polarTo3D(polar: GlobalsunPosMinus)
  GlobalsunPos3DPlus = polarTo3D(polar: GlobalsunPosPlus)
}

public func currentMillis() -> Int{
  return Date().millisecondsSince1970
}

public func usingMillis() -> Int{
  if(Globallive){
    return currentMillis()
  }
  return GlobalfakeMillis1
}

public func updateTime(_ millis: Int){
  dBug("UpdateTime \(millis)")
  GlobalfakeMillis1 = millis
  setLive(false)
  updateSun(millis)
  Globaltoolbar?.updateLabel1FromMillis(millis)
}

public func updateTime2(_ millis: Int){
  GlobalfakeMillis2 = millis
  updateSunTime2Label(label2Millis: millis)
  Globaltoolbar?.updateLabel2FromMillis(millis)
}

public func updateTimeToLive(){
  dBug("updateTimeToLive()")
  setLive(true)
  updateSun(currentMillis())
}

private func setLive(_ isLive: Bool){
  dBug("Setlive()")
  if(isLive != Globallive){
    Globallive = isLive
    updateLiveButton()
  }
}

public func setDrawing(_ isDrawing: Bool){
  if(isDrawing != Globaldrawing){
  Globaldrawing = isDrawing
  updateAllButtons()
    if(Globalorientation == Orientation.PORTRAIT){
      Globaltoolbar?.setLabelsFramePortrait()
    }
  }
}

extension UIButton {
  func setVisibility(_ visible: Bool){
    isHidden = !visible
    if(Globalorientation == Orientation.PORTRAIT){
      GlobalbuttonLabels[self]?.isHidden = !visible
      }
    if(Globalorientation == Orientation.LANDSCAPE){
      GlobalbuttonLabels[self]?.isHidden = true
      }
    }
  
  func updateButtonLocation(place: Int, buttons: Int){
    self.frame = getButtonFrame(place: place, buttons: buttons)
    
    if(Globalorientation == Orientation.PORTRAIT){
      GlobalbuttonLabels[self]?.isHidden = false
      GlobalbuttonLabels[self]?.textColor = GlobalButtonCol
      GlobalbuttonLabels[self]?.frame = getLabelFrame(place: place, buttons: buttons)
      GlobalbuttonLabels[self]?.center = getLabelCenter(place: place, buttons: buttons)
      self.transform = CGAffineTransform.identity
    } else if(Globalorientation == Orientation.LANDSCAPE){
      GlobalbuttonLabels[self]?.isHidden = true
      self.transform = CGAffineTransform.identity.rotated(by: CGFloat(Float.pi / 2))
    }
    }
  }

public func updateSun(_ millis: Int){
  dBug("updateSun \(millis)")
  updatePositionYearMath(millis)
  setSunPos(millis: millis)
  updateSunTimeLabel(label1Millis: millis)
  if(GlobalshowYearline && abs(GloballastUpdateSunYearline - millis) > 1000 * 15 && !Globaltouching){
    updateYearLine()
    GloballastUpdateSunYearline = millis
  }
}

public func getButtonFrame(place: Int, buttons: Int) -> CGRect{
  var leftX: Int!
  var topY: Int!
  if(Globalorientation == Orientation.PORTRAIT){
  leftX = Int(Float(Globalwidth) / Float(buttons) * Float(place) - Float(GlobalbuttonHeight / 2) - Float(Globalwidth / (buttons * 2)))
  topY = Globalheight - GlobalbuttonHeight - GlobalbuttonOffsetBottom
    if(GlobalCurrentView == 1){
      topY -= 14
    }
  }
  if(Globalorientation == Orientation.LANDSCAPE){
    leftX = GlobalbuttonHeight + buttons * (GlobalbuttonHeight + 6) - place * (GlobalbuttonHeight + 6)
    if(UIDevice.current.userInterfaceIdiom == .phone){
      leftX -= GlobalbuttonHeight / 2
    }
    leftX = Int(Double(leftX))
    topY = GlobalbuttonOffsetLeft
    return CGRect(x: leftX, y: topY, width: Int(Double(GlobalbuttonHeight)), height: Int(Double(GlobalbuttonHeight)))
  }
return CGRect(x: leftX, y: topY, width: Int(Double(GlobalbuttonHeight)), height: Int(Double(GlobalbuttonHeight)))
  
}

public func getLabelFrame(place: Int, buttons: Int) -> CGRect{
  let leftX = Int(Float(Globalwidth) / Float(buttons) * Float(place) - Float(GlobalbuttonHeight / 2) - Float(Globalwidth / (buttons * 2)))
  var topY = Globalheight - GlobalbuttonHeight - GlobalbuttonOffsetBottom
  if(GlobalCurrentView == 1){
    topY -= 14
  }
  return CGRect(x: leftX - GlobalbuttonHeight / 2, y: topY + GlobalbuttonHeight, width: GlobalbuttonHeight * 2, height: GlobalbuttonHeight)
}

public func getPremiumLabelFrame(place: Int, buttons: Int) -> CGRect{
  let premiumTextWidth = GlobalbuttonHeight * 3
  let leftX = Int(Float(Globalwidth) / Float(buttons) * Float(place) - Float(premiumTextWidth / 2) - Float(Globalwidth / (buttons * 2)))
  let topY = Globalheight - GlobalbuttonHeight - GlobalbuttonOffsetBottom - 10
  return CGRect(x: leftX - premiumTextWidth / 2, y: topY + GlobalbuttonHeight, width: premiumTextWidth * 2, height: GlobalbuttonHeight)
}

public func getLabelCenter(place: Int, buttons: Int) -> CGPoint{
  let leftX = Int(Float(Globalwidth) / Float(buttons) * Float(place) - Float(GlobalbuttonHeight / 2) - Float(Globalwidth / (buttons * 2)))
  var topY = Globalheight - GlobalbuttonHeight - GlobalbuttonOffsetBottom
  if(GlobalCurrentView == 1){
     topY -= 14
   }
  return CGPoint(x: Double(leftX + GlobalbuttonHeight / 2), y: Double(topY) + Double(GlobalbuttonHeight) * 1.2)
}

public func updateLiveButton(){
  if(GloballiveButton != nil){
     GlobalbuttonLabels[GloballiveButton]?.text = (Gb?.localizedString(forKey: "live", value: nil, table: nil))!
     GloballiveButton.updateButtonLocation(place: 1, buttons: buttons())
    
    //Shouldn't show this button when drawing
    if(Globaldrawing || !GlobalhasPremium || GlobalMapSearchActive){
      GloballiveButton.setVisibility(false)
      //GloballiveButton.isHidden = true
     // GlobalbuttonLabels[GloballiveButton]?.isHidden = true
    }else{
      GloballiveButton.setVisibility(true)
     // GloballiveButton.isHidden = false
     // GlobalbuttonLabels[GloballiveButton]?.isHidden = false
    }
    if(!Globallive){
      GloballiveButton.tintColor = GlobalButtonCol
      GloballiveButton.setImage(GlobalnotliveImage, for: .normal)
    }else{
      GloballiveButton.tintColor = GlobalcolorAccent
      GloballiveButton.setImage(GloballiveImage, for: .normal)
    }
  }
}

public func updatePremiumButton(){
  if(GlobalpremiumButton != nil){
    GlobalbuttonLabels[GlobalpremiumButton]?.text = (Gb?.localizedString(forKey: "get_premium", value: nil, table: nil))!
    if(GlobalhasPremium || GlobalMapSearchActive){
      GlobalpremiumButton.setVisibility(false)
      Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "111",
           AnalyticsParameterItemName: "hasPremium",
           AnalyticsParameterContentType: "hasPremium"])
    }else{
      GlobalpremiumButton.setVisibility(true)
    }
  }
}

public func updateCalendarButton(){
  if(GlobalcalendarButton != nil){
    GlobalcalendarButton?.tintColor = GlobalButtonCol
    GlobalbuttonLabels[GlobalcalendarButton]?.text = (Gb?.localizedString(forKey: "date", value: nil, table: nil))!
    GlobalcalendarButton.updateButtonLocation(place: 2, buttons: buttons())
    
    //Shouldn't show this button when drawing
    if(Globaldrawing || !GlobalhasPremium || GlobalMapSearchActive){
      GlobalcalendarButton.setVisibility(false)
    }else{
      GlobalcalendarButton.setVisibility(true)
    }
  }
}

public func updateFreezeButton(){
  if(GlobalfreezeButton != nil){
   GlobalbuttonLabels[GlobalfreezeButton]?.text = (Gb?.localizedString(forKey: "freeze", value: nil, table: nil))!
    if(deleteShouldBeVisible()){
      GlobalfreezeButton.updateButtonLocation(place: 5, buttons: buttons())
    }else{
      GlobalfreezeButton.updateButtonLocation(place: 4, buttons: buttons())
    }
    if(!Globalfrozen){
      GlobalfreezeButton.tintColor = GlobalButtonCol
    }else{
      GlobalfreezeButton.tintColor = GlobalcolorAccent
    }
    if(GlobalhasPremium && GlobalCurrentView == 0 && !GlobalMapSearchActive){
      GlobalfreezeButton.setVisibility(true)
    }else{
      GlobalfreezeButton.setVisibility(false)
    }
  }
}

public func updateDrawButton(){
  if(GlobaldrawButton != nil){
  GlobalbuttonLabels[GlobaldrawButton]?.text = (Gb?.localizedString(forKey: "draw", value: nil, table: nil))!
    if(deleteShouldBeVisible()){
      GlobaldrawButton.updateButtonLocation(place: 6, buttons: buttons())
    }else{
      GlobaldrawButton.updateButtonLocation(place: 5, buttons: buttons())
    }
    
    if(!Globaldrawing){
      GlobaldrawButton.tintColor = GlobalButtonCol
    }else{
      GlobaldrawButton.tintColor = GlobalcolorAccent
    }
    if(GlobalhasPremium && GlobalCurrentView == 0 && !GlobalMapSearchActive){
      GlobaldrawButton.setVisibility(true)
    }else{
      GlobaldrawButton.setVisibility(false)
    }
  }
}

public func updateLineButton(){
  if(GloballineButton != nil){
    GlobalbuttonLabels[GloballineButton]?.text = (Gb?.localizedString(forKey: "line", value: nil, table: nil))!
    
    GloballineButton.updateButtonLocation(place: 1, buttons: buttons())
    
    if(!GlobalisDrawingLine){
      GloballineButton.tintColor = GlobalButtonCol
    }else{
      GloballineButton.tintColor = GlobalcolorAccent
    }
    
    //Shouldn't show this button when drawing
    if(Globaldrawing && GlobalhasPremium && !GlobalMapSearchActive){
      GloballineButton.setVisibility(true)
    }else{
      GloballineButton.setVisibility(false)
    }
    
  }
}

public func updateUndoButton(){
  if(GlobalundoButton != nil){
    GlobalbuttonLabels[GlobalundoButton]?.text = (Gb?.localizedString(forKey: "undo", value: nil, table: nil))!

    GlobalundoButton.updateButtonLocation(place: 2, buttons: buttons())
    //Shouldn't show this button when drawing
    if(Globalstrokes == 0){
      GlobalundoButton.tintColor = UIColor.gray
    }else{
      GlobalundoButton.tintColor = GlobalButtonCol
    }
    
    if(Globaldrawing && GlobalhasPremium && !GlobalMapSearchActive){
      GlobalundoButton.setVisibility(true)
    }else{
      GlobalundoButton.setVisibility(false)
    }
    
  }
}

public func updateCaptureButton(){
  if(GlobalcameraButton != nil){

    if(deleteShouldBeVisible()){
      GlobalcameraButton.updateButtonLocation(place: 4, buttons: buttons())
    }else{
      GlobalcameraButton.updateButtonLocation(place: 3, buttons: buttons())
    }
    
    if (GlobalcameraisScreenshot){
      GlobalbuttonLabels[GlobalcameraButton]?.text = (Gb?.localizedString(forKey: "capture", value: nil, table: nil))!
      GlobalcameraButton.setImage(GlobalcameraImage, for: .normal)
    }else{
      GlobalbuttonLabels[GlobalcameraButton]?.text = (Gb?.localizedString(forKey: "record", value: nil, table: nil))!
      GlobalcameraButton.setImage(GlobalrecordImage, for: .normal)
      if(!GlobalisRecording){
        GlobalcameraButton.tintColor = GlobalButtonCol
      }else{
        GlobalcameraButton.tintColor = GlobalcolorAccent
      }
    }
    if(GlobalhasPremium && GlobalCurrentView == 0 && !GlobalMapSearchActive){
      GlobalcameraButton.setVisibility(true)
    }else{
      GlobalcameraButton.setVisibility(false)
    }
  }
}

public func updateClearButton(){
  
  if(GlobaldeleteButton != nil){
    if(Globaldrawing){
      GlobaldeleteButton.isHidden = false
    }
    GlobalbuttonLabels[GlobaldeleteButton]?.text = (Gb?.localizedString(forKey: "clear", value: nil, table: nil))!
    GlobaldeleteButton.updateButtonLocation(place: 3, buttons: buttons())
    if(Globalstrokes == 0 || !Globaldrawing){
      GlobaldeleteButton.isHidden = true
      GlobalbuttonLabels[GlobaldeleteButton]?.isHidden = true
    }
  }
}

public func updateOverlayTrackingModeButton(){
  if(GlobaloverlayTrackingModeButton != nil){
     GlobaloverlayTrackingModeButton?.tintColor = GlobalButtonCol
    if(GlobaltrackingOverlayMode == 0){
      GlobalbuttonLabels[GlobaloverlayTrackingModeButton]?.text = lString("here")
    }else if(GlobaltrackingOverlayMode == 1){
      GlobalbuttonLabels[GlobaloverlayTrackingModeButton]?.text = lString("center")
    }else if(GlobaltrackingOverlayMode == 2){
      GlobalbuttonLabels[GlobaloverlayTrackingModeButton]?.text = lString("placed")
    }
    
    GlobaloverlayTrackingModeButton.setImage(GlobaloverlayTrackingModeButtonCurImg, for: .normal)
    GlobaloverlayTrackingModeButton.updateButtonLocation(place: 3, buttons: buttons())
  
    if(GlobalhasPremium && GlobalCurrentView == 1 && !GlobalMapSearchActive){
      GlobaloverlayTrackingModeButton.setVisibility(true)
    }else{
      GlobaloverlayTrackingModeButton.setVisibility(false)
    }
  }
}

public func updateMapButton(){
  if(GlobalmapButton != nil){
    GlobalmapButton?.tintColor = GlobalButtonCol
    GlobalmapButton.updateButtonLocation(place: 4, buttons: buttons())
    if(GlobalMapType == 0){
      GlobalbuttonLabels[GlobalmapButton]?.text = lString("street")
    }else if(GlobalMapType == 1){
      GlobalbuttonLabels[GlobalmapButton]?.text = lString("satellite")
    }
     if(GlobalhasPremium && GlobalCurrentView == 1 && !GlobalMapSearchActive){
      GlobalmapButton.setVisibility(true)
    }else{
      GlobalmapButton.setVisibility(false)
    }
  }
}

public func updateSearchButton(){
  if(GlobalsearchButton != nil){
    GlobalsearchButton?.tintColor = GlobalButtonCol
    GlobalbuttonLabels[GlobalsearchButton]?.text = lString("search")
    if(GlobalCurrentView == 1 && GlobalhasPremium && !GlobalMapSearchActive){
      GlobalsearchButton.updateButtonLocation(place: 5, buttons: buttons())
      GlobalsearchButton.setVisibility(true)
    }else{
      GlobalsearchButton.setVisibility(false)
    }
  }
}

public func updateAllButtons(){
  dBug("updateAllButtons()")
  
  if(GlobalCurrentView == 1 && GlobalMapType == 0){
    GlobalButtonCol = UIColor.gray
  }else{
    GlobalButtonCol = UIColor.white
  }
  updateLiveButton()
  updateCalendarButton()
  updateFreezeButton()
  updateDrawButton()
  updateLineButton()
  updateUndoButton()
  updateCaptureButton()
  updateClearButton()
  updatePremiumButton()
  updateOverlayTrackingModeButton()
  updateMapButton()
  updateSearchButton()
  
}

public func buttons() -> Int{
  if(deleteShouldBeVisible()){
    return 6
  }
  return 5
}


public func deleteShouldBeVisible() -> Bool{
  if(Globaldrawing && Globalstrokes > 0 && GlobalhasPremium){
    return true
  }else{
    return false
  }
}

public func updateDeleteButton(){
  if(GlobaldeleteButton != nil){
    GlobaldeleteButton.updateButtonLocation(place: 3, buttons: buttons())
    
    //Shouldn't show this button when drawing
    if(deleteShouldBeVisible()){
      GlobaldeleteButton.setVisibility(true)
    }else{
      GlobaldeleteButton.setVisibility(false)
    }
  }
}

public func getTimeString(_ time: Int) -> String{
    let date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
    let dateFormatter = getDateFormatterTimezone()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

public func getDateFormatterTimezone() -> DateFormatter{
  let dateFormatter = DateFormatter()
  if(GlobalCurrentView == 1 && GlobalMapTimeZone != nil){
    dateFormatter.timeZone = GlobalMapTimeZone
  }
  return dateFormatter
}

public func updatePseudoOrientation()->Bool{
  dBug("updatePseudoOrientation()")
  if(!GlobalhorizonAngleAvailable){
    dBug("updatePseudoOrientation()1")
    return false
  }
  //Returns didchange
  let modAngle = radToDeg(GlobalhorizonAngle - Float.pi/2)
  if(Globalalt < -1.4){
    //Don't change orientation when device is laying flat on the table
    dBug("updatePseudoOrientation()2")
    return false
  }
  if(modAngle < -55 && Globalorientation == Orientation.PORTRAIT){
    setPseudoOrientation(Orientation.LANDSCAPE)
    dBug("updatePseudoOrientation()3")
    return true
  }
  if(modAngle > -35 && Globalorientation == Orientation.LANDSCAPE){
    setPseudoOrientation(Orientation.PORTRAIT)
    dBug("updatePseudoOrientation()4")
    return true
  }
  return false
}

public func setPseudoOrientation(_ orientation: Orientation){
  dBug("setPseudoOrientation \(orientation)")
  if(orientation != Globalorientation && !GlobalmenuActive){
    Globalorientation = orientation
    Globaltoolbar?.updateOrientation()
    if(Globalorientation == Orientation.PORTRAIT){
      GlobalcalibrationWarningLabel.transform = CGAffineTransform.identity
      
      GlobalcalibrationWarningLabel.frame = CGRect(x: 8,y: 48 + max(Globalnotchsize - 10,0), width: Globalwidth - 16, height: 32)
    }
    if(Globalorientation == Orientation.LANDSCAPE){
      GlobalcalibrationWarningLabel.frame = CGRect(x: Globalwidth / 2 - 56,y: 8 + Globalwidth / 2 - 16, width: Globalwidth - 16, height: 32)
      
      let transform = CGAffineTransform.identity.rotated(by: CGFloat(Float.pi / 2))
    //  transform = transform.translatedBy(x: CGFloat(CGFloat(Globalheight) / 2 - 32 / 2), y: CGFloat(Globalheight) / 2 - CGFloat(Globalwidth) + 32 / 2)
      GlobalcalibrationWarningLabel.transform = transform
    }
    
    updateAllButtons()
  }
}

public func saveAndResetAzimuthOffset(){
  GlobalsavedAzimuthOffset = GlobalazimuthOffset
  GlobalazimuthOffset = 0
}

public func saveAndResetVerticalOffset(){
  GlobalsavedVerticalOffset = GlobalverticalOffset
  GlobalverticalOffset = 0
}

public func loadAzimuthOffset(){
  GlobalazimuthOffset = GlobalsavedAzimuthOffset
}

public func loadVerticalOffset(){
  GlobalverticalOffset = GlobalsavedVerticalOffset
}

public func setVerticalOffset(offset: Float){
  GlobalverticalOffset = offset
}

public func setAzimuthOffset(offset: Float){
  GlobalazimuthOffset = offset
}


public enum Orientation {
  case LANDSCAPE, PORTRAIT
}

public enum TouchEvent {
  case ACTION_DOWN, ACTION_UP, ACTION_MOVE
}


public func radToDeg(_ radians: Float) -> Float
{
  return (radians) * (180.0 / Float.pi)
}

public func degToRad(_ degrees: Float) -> Float
{
  return (degrees) * (Float.pi / 180.0)
}
func degToRadD(_ deg: Double) -> Double {
  return deg * ( Double.pi / 180.0 );
}

func abs(_ a: Float, _ b: Float) -> Float{
  if(a > b){
    return a
  }else{
    return b
  }
}

func signum(_ v: Double) -> Double{
  if(v > 0){
    return 1
  }
  if(v < 0){
    return -1
  }
  return 0
}

func signum(_ v: Float) -> Float{
  if(v > 0){
    return 1
  }
  if(v < 0){
    return -1
  }
  return 0
}

func signum(_ v: Int) -> Int{
  if(v > 0){
    return 1
  }
  if(v < 0){
    return -1
  }
  return 0
}

func mod(_ a:Float, _ b:Float) -> Float{
  let c = a.remainder(dividingBy: b)
  if (c < 0){
    return c + b
  }
  return c
}


public func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
  //Calculate the size of the rotated view's containing box for our drawing space
  let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
  let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
  rotatedViewBox.transform = t
  let rotatedSize: CGSize = rotatedViewBox.frame.size
  //Create the bitmap context
  UIGraphicsBeginImageContext(rotatedSize)
  let bitmap: CGContext = UIGraphicsGetCurrentContext()!
  //Move the origin to the middle of the image so we will rotate and scale around the center.
  bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
  //Rotate the image context
  bitmap.rotate(by: (degrees * CGFloat.pi / 180))
  //Now, draw the rotated/scaled image into the context
  bitmap.scaleBy(x: 1.0, y: -1.0)
  bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
  let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext()
  return newImage
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

public func addTitleWithBackButton(ctrl: UIViewController, titleText: String) -> UIButton{
  let contentX = 24
  let backbutton = UIButton(frame: CGRect(x: contentX, y: 50, width: 32, height: 32))
  backbutton.setImage(UIImage(named: "ic_back.png"), for: .normal)
  backbutton.imageView?.contentMode = .scaleAspectFit
  ctrl.view.addSubview(backbutton)
  
  let textColor = UIColor(red: 72 / 255, green: 72 / 255, blue: 72 / 255, alpha: 1.0)
  let title = UILabel(frame: CGRect(x: contentX, y: 80, width: Globalwidth - 32, height: 40))
  title.text = titleText
  title.textColor = textColor
  title.font = UIFont(name: "SofiaPro-Bold", size: CGFloat(30))
  ctrl.view.addSubview(title)
  return backbutton
}

public func setCameraFunction(row: Int){
  print("Set units \(row)")
  GlobalcameraisScreenshot = (row == 0)
  UserDefaults.standard.set(row, forKey: "camerafunction")
  updateAllButtons()
}

func updateGlobalTimeSlider(_ millis: Int){
  if(GlobaltimeSlider != nil && sunline != nil && sunline.sunRiseSetNoonTime.count > 1){
    GlobaltimeSlider.isEnabled = true
    GlobaltimeSliderOffset = sunline.sunRiseSetNoonTime[0] / 1000
    GlobaltimeSlider.minimumValue = 0
    if(!sunline.sunriseExist){
      if(sunline.eulerArray.count == 0){
        GlobaltimeSlider.isEnabled = false
      }else{
        GlobaltimeSlider.maximumValue = 86400
      }
    }else{
      GlobaltimeSlider.maximumValue = Float((sunline.sunRiseSetNoonTime[1] / 1000) - GlobaltimeSliderOffset)
    }
    GlobaltimeSlider.value = Float((millis / 1000) - GlobaltimeSliderOffset)
  }
}

public func setUnits(row: Int){
  GlobalBlockedIshours = (row == 0)
  UserDefaults.standard.set(row, forKey: "units")
  GlobalupdateUnits = true
}

public func updateAddressFromLocation(location: CLLocation){
  dBug("updateAddressFromLocation()")
  var placemark: CLPlacemark!
  CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
    if(error == nil && (placemarks?.count)! > 0){
      placemark = placemarks![0] as CLPlacemark
      if(placemark.locality != nil){
        
        Globalcountrycode = placemark.isoCountryCode ?? ""
        Globalcountry = placemark.country ?? ""
        Globalcity = placemark.locality ?? ""
        Globalpostalcode = placemark.postalCode ?? ""
        Globalstreet = placemark.thoroughfare ?? ""
        Globalstreetnumber = placemark.subThoroughfare ?? ""
        
        if(Globalcountrycode != "" && Globalcity != "" && Globalstreet != ""){
          GlobalshortAddress = Globalstreet + ", " + Globalcity + ", " + Globalcountrycode
        }
        
        var builder = "";
        
        if(Globalstreet != ""){
          builder = Globalstreet
          if(Globalstreetnumber != ""){
            builder = Globalstreetnumber + " " + builder
          }
        }
        
        builder = builder + ","
        
        if(Globalpostalcode != ""){
          builder = builder + " " + Globalpostalcode
        }
        
        builder = builder + " " + Globalcity
        
        if(Globalcountry != ""){
          builder = builder + ", " + Globalcountry
        }
        
        GlobalwholeAddress = builder
        print(GlobalwholeAddress)
        
      }
    }
  })
}

public func lString(_ keyword: String) -> String {
  return (Gb?.localizedString(forKey: keyword, value: nil, table: nil))!
}


let GlobalDbugFile = "dBugfile.txt"
var GlobalDebug = false
var GlobalDebugLoopCount = 20
public func dBug(_ text: String) {
  if(GlobalDebug && GlobalDebugLoopCount > 0){
    
    OperationQueue.main.addOperation {
      do {
          let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
          let url = dir.appendingPathComponent(GlobalDbugFile)
          try "\(text)".appendLineToURL(fileURL: url as URL)
          //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
      }
      catch {
          print("Could not write to file")
      }
    }

  }
}

extension String {
   func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
