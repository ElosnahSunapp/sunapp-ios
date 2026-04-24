//
//  Sunlines.swift
//  Places
//
//  Created by Phillip Løjmand on 24/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

var sunline = Sunline()
var summerline = Sunline()
var winterline = Sunline()
var anydayline = Sunline()
var reverseSunline = Sunline()
var yearline = Sunline()


public func updateDayLine() {
  let r = sunline.onDestroy()
  sunline = getDayOfSun(timeInterval: Globalprecision)
  sunline.update3DVector()
  sunline.setColor(color: UIColor.yellow)
  r?.addChild(sunline.node)
}

var updatingYearline = false
public func updateYearLine() {
  while(updatingYearline){
     usleep(50)
  }
  updatingYearline = true
  let r = yearline.onDestroy()
  yearline = getYearOfSun()
  yearline.makeCleanLine()
  yearline.update3DVector()
  yearline.setColor(color: UIColor.blue)
  r?.addChild(yearline.node)
  updatingYearline = false
}

public func updateDayLine2(){
  let r = reverseSunline.onDestroy()
  reverseSunline = getDayOfSun2(timeInterval: Globalprecision)
  reverseSunline.setLabelPosDist(dist: -5)
  reverseSunline.update3DVector()
  reverseSunline.setColor(color: UIColor.yellow)
  r?.addChild(reverseSunline.node)
}

public func updateLines3DVectors(){
  sunline.update3DVector()
  summerline.update3DVector()
  winterline.update3DVector()
  anydayline.update3DVector()
  reverseSunline.update3DVector()
  yearline.update3DVector()
}

public func updateSummerAndWinterLine() {
  
  let date = Date()
  let calendar = NSCalendar.current
  var dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
  
  // dateComponents.year = 2018
  dateComponent.month = 6
  dateComponent.day = 21
  // dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
  dateComponent.hour = 1
  dateComponent.minute = 0
  dateComponent.second = 0
  
  // Create date from components
  let userCalendar = Calendar.current // user calendar
  
  GlobalsummerDate = userCalendar.date(from: dateComponent)!
  
  let r = summerline.onDestroy()
  summerline = getDayOfSun(date: GlobalsummerDate, timeInterval: Globalprecision)
  summerline.update3DVector()
  summerline.setColor(color: UIColor.orange)
  r?.addChild(summerline.node)
  
  dateComponent.month = 12
  GlobalwinterDate = userCalendar.date(from: dateComponent)!
  winterline.onDestroy()
  winterline = getDayOfSun(date: GlobalwinterDate, timeInterval: Globalprecision)
  winterline.update3DVector()
  winterline.setColor(color: UIColor.red)
  r?.addChild(winterline.node)
}


public func getDayOfSun(timeInterval: Double) -> Sunline {
  return getDayOfSun(date: Date(timeIntervalSince1970: TimeInterval(usingMillis() / 1000)), timeInterval: timeInterval)
}

public func getDayOfSun2(timeInterval: Double) -> Sunline{
  let date1 = Date(timeIntervalSince1970: TimeInterval(usingMillis() / 1000))
  let date2 = Date(timeIntervalSince1970: TimeInterval(GlobalfakeMillis2 / 1000))
  return getDayOfSun(date: date1, date2: date2, timeInterval: timeInterval)
}

public func getDayOfSun(date: Date, timeInterval: Double) -> Sunline {
  return getDayOfSun(date: date, date2: date, timeInterval: timeInterval)
}

public func getYearOfSun() -> Sunline{
  
  let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(timeIntervalSince1970: TimeInterval(usingMillis() / 1000)))
  
  var time = Calendar.current.date(from: component)!.millisecondsSince1970
  let saveTime = time
  updatePositionYearMath(saveTime)
  let dayOfSun = Sunline(saveTime)
  let sunPosition = getSunPosition(millis: saveTime)
  dayOfSun.add(polar: sunPosition)
  var i:Int = 0
  let interval = 1000 * 60 * 60  * 9
  repeat{
    i += interval
    time = saveTime + i * 24
    let sunPosition = safeGetSunPosition(millis: time)
    dayOfSun.add(polar: sunPosition)
  }while(i <= 1000 * 60 * 60 * 365)
 return dayOfSun
}

public func getDayOfSun(date: Date, date2: Date, timeInterval: Double) -> Sunline {
  var horalt:Float = -degToRad(0.83)
  if(GlobalCurrentView == 0){
    horalt = 0
  }
  var time = getStartOfDayFromMillis(millis: date.millisecondsSince1970)
  let ogtime2 = getStartOfDayFromMillis(millis: date2.millisecondsSince1970)
  var time2 = ogtime2

  //print("Today: \(time)")
  
  updatePositionYearMath(time)
  let dayOfSun = Sunline(time)
 // print("Day of sun \(time)")
  
  let firstPosition = polarTo3D(polar: getSunPositionSimple(millis: time))
  
  updatePositionYearMath(time2)

  time2 = time2 - 1000 * 60 * 60 * 2
  var bestTime = time2
  var bestDist = Float.infinity
  while(time2 < ogtime2 + 1000 * 60 * 60 * 2){
    let checkPosition = polarTo3D(polar: getSunPositionSimple(millis: time2))
    let dist = checkPosition.squaredDist3DTo(to: firstPosition)
    if(dist < bestDist){
      bestTime = time2
      bestDist = dist
    }
  time2 += Int(timeInterval * 60 * 60 * 1000)
  }
  time2 = bestTime
  time2 += Globalsunlineadder
  time += Globalsunlineadder
  updatePositionYearMath(time)

  var oldPos = getSunPositionSimple(millis: time)
  var sunPosition = oldPos
  var skip = 0
  let inc = Int(1000 * 60 * 60 * timeInterval) * Globalmultiplier
  repeat{
    oldPos = sunPosition
    skip += inc
    sunPosition = getSunPositionSimple(millis: time + skip)
  }while(sunPosition.alt() >= horalt && sunPosition.alt() < oldPos.alt())
  skip -= inc
  dayOfSun.setStartMillis(time + skip)
  
  var i: Double = 0
  var prevWasAbove = false
  if(getSunPositionSimple(millis: time).alt() >= horalt){
    prevWasAbove = true
  }
  while(i <= 24){
    sunPosition = getSunPositionSimple(millis: time)

    if(prevWasAbove != (sunPosition.alt() >= horalt)){
      //Crossed horizon
      dayOfSun.sunriseExist = true
      //Fit line to horizon
      let rememberthetime = time
      let rememberthetime2 = time2
      
      var currentBest = sunPosition
      var current = sunPosition
      repeat{
        currentBest = current
        time -= Int(1000 * 60 * 60 * timeInterval / 5) * Globalmultiplier
        time2 -= Int(1000 * 60 * 60 * timeInterval / 5) * Globalmultiplier
        current = getSunPositionSimple(millis: time)
      }while(abs(currentBest.alt() - horalt) > abs(current.alt() - horalt))
      
      currentBest.setPayload(time2)
      currentBest.payloadString = getHourStringFromMillis(millis: time2)
      dayOfSun.add(polar: currentBest)
      
      
      time = rememberthetime
      time2  = rememberthetime2
      prevWasAbove = !prevWasAbove
    }else if(sunPosition.alt() >= horalt){
      sunPosition.setPayload(time2)
      if(abs(Double(time2) / (1000 * 60 * 60) - floor(Double(time2) / (1000 * 60 * 60))) == 0){
      sunPosition.payloadString = getHourStringFromMillis(millis: time2)
      }
      dayOfSun.add(polar: sunPosition)
      prevWasAbove = true
    }else{
      prevWasAbove = false
    }
    time += Int(1000 * 60 * 60 * timeInterval) * Globalmultiplier
    time2 += Int(1000 * 60 * 60 * timeInterval) * Globalmultiplier
    i += timeInterval
  }
  if(southernMode()){
    dayOfSun.invert()
  }
  return dayOfSun
}

public func safeGetSunPosition(millis: Int) -> Polar {
  return sunPositionOwnMath(millis: millis)
}

public func getSunPosition(millis: Int) -> Polar {
  
  updatePositionYearMath(millis)
  return sunPositionMath(millis: millis)
}

public func getSunPositionSimple(millis: Int) -> Polar {
  
  return sunPositionMath(millis: millis)
}

internal func getStartOfDayFromMillis(millis: Int) -> Int {
  
  let date = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
  let calendar = getCurrentCalendarTimeZone()
  var dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
  
  dateComponent.hour = 1
  dateComponent.minute = 0
  dateComponent.second = 0
  
  let startOfDay = calendar.date(from: dateComponent)!.millisecondsSince1970
  
  return startOfDay
}

