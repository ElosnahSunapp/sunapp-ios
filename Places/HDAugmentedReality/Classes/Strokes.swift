//
//  Strokes.swift
//  Places
//
//  Created by Phillip Løjmand on 18/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation

class Strokes {

var strokes = [Stroke()]
  
  func removeAll(){
    strokes.removeAll()
    Globalstrokes = 0
    updateButtons()
  }
  
  func removeLast(){
    strokes.removeLast()
    Globalstrokes = strokes.count
    updateButtons()
  }
  
  func append(_ stroke: Stroke){
    strokes.append(stroke)
    Globalstrokes = strokes.count
    updateButtons()
  }
  
  func updateButtons(){
    updateLineButton()
    updateUndoButton()
    updateDeleteButton()
    updateCaptureButton()
    updateFreezeButton()
    updateDrawButton()
  }
  
  func size() -> Int{
    return strokes.count
  }
  
  func get() -> [Stroke]{
    return strokes
  }
  
}
