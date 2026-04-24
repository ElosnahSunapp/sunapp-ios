//
//  SunMath.swift
//  Places
//
//  Created by Phillip Løjmand on 17/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import CoreLocation

var g: Double = 0
var D: Double = 0
var cosD: Double = 0
var sinD: Double = 0

var TC: Double = 0
var cosg: Double = 0
var sing: Double = 0
var cos2g: Double = 0
var sin2g: Double = 0

var maxZenith: Double = 0
var maxAzimuth: Double = 0

var latitude: Double = 0
var longtitude: Double = 0
var ARlatitude: Double = 0
var ARlongtitude: Double = 0

var sinRadiansLat: Double = 0
var cosRadiansLat: Double = 0


var hoursSinceNewYear: Double = 0
public var newYearMillis: Int = 0

public var GlobalmillisOfLastYearUpdate = 0

public func updateLocationForMath(location: CLLocation){
  latitude = location.coordinate.latitude
  longtitude = location.coordinate.longitude
  print("Location updated: \(latitude),\(longtitude)")
  sinRadiansLat = sin(degreesToRadians(latitude))
  cosRadiansLat = cos(degreesToRadians(latitude))  
}

public func southernMode() -> Bool{
  return latitude < D
}

extension Date {
  var millisecondsSince1970:Int {
    return Int((self.timeIntervalSince1970 * 1000.0).rounded())
  }
  
  init(milliseconds:Int) {
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
  }
}

func getCurrentCalendarTimeZone() -> Calendar{
  var cal = Calendar.current
  if(GlobalCurrentView == 1 && GlobalMapTimeZone != nil){
    cal.timeZone = GlobalMapTimeZone
  }
  return cal
}

func getDateComponentTimeZone() -> DateComponents{
  var dateComp = DateComponents()
  if(GlobalCurrentView == 1 && GlobalMapTimeZone != nil){
    dateComp.timeZone = GlobalMapTimeZone
  }
  return dateComp
}

internal func julianDay(millis: Int64) -> Double{

  var dateComponent = DateComponents()
  
  dateComponent.year = 1900
  dateComponent.month = 1
  dateComponent.day = 0
  // dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
  dateComponent.hour = 0
  dateComponent.minute = 0
  dateComponent.second = 0
  
  let millis1900 = getCurrentCalendarTimeZone().date(from: dateComponent)!.millisecondsSince1970
  
  let diff = Int(millis) - millis1900
  
  return Double(diff) / (24 * 60 * 60 * 1000) + 2415019.5
}


public func updateHoursSinceNewYear(millis: Int){
  if(newYearMillis == 0){
    let date = Date()
    let calendar = getCurrentCalendarTimeZone()
    var dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
    
    // dateComponents.year = 2018
    dateComponent.month = 1
    dateComponent.day = 0
    dateComponent.timeZone = TimeZone(abbreviation: "GMT")
    dateComponent.hour = 0
    dateComponent.minute = 0
    dateComponent.second = 0
    
    // Create date from components
    let userCalendar = getCurrentCalendarTimeZone() // user calendar
    newYearMillis = userCalendar.date(from: dateComponent)!.millisecondsSince1970
  }
  
  hoursSinceNewYear = Double((millis - newYearMillis)) / (1000 * 60 * 60)
}

public func updatePositionYearMath(_ millis: Int)
{
  GlobalmillisOfLastYearUpdate = millis
  
  updateHoursSinceNewYear(millis: millis)
  
  //print("Hours since new year \(hoursSinceNewYear)")
  
  g = Double.pi * 2 / 365.25 * (hoursSinceNewYear / 24)
  cosg = cos(g)
  sing = sin(g)
  cos2g = cos(2*g)
  sin2g = sin(2*g)
  
  let jDay = julianDay(millis: Int64(millis))
  
  //print("JDay \(jDay)")
  
  let jCentury = (jDay - 2451545) / 36525
  //print("JCentury \(jCentury)")
  
  let GMAS = 357.52911 + (jCentury*(35999.05029 - 0.0001537 * jCentury))
  //print("GMAS \(GMAS)")
  
  let SEoC = sin(degreesToRadians(GMAS)) * (1.914602 - jCentury * (0.004817 + 0.000014 * jCentury)) + sin(degreesToRadians(2 * GMAS)) * (0.019993 - 0.000101 * jCentury) + sin(degreesToRadians(3 * GMAS)) * 0.000289
  //print("SEoC \(SEoC)")
  
  
  let GMLS = 280.46646 + (jCentury * (36000.76983 + jCentury * 0.0003032)).truncatingRemainder(dividingBy: 360)
  //print("GMLS \(GMLS)")
  
  let STL = GMLS + SEoC
  //print("STL \(STL)")
  
  let MEO = 23 + (26+((21.448 - jCentury*(46.815 + jCentury * (0.00059 - jCentury*0.001813))))/60)/60
  //print("MEO \(MEO)")
  
  
  let OBCORR = MEO + 0.00256 * cos(degreesToRadians(125.04 - 1934.136 * jCentury))
  //print("OBCORR: \(OBCORR)")
  let SAPP = STL - 0.00569 - 0.00478 * sin(degreesToRadians(125.04 - 1934.136 * jCentury))
  //print("SAPP: \(SAPP)")
  D = asin(sin(degreesToRadians(OBCORR)) * sin(degreesToRadians(SAPP)))
  
  TC = degreesToRadians(0.004297 + 0.107029 * cosg - 1.837877 * sing - 0.837378 * cos2g - 2.340475 * sin2g)

  
  cosD = cos(D)
  sinD = sin(D)
  
  maxZenith = acos(sinRadiansLat * sinD + cosRadiansLat * cosD)
  maxAzimuth = (sinD - sinRadiansLat * cos(maxZenith)) / (cosRadiansLat * sin(maxZenith))
  if(maxAzimuth > 1){
    maxAzimuth = 1
  }
  if(maxAzimuth < -1){
    maxAzimuth = -1
  }
  maxAzimuth = acos(maxAzimuth)

}

public func sunPositionMath(millis: Int) -> Polar{
  var sunPos = [Double]()
  
  updateHoursSinceNewYear(millis: millis)
  
  var SHA = degreesToRadians(((hoursSinceNewYear - floor(hoursSinceNewYear / 24) * 24) - 12) * 15) + degreesToRadians(longtitude) + TC

  if(SHA > Double.pi){
    SHA -= 2 * Double.pi
  }
  
  if(SHA < -Double.pi){
    SHA += 2 * Double.pi
  }
  
  sunPos.append(acos(sinRadiansLat * sinD + cosRadiansLat * cosD * cos(SHA)))
  
  var cosSZA = cos(sunPos[0])
  
  if(cosSZA > 1){
    cosSZA = 1
  }
  if(cosSZA < -1){
    cosSZA = -1
  }
  
  sunPos.append( degreesToRadians(90) - sunPos[0])
  
  sunPos.append(acos((sinD - sinRadiansLat * cosSZA) / (cosRadiansLat * sin(sunPos[0]))))

  if(SHA > 0){
    sunPos[2] = 2 * maxAzimuth - sunPos[2]
  }
  
  sunPos.append(0)
  
  return Polar(array: sunPos)
}



public func sunPositionOwnMath(millis: Int) -> Polar{
  
  let hoursSinceNewYear = Double((millis - newYearMillis)) / (1000 * 60 * 60)
  
  //print("Hours since new year \(hoursSinceNewYear)")
  
  let g = Double.pi * 2 / 365.25 * (hoursSinceNewYear / 24)
  let cosg = cos(g)
  let sing = sin(g)
  let cos2g = cos(2*g)
  let sin2g = sin(2*g)
  
  let jDay = julianDay(millis: Int64(millis))
  
  //print("JDay \(jDay)")
  
  let jCentury = (jDay - 2451545) / 36525
  //print("JCentury \(jCentury)")
  
  let GMAS = 357.52911 + (jCentury*(35999.05029 - 0.0001537 * jCentury))
  //print("GMAS \(GMAS)")
  
  let SEoC = sin(degreesToRadians(GMAS)) * (1.914602 - jCentury * (0.004817 + 0.000014 * jCentury)) + sin(degreesToRadians(2 * GMAS)) * (0.019993 - 0.000101 * jCentury) + sin(degreesToRadians(3 * GMAS)) * 0.000289
  //print("SEoC \(SEoC)")
  
  
  let GMLS = 280.46646 + (jCentury * (36000.76983 + jCentury * 0.0003032)).truncatingRemainder(dividingBy: 360)
  //print("GMLS \(GMLS)")
  
  let STL = GMLS + SEoC
  //print("STL \(STL)")
  
  let MEO = 23 + (26+((21.448 - jCentury*(46.815 + jCentury * (0.00059 - jCentury*0.001813))))/60)/60
  //print("MEO \(MEO)")
  
  
  let OBCORR = MEO + 0.00256 * cos(degreesToRadians(125.04 - 1934.136 * jCentury))
  //print("OBCORR: \(OBCORR)")
  let SAPP = STL - 0.00569 - 0.00478 * sin(degreesToRadians(125.04 - 1934.136 * jCentury))
  //print("SAPP: \(SAPP)")
  let D = asin(sin(degreesToRadians(OBCORR)) * sin(degreesToRadians(SAPP)))
  
  let TC = degreesToRadians(0.004297 + 0.107029 * cosg - 1.837877 * sing - 0.837378 * cos2g - 2.340475 * sin2g)
  
  
  
  let cosD = cos(D)
  let sinD = sin(D)
  
  let maxZenith = acos(sinRadiansLat * sinD + cosRadiansLat * cosD)
  var maxAzimuth = (sinD - sinRadiansLat * cos(maxZenith)) / (cosRadiansLat * sin(maxZenith))
  if(maxAzimuth > 1){
    maxAzimuth = 1
  }
  if(maxAzimuth < -1){
    maxAzimuth = -1
  }
  maxAzimuth = acos(maxAzimuth)
  
  var sunPos = [Double]()
  
  var SHA = degreesToRadians(((hoursSinceNewYear - floor(hoursSinceNewYear / 24) * 24) - 12) * 15) + degreesToRadians(longtitude) + TC
  if(SHA > Double.pi){
    SHA -= 2 * Double.pi
  }
  
  if(SHA < -Double.pi){
    SHA += 2 * Double.pi
  }
  
  sunPos.append(acos(sinRadiansLat * sinD + cosRadiansLat * cosD * cos(SHA)))
  
  var cosSZA = cos(sunPos[0])
  
  if(cosSZA > 1){
    cosSZA = 1
  }
  if(cosSZA < -1){
    cosSZA = -1
  }
  
  sunPos.append( degreesToRadians(90) - sunPos[0])
  
  sunPos.append(acos((sinD - sinRadiansLat * cosSZA) / (cosRadiansLat * sin(sunPos[0]))))
  
  if(SHA > 0){
    sunPos[2] = 2 * maxAzimuth - sunPos[2]
  }
  
  sunPos.append(0)
  
  return Polar(array: sunPos)
}

