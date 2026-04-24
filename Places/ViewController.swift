

import UIKit

import CoreLocation
import MapKit
import SpriteKit

class ViewController: UIViewController {
  
  fileprivate var locationManager:CLLocationManager!

  var arViewController: ARViewController!
  var startedLoadingPOIs = false
  var startAR = true
  var locationUpdates = 0
  
  var recuringLocationUpdateTimer = Timer()
  
  public func sharedBugFile(){
    if(GlobalDebug){
      if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(GlobalDbugFile)
        //reading
        do {
            let text2 = try String(contentsOf: fileURL, encoding: .utf8)
            GlobalDebug = false
            // set up activity view controller
            let textToShare = [ text2 ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = []

            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
        catch {/* error handling here */}
        do{
          print("Try delete file")
          try FileManager.default.removeItem(at: fileURL)
          print("Success")
        }catch {
          print("Some error")
        }
        
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sharedBugFile()
    dBug("Start")
    Globalwidth = Int(self.view.bounds.width)
    Globalheight = Int(self.view.bounds.height)
    Globalscale = Float(sqrt(pow(Double(Globalwidth), 2) + pow(Double(Globalheight), 2)) / sqrt(pow(414, 2) + pow(736, 2)))
    finilizeGlobals()
    dBug("Finilized Globals")
    UIApplication.shared.isIdleTimerDisabled = true
    OperationQueue.main.addOperation{
    self.locationManager = CLLocationManager()
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    dBug("Now waiting for location")
    }
    scheduledLocationTimer()
  }
  
  func scheduledLocationTimer(){
    recuringLocationUpdateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateLocationTimer), userInfo: nil, repeats: true)
  }
  
  @objc func updateLocationTimer(){
    self.locationManager.startUpdatingLocation()
  }
  
  func updateLocation(location: CLLocation){
    if(self.startAR){
      self.startAR = false
      updateLocationForMath(location: location)
      let millis = currentMillis()
      updatePositionYearMath(millis)
      setSunPos(millis: millis)
      updateSunTimeLabel(label1Millis: millis)
      
      updateDayLine()
      updateSummerAndWinterLine()
      dBug("Sun Pos \(radiansToDegrees(Double(getSunPos().zenith()))),\(radiansToDegrees(Double(getSunPos().alt()))),\(radiansToDegrees(Double(getSunPos().az())))")
      let sunPos3D = polarTo3D(polar: getSunPos())
      dBug("Sun Pos 3D \(sunPos3D.x()), \(sunPos3D.y()), \(sunPos3D.z())")
      
      if #available(iOS 11.0, *) {
       
        Globalnotchsize = max(0,Int((UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)) - 0)
        if(Globalnotchsize < 25){
          Globalnotchsize = 0
        }
        GlobalbuttonOffsetLeft = max(GlobalbuttonOffsetLeft,Globalnotchsize)
        GlobalbuttonOffsetBottom = max(GlobalbuttonOffsetBottom,Int((UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)))
        
      }
      
      DispatchQueue.main.async {
        dBug("STARTING AR VIEW")
        self.startARView()
      }
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func startARView(){
  
    arViewController = ARViewController()

  //  locationManager.stopUpdatingLocation()
    arViewController.modalPresentationStyle = .fullScreen
    self.present(arViewController, animated: false, completion: nil)
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return false
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    dBug("Did Change Authorization")
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .denied:
        let ac = UIAlertController(title: (Gb?.localizedString(forKey: "locationDenied_title", value: nil, table: nil))!, message: (Gb?.localizedString(forKey: "locationDenied", value: nil, table: nil))!, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "ok", value: nil, table: nil), style: .default))
        present(ac, animated: true)
        
      case .notDetermined, .restricted:
        dBug("No location access")
      case .authorizedAlways, .authorizedWhenInUse:
        dBug("Start Updating Location")
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
      }
    } else {
      dBug("Location services are not enabled")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    dBug("Did Update Location")
    if (locations.count > 0){
      print(locations)
      let location = locations.last!
      updatePositionYearMath(currentMillis())
      if(location.coordinate.latitude < Double(radToDeg(Float(D)))){
        Globalmultiplier = -1
        Globalsunlineadder = 1000 * 60 * 60 * 24
      }
      updateAddressFromLocation(location: location)
      dBug("Updating Location as last location")
      if(GlobalArView){
        self.updateLocation(location: location)
      }else{
        ARlatitude = location.coordinate.latitude
        ARlongtitude = location.coordinate.longitude
      }
      
      locationUpdates += 1
      if(locationUpdates >= 4){
        manager.stopUpdatingLocation()
      }
    }
  }
}
