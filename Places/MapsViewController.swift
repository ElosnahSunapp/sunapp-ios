//
//  MapsViewController.swift
//  SunApp
//
//  Created by Phillip Løjmand on 24/08/2019.
//  Copyright © 2019 casafox. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import TimeZoneLocate
import Firebase

extension MKLocalSearchCompletion{
  @objc func getMainText() -> String{
    return title
  }
  
  @objc func getSubText() -> String{
    return subtitle
  }
  
  @objc func gotoCurrent() -> Bool{
    return false
  }
}

class CustomSearchCompletion: MKLocalSearchCompletion{
  var alternativeText = ""
  
  override func getMainText() -> String{
    return alternativeText
  }
 
  override func getSubText() -> String{
    return ""
  }
  
  override func gotoCurrent() -> Bool {
    return true
  }
  
  func setAlt(alternativeText: String){
    self.alternativeText = alternativeText
  }
}

class MapView: UIView, MKMapViewDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {

  let mapView = MKMapView()
  var overlayLocation:CLLocationCoordinate2D!
  var lastOverlayReCalc:CLLocationCoordinate2D!
  public var sunMapOverlay:MapOverlayView!
  var searchController: UISearchController!
  private var myTableView: UITableView!
  var matchingItems:[MKLocalSearchCompletion] = []
  var completer: MKLocalSearchCompleter!
  var lastRadius:Double = -1
  var lastUserLocation: MKUserLocation!
  var sliderOffset = 42
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let leftMargin:CGFloat = 0
    let topMargin:CGFloat = 0
    let mapWidth:CGFloat = frame.size.width
    let mapHeight:CGFloat = frame.size.height
    
    mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
    
    mapView.mapType = MKMapType.satellite
    GlobalMapType = 1
    if(GlobalhasPremium){
      GlobaltrackingOverlayMode = 1
      GlobaloverlayTrackingModeButtonCurImg = GlobalmapFollowImage
    }
    updateMapButton()
    mapView.isZoomEnabled = true
    mapView.isRotateEnabled = true
    mapView.isScrollEnabled = true
    mapView.showsUserLocation = false
    //mapView.showsScale = true
    mapView.showsBuildings = true
    //mapView.isRotateEnabled = true
    mapView.isPitchEnabled = false
    mapView.showsPointsOfInterest = false
    updateCompass()
    

    self.addSubview(mapView)
    
    //Add overlay
    sunMapOverlay = MapOverlayView(frame: mapView.frame)
    sunMapOverlay.center = self.center
    self.addSubview(sunMapOverlay)
    self.bringSubviewToFront(self.sunMapOverlay)
    sunMapOverlay.setNeedsDisplay()
    
    
    
    //Zoom to user location
    overlayLocation = CLLocationCoordinate2DMake(latitude, longtitude)
    let viewRegion = MKCoordinateRegion(center: overlayLocation, latitudinalMeters: 150, longitudinalMeters: 150)
    
    mapView.setRegion(viewRegion, animated: false)
    mapView.delegate = self
    
    searchController = UISearchController(searchResultsController: nil)
    
    // The object responsible for updating the contents of the search results controller.
    searchController.searchResultsUpdater = self
    searchController?.hidesNavigationBarDuringPresentation = false
    searchController?.dimsBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = lString("search_for")
    searchController.searchBar.sizeToFit()
    
    let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    let displayWidth: CGFloat = self.frame.width
    let displayHeight: CGFloat = self.frame.height
    
    
    myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight))
    myTableView.dataSource = self
    myTableView.delegate = self
    myTableView.tableHeaderView = searchController.searchBar
    myTableView.tableFooterView = UIView()
    
    //definesPresentationContext = true
    myTableView.isHidden = true
    sunMapOverlay.isHidden = false
    mapView.addSubview(myTableView)
    
    self.completer = MKLocalSearchCompleter.init()
    self.completer.filterType = MKLocalSearchCompleter.FilterType.locationsOnly
    self.completer.delegate = self
    fitTableView()
    
    //Slider
    var sliderHeight = 32
    var sliderWidth = Int(self.frame.width / 2)
    var frame:CGRect!
    if(UIDevice.current.userInterfaceIdiom == .phone){
      sliderHeight = 26
      sliderWidth = Int(self.frame.width - 40)
      frame = CGRect(x: 20, y: Globalheight - GlobalbuttonHeight - GlobalbuttonOffsetBottom - sliderOffset, width: sliderWidth, height: sliderHeight)
    }else{
      frame = CGRect(x: 20, y: GlobalToolbarHeight + sliderOffset, width: sliderWidth, height: sliderHeight)
    }
    GlobaltimeSlider = UISlider(frame: frame)
    GlobaltimeSlider.minimumTrackTintColor = UIColor.lightGray
    GlobaltimeSlider.maximumTrackTintColor = UIColor.lightGray
    GlobaltimeSlider.minimumValueImage = resizeImage(image: UIImage(named: "ic_sunrise.png")!, newWidth: CGFloat(sliderHeight))
    GlobaltimeSlider.maximumValueImage = resizeImage(image: UIImage(named: "ic_sunset.png")!, newWidth: CGFloat(sliderHeight))
    GlobaltimeSlider.addTarget(self, action: #selector(globalTimeSliderChanged), for: .valueChanged)
    self.addSubview(GlobaltimeSlider)
    updateOverlay()
    sunMapOverlay.renderPaths()
  }
  
  @objc func globalTimeSliderChanged(sender:UISlider!){
    updateTime((Int(sender!.value) + GlobaltimeSliderOffset) * 1000)
    updateOverlay()
  }
  
  func nextOverlayTrackingMode(){
    GlobaltrackingOverlayMode = (GlobaltrackingOverlayMode + 1) % 3
    //Skip here
    if(GlobaltrackingOverlayMode == 0){
      GlobaltrackingOverlayMode = 1
    }
    switch GlobaltrackingOverlayMode {
    case 0:
      GlobaloverlayTrackingModeButtonCurImg = GlobalcurrentLocationImage
      if(self.lastUserLocation != nil){
        setOverlayLocation(location: self.lastUserLocation.location!)
        recalcSunPath(location: self.lastUserLocation.location!)
        updateOverlay()
      }
      break
    case 1:
      GlobaloverlayTrackingModeButtonCurImg = GlobalmapFollowImage
      setOverlayLocation(location: CLLocation(latitude: self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude))
      recalcSunPath(location: CLLocation(latitude: self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude))
      updateOverlay()
      break
    case 2:
      GlobaloverlayTrackingModeButtonCurImg = GlobalmarkerImage
      break
    default:
      GlobaloverlayTrackingModeButtonCurImg = GlobalcurrentLocationImage
    }
  }
  
  func updateSunlineCol(){
    switch GlobalMapType {
    case 0:
      sunline.setColor(color: UIColor.init(red: 249.0 / 255.0, green: 215.0 / 255.0, blue: 28.0 / 255.0, alpha: 1))
      break
    case 1:
      sunline.setColor(color: UIColor.yellow)
      break
    default:
      self.mapView.mapType = .standard
    }
  }
  
  func nextMapType(){
    GlobalMapType = (GlobalMapType + 1) % 2
    switch GlobalMapType {
    case 0:
      self.mapView.mapType = .standard
      break
    case 1:
      self.mapView.mapType = .satellite
      sunline.setColor(color: UIColor.yellow)
      break
    default:
      self.mapView.mapType = .standard
    }
    updateOverlay()
    sunMapOverlay.renderPaths()
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func fitTableView(){
    var frame = self.myTableView.frame
    
    if(matchingItems.count > 0){
      frame.size.height = self.frame.height
    }else{
      frame.size.height = (self.myTableView.tableFooterView?.frame.minY)!
    }
    self.myTableView.frame = frame
  }
  
  func updateCompass(){
    mapView.showsCompass = false
    if let oldCompassBtn = mapView.viewWithTag(100) {
      oldCompassBtn.removeFromSuperview()
    }
    if #available(iOS 11.0, *) {
      let compassBtn = MKCompassButton(mapView:mapView)
      compassBtn.tag = 101
      if(Globalorientation == Orientation.PORTRAIT){
        compassBtn.frame.origin = CGPoint(x: self.frame.maxX - 40, y: CGFloat(GlobalToolbarHeight + sliderOffset))
      }else{
        compassBtn.frame.origin = CGPoint(x: self.frame.maxX - 130, y:  self.frame.maxY - CGFloat(sliderOffset))
      }
      compassBtn.tag = 100
      compassBtn.compassVisibility = .visible
      mapView.addSubview(compassBtn)
    }
  }
  
  func setOverlayLocation(location: CLLocation){
    self.overlayLocation = location.coordinate
  }
  
  func recalcSunPath(location: CLLocation){
    if(lastOverlayReCalc == nil || getDistanceBetweenPoints(location.coordinate, lastOverlayReCalc) > 10000){
      self.lastOverlayReCalc = self.overlayLocation
      GlobalMapTimeZone = location.timeZone
      Globaltoolbar?.updateLanguageChange()
      updateAddressFromLocation(location: location)
      location.timeZone { (tz) -> (Void) in
        guard let tz = tz else { return }
        // got a more accurate timezone from the network
        GlobalMapTimeZone = tz
        Globaltoolbar?.updateLanguageChange()
        print("Network TimeZone: \(tz.identifier)")
        updateLocationForMath(location: location)
        setSunPos(millis: usingMillis())
        updatePositionYearMath(usingMillis())
        updateDayLine()
        updateSummerAndWinterLine()
        self.limitToDayTime(usingMillis())
        //updateLocationForMath(location: realLocation)
        self.updateSunlineCol()
        self.sunMapOverlay.renderPaths()
      }
      updateLocationForMath(location: location)
      setSunPos(millis: usingMillis())
      updatePositionYearMath(usingMillis())
      updateDayLine()
      updateSummerAndWinterLine()
      limitToDayTime(usingMillis())
      //updateLocationForMath(location: realLocation)
      updateSunlineCol()
      sunMapOverlay.renderPaths()
    }
  }
  
  func updateOverlay(){
    if(GlobalhasPremium){
      GlobaltimeSlider?.isHidden = false
    }else{
      GlobaltimeSlider?.isHidden = true
    }
    updateSunlineCol()
    if(overlayLocation == nil){
      return
    }
    
    let originMap = overlayLocation!
    let towardsNorthMap = CLLocationCoordinate2D(latitude: originMap.latitude + 0.01, longitude: originMap.longitude)
    let origin = self.mapView.convert(originMap, toPointTo: sunMapOverlay)
    let towardsNorth = self.mapView.convert(towardsNorthMap, toPointTo: sunMapOverlay)
    let heading = atan2(towardsNorth.y - origin.y, towardsNorth.x - origin.x)
    self.sunMapOverlay?.setOrigin(point: origin)
    self.sunMapOverlay?.setRotation(rotation: heading)
    self.sunMapOverlay?.setNeedsDisplay()
  }
  
  func updateScreenOrientation(){
    updateCompass()
    if(Globalorientation == Orientation.LANDSCAPE){
      var transform = CGAffineTransform.identity.rotated(by: CGFloat(Float.pi / 2))
      transform = transform.concatenating(CGAffineTransform(translationX: self.frame.width - GlobaltimeSlider.center.x - CGFloat(GlobalToolbarHeight + sliderOffset + 16), y: GlobaltimeSlider.frame.width / 2 - CGFloat(GlobalToolbarHeight - sliderOffset)))
      GlobaltimeSlider.transform = transform
    }else{
      GlobaltimeSlider.transform = CGAffineTransform.identity
    }

    /*if(Globalorientation == Orientation.LANDSCAPE){
      self.frame = CGRect(x: 0, y: 0, width: frame.size.height, height: frame.size.width)
      self.mapView.frame = self.frame
      self.transform = CGAffineTransform.identity.rotated(by: CGFloat(Float.pi / 2))
      //transform = transform.translatedBy(x: frame.size.height / 8, y: frame.size.height / 8)
    }else{
      self.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
      self.mapView.frame = self.frame
      self.transform = CGAffineTransform.identity
    }*/
  }
  
  func search(){
    myTableView.isHidden = false
    if #available(iOS 11.0, *) {
      let compassBtn = mapView.viewWithTag(101) as? MKCompassButton
      compassBtn?.compassVisibility = .hidden
    }
    sunMapOverlay.isHidden = true
    self.searchController.isActive = true
    matchingItems.removeAll()
    let here = CustomSearchCompletion()
    here.setAlt(alternativeText: lString("search_here"))
    matchingItems.append(here)
    myTableView.reloadData()
    fitTableView()
    GlobalMapSearchActive = true
    Globaltoolbar?.isHidden = true
    GlobaltimeSlider?.isHidden = true
    updateAllButtons()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if(matchingItems[indexPath.row].gotoCurrent()){
      let myLocation = CLLocationCoordinate2D(latitude: ARlatitude, longitude: ARlongtitude)
      let viewRegion = MKCoordinateRegion(center: myLocation, latitudinalMeters: 150, longitudinalMeters: 150)
      self.mapView.setRegion(viewRegion, animated: true)
      self.searchController.isActive = false
      return
    }
    let request = MKLocalSearch.Request(completion: matchingItems[indexPath.row])
    let search = MKLocalSearch(request: request)
    search.start { (response: MKLocalSearch.Response?, error: Error?) in
      if let _ = error {
        self.searchController.isActive = false
      }
      else if let mapItems = response?.mapItems {
        if(mapItems.count == 1){
          self.searchController.isActive = false
          let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(mapItems[0].placemark.location!.coordinate.latitude, mapItems[0].placemark.location!.coordinate.longitude), latitudinalMeters: 150, longitudinalMeters: 150)
          self.mapView.setRegion(viewRegion, animated: true)
          
          if(GlobaltrackingOverlayMode == 0){
            self.nextOverlayTrackingMode()
            updateOverlayTrackingModeButton()
          }
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = "MyCell"
    var cell:UITableViewCell? =
      myTableView?.dequeueReusableCell(withIdentifier: reuseIdentifier)
    if (cell == nil)
    {
      cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                             reuseIdentifier: reuseIdentifier)
    }
    
    let selectedItem = matchingItems[indexPath.row]
    cell!.textLabel?.text = selectedItem.getMainText()
    cell!.detailTextLabel?.text = selectedItem.getSubText()
    return cell!
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    GlobalMapSearchActive = false
    updateAllButtons()
    //No need to update anything if we're being dismissed.
    if !searchController.isActive {
      self.matchingItems = []
      self.myTableView.reloadData()
      fitTableView()
      myTableView.isHidden = true
      sunMapOverlay.isHidden = false
      Globaltoolbar?.isHidden = false
      GlobaltimeSlider.isHidden = false
      if #available(iOS 11.0, *) {
        let compassBtn = mapView.viewWithTag(101) as? MKCompassButton
        compassBtn?.compassVisibility = .visible
      }
      return
    }
    
    let searchBarText = searchController.searchBar.text
    completer.region = mapView.region
    completer.queryFragment = searchBarText!
  }
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter){
    self.matchingItems = completer.results
    self.myTableView.reloadData()
    fitTableView()
  }
  
  /*func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
    if overlay is SunOverlay
    {
      if(self.sunOverlayRender == nil){
        self.sunOverlayRender = SunOverlayRender(overlay: overlay, radius: CGFloat(getVisibleRadius()))
      }
      self.sunOverlayRender.updateRadius(radius: CGFloat(getVisibleRadius()))
      self.sunOverlayRender.updatePosition(pos: self.mapView.region.center)
      return self.sunOverlayRender
    }
    
    
    return MKPolylineRenderer()
  }*/
  
  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if (newWindow == nil) {
      
    } else {
    Analytics.logEvent(AnalyticsEventScreenView,
    parameters: [AnalyticsParameterScreenName: "Maps View",
                 AnalyticsParameterScreenClass: "MapsViewController"])
    }
  }
  
  var updateCounter = 0
  func mapViewDidChangeVisibleRegion(_ mapView: MKMapView){
    if(updateCounter == 0){
      DispatchQueue.main.async {
        if(GlobaltrackingOverlayMode == 1){
          self.setOverlayLocation(location: CLLocation(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude))
        }
        self.updateOverlay()
        self.updateCounter = 1
      }
    }
    updateCounter = updateCounter - 1;
  }
  
  func mapView(_ mapView: MKMapView,regionDidChangeAnimated animated: Bool){
    if(GlobaltrackingOverlayMode == 1){
      self.setOverlayLocation(location: CLLocation(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude))
      recalcSunPath(location: CLLocation(latitude: self.overlayLocation.latitude, longitude: self.overlayLocation.longitude))
      updateOverlay()
    }
  }
  
  func mapView(_ mapView: MKMapView,didUpdate userLocation: MKUserLocation){
    self.lastUserLocation = userLocation
    if(GlobaltrackingOverlayMode == 0){
      setOverlayLocation(location: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
      updateOverlay()
    }
  }
  
  func getDistanceBetweenPoints(_ point1: CLLocationCoordinate2D,_ point2: CLLocationCoordinate2D) -> Double {
  
  let earthRadius: Double = 6371.0;
  
  let dLat = degToRadD(Double(point2.latitude - point1.latitude))
  let dLng = degToRadD(Double(point2.longitude - point1.longitude))

  let a = sin( dLat / 2 ) * sin( dLat / 2 ) +
  cos(degToRadD(Double(point1.latitude))) * cos(degToRadD(Double(point2.latitude))) *
  sin( dLng / 2 ) * sin( dLng / 2 );
  let c:Double = 2 * atan2(sqrt(a), sqrt( 1 - a ));
  
  return abs(( earthRadius * c ) * 350);
  }
  
  func getVisibleRadius() -> Double{
    let cent = mapView.region.center
    let latEdge = CLLocationCoordinate2D(latitude: cent.latitude + mapView.region.span.latitudeDelta, longitude: cent.longitude)
    let lngEdge = CLLocationCoordinate2D(latitude: cent.latitude, longitude: cent.longitude + mapView.region.span.longitudeDelta)
    return min(getDistanceBetweenPoints(cent,latEdge),getDistanceBetweenPoints(cent, lngEdge))
  }
  
  func limitToDayTime(_ millis: Int){
    if(GlobalCurrentView == 1){
      //Make sure time stays within daytime for map view
      var newmillis = millis
      if(millis < sunline.sunRiseSetNoonTime[0]){
        newmillis = sunline.sunRiseSetNoonTime[0]
      }
      if(millis > sunline.sunRiseSetNoonTime[1]){
        newmillis = sunline.sunRiseSetNoonTime[1]
      }
      if(millis != newmillis){
        updateTime(newmillis)
        updateDayLine()
      }
      self.sunMapOverlay.setNeedsDisplay()
    }
  }
  
}

class MapOverlayView : UIView {
  
  var origin:CGPoint!
  var rotation:CGFloat = 0
  private let sunImage = UIImage(named: "sunSprite.png")
  
  var ringRadius:CGFloat!
  var middleDot:UIBezierPath!
  var outerring:UIBezierPath!
  var sunPath:UIBezierPath!
  var winterPath:UIBezierPath!
  var summerPath:UIBezierPath!
  var winterPathHelper:UIBezierPath?
  var summerPathHelper:UIBezierPath?
  var sunPathHelper:UIBezierPath?
  
  var markerArray:[TimeMarker] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor(white: 1, alpha: 0)
    self.isUserInteractionEnabled = false //Don't steal interaction from map
    ringRadius = min(CGFloat(self.frame.width / 9 * 3),CGFloat(self.frame.height / 9 * 3))
    mapViewStringattributes[NSAttributedString.Key.font] = UIFont(name: "SofiaPro-Bold", size: CGFloat(ringRadius / 240 * 20))!
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func setOrigin(point: CGPoint){
    self.origin = point
  }
  
  func setRotation(rotation: CGFloat){
    self.rotation = rotation
  }
  
  func createOuterRingPath(radius: CGFloat) -> UIBezierPath {
  return UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
  }
  
  func createSunPathSimple(radius: CGFloat) -> UIBezierPath {
    let sunriseAngle = sunline.eulerArray[0].az()
    let sunsetAngle = sunline.eulerArray[sunline.eulerArray.count - 1].az()
    return UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: radius, startAngle: CGFloat(sunriseAngle), endAngle: CGFloat(sunsetAngle), clockwise: true)
  }
  
  func polarRadiusToPoint(_ polar: Polar, _ radius: CGFloat) -> CGPoint{
    return CGPoint(x: CGFloat(cos(polar.az()) * sin(polar.zenith())) * radius, y: CGFloat(sin(polar.az()) * sin(polar.zenith())) * radius)
  }
  
  func pointsToDir(_ p1: CGPoint,_ p2: CGPoint) -> Float{
    let v1 = Vector(Float(p1.x),Float(p1.y))
    let v2 = Vector(Float(p2.x),Float(p2.y))
    return v1.angleTo(to: v2)
  }
  
  func createSunriseSunsetHelperLine(radius: CGFloat, sunline: Sunline) -> UIBezierPath?{
    if(!sunline.sunriseExist){
      return nil
    }
    
    if(sunline.eulerArray.count < 2){
      return nil
    }
    let center = CGPoint(x: 0, y: 0)
    let sunrise = polarRadiusToPoint(sunline.eulerArray[0],radius)
    let sunset = polarRadiusToPoint(sunline.eulerArray[sunline.eulerArray.count - 1],radius)
    let path = UIBezierPath()
    path.move(to: center)
    path.addLine(to: sunrise)
    path.move(to: center)
    path.addLine(to: sunset)
    return path
  }
  
  func createSunPath(radius: CGFloat, sunline: Sunline, timemark: Bool, hormark: Bool) -> UIBezierPath? {
    let scale:Float = Float(ringRadius / 220)
    if(sunline.eulerArray.count < 2){
      return nil
    }
    let center = CGPoint(x: 0, y: 0)
    let path = UIBezierPath()
    let start = polarRadiusToPoint(sunline.eulerArray[0],radius)
    let end = polarRadiusToPoint(sunline.eulerArray[sunline.eulerArray.count - 1],radius)
    path.move(to: start)
    let markerLineLen:Float = 10
    var dir:Float = 0
    var p = start
    var lastP:CGPoint!
    for i in 1 ... sunline.eulerArray.count - 1{
      let wholeHour = sunline.eulerArray[i].payload % 3600000 == 0
      if(i % 5 == 0 || i == sunline.eulerArray.count - 1 || wholeHour){
        lastP = p
        p = polarRadiusToPoint(sunline.eulerArray[i],radius)
        path.addLine(to: p)
        
        //Draw sunline label here, if there's no horizon to attach it to
        if(!sunline.sunriseExist && i == 15){
          if(sunline.id == summerline.id){
            markerArray.append(TimeMarker(text: GlobalsolsticeLabel, point: p, rot: CGFloat(pointsToDir(lastP,p)), col: sunline.getColor()))
          }else if(sunline.id == winterline.id){
              markerArray.append(TimeMarker(text: GlobalsolticeLabel, point: p, rot: CGFloat(pointsToDir(lastP,p)), col: sunline.getColor()))
          }
        }
      }
      if(timemark && wholeHour && (i >= 10 && i < sunline.eulerArray.count - 11 || !sunline.sunriseExist)){
        dir = pointsToDir(lastP,p) - Float.pi / 2
        let t = CGPoint(x: p.x + CGFloat(cos(dir) * markerLineLen), y: p.y + CGFloat(sin(dir) * markerLineLen))
        path.addLine(to: t)
        markerArray.append(TimeMarker(text: sunline.eulerArray[i].payloadString, point: t, rot: CGFloat(dir + Float.pi / 2), col: sunline.getColor()))
        path.move(to: p)
      }
    }
    if(sunline.sunriseExist && hormark){
      //Sunrise
      path.move(to: start)
      dir = pointsToDir(center,start)
      var t = CGPoint(x: start.x + CGFloat(cos(dir) * markerLineLen),y: start.y + CGFloat(sin(dir) * markerLineLen))
      path.addLine(to: t)
      
      markerArray.append(TimeMarker(text: getTimeString(sunline.sunRiseSetNoonTime[southernMode() ? 1 : 0]), point: t, rot: CGFloat(dir + Float.pi / 2), col: sunline.getColor()))
      
      let dateMarkerLen = markerLineLen + markerLineLen * 2 * scale
      if(sunline.id == summerline.id){
        t = CGPoint(x: start.x + CGFloat(cos(dir) * dateMarkerLen),y: start.y + CGFloat(sin(dir) * dateMarkerLen))
        markerArray.append(TimeMarker(text: GlobalsolsticeLabel, point: t, rot: CGFloat(dir + Float.pi / 2), col: sunline.getColor()))
      }else if(sunline.id == winterline.id){
        t = CGPoint(x: start.x + CGFloat(cos(dir) * dateMarkerLen),y: start.y + CGFloat(sin(dir) * dateMarkerLen))
         markerArray.append(TimeMarker(text: GlobalsolticeLabel, point: t, rot: CGFloat(dir + Float.pi / 2), col: sunline.getColor()))
      }
      
      
      //Sunset
      dir = pointsToDir(center,end)
      path.move(to: end)
      t = CGPoint(x: end.x + CGFloat(cos(dir) * markerLineLen),y: end.y + CGFloat(sin(dir) * markerLineLen))
      path.addLine(to: t)
      markerArray.append(TimeMarker(text: getTimeString(sunline.sunRiseSetNoonTime[southernMode() ? 0 : 1]), point: t, rot: CGFloat(dir + Float.pi / 2), col: sunline.getColor()))
    }
    return path
  }
  
  func renderPaths(){
    
    markerArray.removeAll()
    
    
    middleDot = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 6, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
    outerring = createOuterRingPath(radius: ringRadius)
    sunPath = createSunPath(radius: ringRadius, sunline: sunline, timemark: true, hormark: true)
    if(abs(sunline.getStartMillis() - winterline.getStartMillis()) / 86400000 > 25){
      winterPath = createSunPath(radius: ringRadius, sunline: winterline, timemark: false, hormark: true)
    }else{
      winterPath = createSunPath(radius: ringRadius, sunline: winterline, timemark: false, hormark: false)
    }
    if(abs(sunline.getStartMillis() - summerline.getStartMillis()) / 86400000 > 25){
      summerPath = createSunPath(radius: ringRadius, sunline: summerline, timemark: false, hormark: true)
    }else{
      summerPath = createSunPath(radius: ringRadius, sunline: summerline, timemark: false, hormark: false)
    }
    
    winterPathHelper = createSunriseSunsetHelperLine(radius: ringRadius, sunline: winterline)
    summerPathHelper = createSunriseSunsetHelperLine(radius: ringRadius, sunline: summerline)
    sunPathHelper = createSunriseSunsetHelperLine(radius: ringRadius, sunline: sunline)
    
  }
  
  override func draw(_ rect: CGRect){
    if(origin == nil){
      //We must have a place to draw
      return
    }
    
    let scale:Float = Float(ringRadius / 220)
    
    //Always sync drawing
    OperationQueue.main.addOperation {
      Globaltoolbar?.updateLabel1FromMillis(usingMillis())
      updateGlobalTimeSlider(usingMillis())
    }
    
    //Place on map by transform
    var transform = CGAffineTransform(rotationAngle: rotation)
    transform = transform.concatenating(CGAffineTransform(translationX: origin.x, y: origin.y))
    outerring.apply(transform)
    middleDot.apply(transform)
    sunPath?.apply(transform)
    winterPath?.apply(transform)
    summerPath?.apply(transform)
    winterPathHelper?.apply(transform)
    summerPathHelper?.apply(transform)
    sunPathHelper?.apply(transform)
    
    var fillColor = UIColor.black
    
    //Draw outerline
    var strokeColor = UIColor.black
    strokeColor.setStroke()
    outerring.lineWidth = 1.0
    outerring.stroke()
    
    //Draw middle dot
    if(GlobaltrackingOverlayMode != 0){
      fillColor = UIColor.black
      fillColor.setFill()
      middleDot.fill()
    }
    
    //Draw sunline
    //Summer/winter
    strokeColor = winterline.getColor()
    strokeColor.setStroke()
    winterPathHelper?.lineWidth = 1.0
    winterPathHelper?.stroke()
    winterPath?.lineWidth = 3.0
    winterPath?.stroke()
    
    strokeColor = summerline.getColor()
    strokeColor.setStroke()
    summerPathHelper?.lineWidth = 1.0
    summerPathHelper?.stroke()
    summerPath?.lineWidth = 3.0
    summerPath?.stroke()
    
    //Today
    strokeColor = sunline.getColor()
    strokeColor.setStroke()
    sunPathHelper?.lineWidth = 1.0
    sunPathHelper?.stroke()
    sunPath?.lineWidth = 3.0
    sunPath?.stroke()
   
    
    //Draw sun
    let polarSun = getSunPos()
    if(polarSun.alt() > -0.02){
      var sunPos = polarRadiusToPoint(polarSun,ringRadius)
      sunPos = sunPos.applying(transform)
      let sunSize:CGFloat = CGFloat((36 + 36 * cos(polarSun.zenith())) * scale)
      sunImage?.draw(in: CGRect(x: sunPos.x - sunSize / 2, y: sunPos.y - sunSize / 2, width: sunSize, height: sunSize))
    }
    
    //Draw labels
    let context = UIGraphicsGetCurrentContext()!
    for marker in markerArray{
      marker.drawTransformed(context: context, transform: transform, fontScaleOffset: scale)
    }
    
    //Invert transforms
    let transInvert = transform.inverted()
    outerring.apply(transInvert)
    middleDot.apply(transInvert)
    sunPath?.apply(transInvert)
    winterPath?.apply(transInvert)
    summerPath?.apply(transInvert)
    winterPathHelper?.apply(transInvert)
    summerPathHelper?.apply(transInvert)
    sunPathHelper?.apply(transInvert)
  }
}

class TimeMarker
{
  var text:String!
  var point:CGPoint!
  var rot:CGFloat
  var col:UIColor!
  
  init(text: String, point: CGPoint, rot: CGFloat, col:UIColor) {
    self.text = text
    self.point = point
    self.rot = rot
    self.col = col
  }
  
  func drawTransformed(context: CGContext, transform: CGAffineTransform, fontScaleOffset: Float){
    mapViewStringattributes?[NSAttributedString.Key.foregroundColor] = self.col
    let attributedString = NSAttributedString(string: text, attributes: mapViewStringattributes)
    let stringRect = CGRect(x: -50, y: Int(-25 * fontScaleOffset), width: 100, height: 40)

    
    context.saveGState()
    context.concatenate(CGAffineTransform(rotationAngle: rot).concatenating(CGAffineTransform(translationX: point.x, y: point.y)).concatenating(transform))
    attributedString.draw(in: stringRect)

    context.restoreGState()
  }
}
