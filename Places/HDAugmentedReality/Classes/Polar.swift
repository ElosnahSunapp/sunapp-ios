//
//  Polar.swift
//  Places
//
//  Created by Phillip Løjmand on 24/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation

public func addAZ(_ az1: Float, _ az2: Float) -> Float{
  var result = az1 + az2
  while(result > Float.pi * 2){
    result -= Float.pi * 2
  }
  return result
}

public func subtractAZ(_ az1: Float, _ az2: Float) -> Float{
  var result = az1 - az2
  while(result < 0){
    result += Float.pi * 2
  }
  return result
}

public class Polar {
  
  var coordinates = [Float]()
  var payload = 0
  var effect: Double = 0
  var payloadString = ""
  
  init(){
    self.coordinates.append(0)
    self.coordinates.append(0)
    self.coordinates.append(0)
    self.coordinates.append(0)
  }
  
  init(zenith: Float, azimuth: Float){
    self.coordinates.append(zenith)
    self.coordinates.append(Float.pi / 2 - zenith)
    self.coordinates.append(azimuth)
    self.coordinates.append(0)
  }
  
  init(altitude: Float, azimuth: Float){
    self.coordinates.append(Float.pi / 2 - altitude)
    self.coordinates.append(altitude)
    self.coordinates.append(azimuth)
    self.coordinates.append(0)
  }
  
  init(array: Array<Float>){
    self.coordinates = array
    }
  
  init(array: Array<Double>){
    for index in 0...array.count-1 {
      self.coordinates.append(Float(array[index]))
    }
    
  }
  
  public func az() -> Float{
    return coordinates[2]
  }
  
  public func alt() -> Float{
    return coordinates[1]
  }
  
  public func zenith() -> Float{
    return coordinates[0]
  }
  
  public func setZenith(_ x: Float){
    if(coordinates.count > 0){
      self.coordinates[0] = x
    }else{
      self.coordinates.append(x)
    }
  }
  
  public func setAlt(_ y: Float){
    if(coordinates.count > 1){
      self.coordinates[1] = y
    }else{
      while(coordinates.count < 2){
        self.coordinates.append(y)
      }
    }
  }
  
  public func setAZ(_ z: Float){
    if(coordinates.count > 2){
      self.coordinates[2] = z
    }else{
      while(coordinates.count < 3){
        self.coordinates.append(z)
      }
    }
    while(self.coordinates[2] < 0){
      self.coordinates[2] += Float.pi * 2
    }
  }
  
  public func setPayload(_ payload: Int){
    self.payload = payload
  }
  
  public func addPayload(_ payload: Int){
    self.payload += payload
  }
  
  public func getPayload() -> Int{
    return payload
  }
  
  public func setEffect(_ effect: Double){
    self.effect = effect
  }
  
  public func getEffect() -> Double{
    return self.effect
  }
  
}
