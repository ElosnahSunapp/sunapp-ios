//
//  Stroke.swift
//  Places
//
//  Created by Phillip Løjmand on 16/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation

class Stroke {

  var stroke = [Polar]()
  var stroke3D = [Vector]()
  var start3D: Vector!
  
  func add(_ point: Polar){
    if(size() == 1){
      start3D = polarTo3D(polar: point)
      start3D.normalize()
      start3D.setZ(max(start3D.z(), 0))
      stroke3D.append(start3D)
      stroke.append(point3DToPolar(point3D: start3D))
    }else{
    stroke.append(point)
    let point3D = polarTo3D(polar: point)
    point3D.normalize()
    stroke3D.append(point3D)
    }
  }
  
  func get(_ i: Int) -> Polar{
    return stroke[i]
  }
  
  func get3D(_ i: Int) -> Vector{
    return stroke3D[i]
  }
  
  func set(_ i: Int, _ value: Polar){
    stroke[i] = value
    stroke3D[i] = polarTo3D(polar: value)
  }
  
  func set(_ i: Int, _ value: Vector){
    stroke3D[i] = value
    stroke[i] = point3DToPolar(point3D: value)
  }

  
  func size() -> Int{
    return stroke.count
  }
  
  func clear(){
    start3D = Vector()
    stroke.removeAll()
    stroke3D.removeAll()
  }
  
}



