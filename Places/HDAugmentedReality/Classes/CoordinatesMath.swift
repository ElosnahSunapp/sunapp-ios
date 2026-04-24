//
//  CoordinatesMath.swift
//  Places
//
//  Created by Phillip Løjmand on 20/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import GLKit



// Towards XY conversions

public func polarTo3D(polar: Polar) -> Vector{

  let point = Vector()
  
  point.add(Float(sin(adjustAzimuth(heading: polar.az())) * sin(polar.zenith())) * 1000)
  point.add(Float(cos(adjustAzimuth(heading: polar.az())) * sin(polar.zenith())) * 1000)
  point.add(Float(cos(polar.zenith())) * 1000)
  point.add(1)

  return point
}

public func polarTo3D(polar: Array<Polar>) -> Array<Vector>{
  
  var array3D = [Vector]()
  
  for polar in polar{
    let vector3D = polarTo3D(polar: polar)
    vector3D.setPayload(polar.payload)
    vector3D.payloadString = polar.payloadString
    array3D.append(vector3D)
    
  }
  return array3D
}


public func point3DToXY(fillArray: inout Vector, point3D: Vector) -> Bool{
  if(GlobalprojectionMatrix == nil){
     return false
  }
  let cameraCoordinateVector = GLKMatrix4MultiplyVector4(GlobalprojectionMatrix!, GLKVector4Make(point3D.x(), point3D.y(), point3D.z(), 1))
  
 //   print(GlobalprojectionMatrix.m)
 //   print(cameraCoordinateVector.v)
  if(cameraCoordinateVector[2] > 0) {
    //print("V0 \(cameraCoordinateVector[0]), v3 \(cameraCoordinateVector[3]), gWidth \(Globalwidth)")
    fillArray.setX((cameraCoordinateVector[0] / cameraCoordinateVector[3]) * Float(Globalwidth) - (GlobalhorizonVector.y() * GlobalverticalOffset))
    fillArray.setY((cameraCoordinateVector[1] / cameraCoordinateVector[3]) * Float(Globalheight) - (GlobalhorizonVector.x() * GlobalverticalOffset))
    fillArray.setPayload(point3D.payload)
    fillArray.payloadString = point3D.payloadString
    return true
  }else{
    return false
  }
}

public func point3DToXY(fillArray: inout Array<Vector>, point3D: Array<Vector>){
  fillArray.removeAll()
  var i = 0
  while(i < point3D.count){
  let coordinates = point3D[i]
  var newPoint = Vector(0,0)
    if(point3DToXY(fillArray: &newPoint, point3D: coordinates)){
      fillArray.append(newPoint)
    }
    if(newPoint.inView()){
      i += 1
    }else{
      if(i > point3D.count - 2){
        i+=1
      }else{
        i += 4
      }
    }
  }
}


public func convertToXY(fillArray: inout Vector, polar: Polar) -> Bool{
  let point3D = polarTo3D(polar: polar)
  if(point3DToXY(fillArray: &fillArray, point3D: point3D)){
    return true
  }
  return false
}


//Towards Polar conversions

public func xyTo3DPoint(pointXY: Vector) -> Vector{
  var cameraCoordinateVector = [Float]()
  let width = Float(Globalwidth)
  let height = Float(Globalheight)
  cameraCoordinateVector.append(((pointXY.x() + (GlobalhorizonVector.y() * GlobalverticalOffset))) / width)
  cameraCoordinateVector.append(((pointXY.y() + (GlobalhorizonVector.x() * GlobalverticalOffset))) / height)
  cameraCoordinateVector.append(1)
  cameraCoordinateVector.append(1)
  
  
  let point = GLKMatrix4MultiplyVector4(GlobalinversedprojectionMatrix, GLKVector4Make(cameraCoordinateVector[0], cameraCoordinateVector[1], cameraCoordinateVector[2], cameraCoordinateVector[3]))
  return Vector(point[0], point[1], point[2])
}

public func point3DToPolar(point3D: Vector) -> Polar {
  point3D.normalize()
  
  let polar = Polar()
  if(point3D.y() >= 0){
    polar.setAZ(atan(point3D.x() / point3D.y()))
  }else{
    polar.setAZ(Float.pi + atan(point3D.x() / point3D.y()))
  }
  polar.setAZ(polar.az() + polar.az() - adjustAzimuth(heading: polar.az()))
  polar.setZenith(acos(point3D.z()))
  polar.setAlt(Float.pi / 2 - polar.zenith())
  return polar
}

public func convertToPolar(pointXY: Vector) -> Polar{
  return point3DToPolar(point3D: xyTo3DPoint(pointXY: pointXY))
}

public func distanceBetweenEuler(from: Polar, to: Polar) -> Float{
  return polarTo3D(polar: from).squaredDist3DTo(to: polarTo3D(polar: to))
}
