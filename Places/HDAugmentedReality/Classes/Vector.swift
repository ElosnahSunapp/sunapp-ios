//
//  Vector.swift
//  Places
//
//  Created by Phillip Løjmand on 25/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit

public class Vector {
  
  var coordinates = [Float]()
  var payload = 0
  var payloadString = ""
  
  init(){
  }
  
  init(_ x : Float,_ y : Float){
    coordinates.append(x)
    coordinates.append(y)
  }
  
  init(_ x : Float,_ y : Float,_ z : Float){
    coordinates.append(x)
    coordinates.append(y)
    coordinates.append(z)
  }
  
  public func normalize(){
    var length: Float = 0
    for i in 0...coordinates.count-1{
      length += pow(coordinates[i], 2)
    }
    length = sqrt(length)
    for i in 0...coordinates.count-1{
      coordinates[i] = coordinates[i] / length
    }
    
  }
  
  public func toScreenCoords(){
    setX((x() + Float(Globalwidth / 2)) * scaleX())
    setY((Float(Globalheight / 2) - y()) * scaleY())
  }
  
  public func add(_ value: Float){
    coordinates.append(value)
  }
  
  init(array: Array<Float>){
    self.coordinates = array
  }
  
  init(array: Array<Double>){
    for index in 0...array.count-1 {
      self.coordinates.append(Float(array[index]))
    }
    
  }
  
  public func x() -> Float{
    if(!(coordinates.count >= 1)){
      return -1
    }
    return coordinates[0]
  }
  
  public func y() -> Float{
    if(!(coordinates.count >= 2)){
      return -1
    }
    return coordinates[1]
  }
  
  public func z() -> Float{
    if(!(coordinates.count >= 3)){
      return -1
    }
    return coordinates[2]
  }
  
  public func xI() -> Int{
    if(!(coordinates.count >= 1)){
      return -1
    }
    return Int(coordinates[0])
  }
  
  public func yI() -> Int{
    if(!(coordinates.count >= 2)){
      return -1
    }
    return Int(coordinates[1])
  }
  
  public func zI() -> Int{
    if(!(coordinates.count >= 3)){
      return -1
    }
    return Int(coordinates[2])
  }
  
  public func inRect(topLeftX: Float, topLeftY: Float, bottomRightX: Float, bottomRightY: Float) -> Bool{
    let realX = x() + Float(Globalwidth / 2)
    let realY = y() + Float(Globalheight / 2)
    if(realX >= topLeftX && realX <= bottomRightX && realY >= topLeftY && realY <= bottomRightY){
      return true
    }else{
      return false
    }
  }
  
  public func inRect(topLeft: Vector, bottomRight: Vector) -> Bool{
    let realX = x() + Float(Globalwidth / 2)
    let realY = y() + Float(Globalheight / 2)
    if(realX >= topLeft.x() && realX <= bottomRight.x() && realY >= topLeft.y() && realY <= bottomRight.y()){
      return true
    }else{
      return false
    }
  }
  
  public func inBoundary() -> Bool{
    return inRect(
      topLeftX: Float(Globalwidth) * Globalboundary.x(), topLeftY: Float(Globalheight) * Globalboundary.y(),
      bottomRightX: Float(Globalwidth) * (1-Globalboundary.x()), bottomRightY: Float(Globalheight) * (1-Globalboundary.y()))
  }
  
  public func inView() -> Bool{
    return inRect(
      topLeftX: Float(-Globalwidth) * 0.35, topLeftY: Float(-Globalheight) * 0.35,
      bottomRightX: Float(Globalwidth) * 1.35, bottomRightY: Float(Globalheight) * 1.35)
  }
  
  public func toCGPoint() -> CGPoint{
    return CGPoint(x: Double(x()), y: Double(y()))
  }
  
  public func angleTo(to: Vector) -> Float{
    return atan2(to.y() - y(), to.x() - x())
  }
  
  public func squaredDist3DTo(to: Vector) -> Float{
    return pow(x() - to.x(),2) + pow(y() - to.y(),2) + pow(z() - to.z(),2)
  }
  
  public func squaredDist2DTo(to: Vector) -> Float{
    return pow(x() - to.x(),2) + pow(y() - to.y(),2)
  }
  
  public func makeUnit(){
    if(coordinates.count == 2){
      let l = sqrt(pow(x(),2) + pow(y(),2))
      setX(x() / l)
      setY(y() / l)
    }
    if(coordinates.count == 3){
      let l = sqrt(pow(x(),2) + pow(y(),2) + pow(z(),2))
      setX(x() / l)
      setY(y() / l)
      setZ(y() / l)
    }
  }
  
  public func move(dir: Vector,dist: Float){
    dir.normalize()
    setX((x() + dir.x() * dist))
    setY((y() + dir.y() * dist))
  }
  
  public func setX(_ x: Float){
    if(coordinates.count > 0){
      self.coordinates[0] = x
    }else{
      self.coordinates.append(x)
    }
  }
  
  public func setY(_ y: Float){
    if(coordinates.count > 1){
      self.coordinates[1] = y
    }else{
      while(coordinates.count < 2){
        self.coordinates.append(y)
      }
    }
  }
  
  public func setZ(_ z: Float){
    if(coordinates.count > 2){
      self.coordinates[2] = z
    }else{
      while(coordinates.count < 3){
        self.coordinates.append(z)
      }
    }
  }
  
  public func setPayload(_ payload: Int){
    self.payload = payload
  }
  
  public func getPayload() -> Int{
    return payload
  }
  
  public func rotate2D(a: Float){
    let aRad = a * 3.1415 / 180
    let nX = cos(aRad)*x() - sin(aRad)*y()
    let nY = sin(aRad)*x() + cos(aRad)*y()
    setX(nX)
    setY(nY)
  }
  
}
