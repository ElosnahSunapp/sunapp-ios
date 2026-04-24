//
//  sunline.swift
//  Places
//
//  Created by Phillip Løjmand on 24/06/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

var sunlineIDTally = 0

public class Sunline {
  var drawColor = UIColor.white
  var labelPos = Vector()
  var labelAngle: Float = 0
  var labelPosIsNull = true
  
  var sunriseLabel = Vector()
  var sunsetLabel = Vector()
  var sunriseInView = false
  var sunsetInView = false
  var sunriseLoaded = false
  var sunsetLoaded = false
  var sunriseExist = false
  
  var eulerArray = [Polar]()
  var array3D = [Vector]()
  var array2D = [Vector]()
  var timeLabels = [Vector]()
  var startMillis = 0
  var labelposDist: Float = 20
  var sunRiseSetNoonTime = [-1,-1,-1]
  
  var timeText = [SKLabelNode]()
  var sunriseText = SKLabelNode(fontNamed: "Helvetica Bold")
  var sunsetText = SKLabelNode(fontNamed: "Helvetica Bold")
  var dateText = SKLabelNode(fontNamed: "Helvetica Bold")
  var lineNode = SKShapeNode()
  var lineShadowNode = SKShapeNode()
  
  var node = SKNode()
  var path = UIBezierPath()
  var cgPath: CGPath!
  let shadowPath = UIBezierPath()
  var shadowCenterVector: Vector!
  var shadowCenterVectorMid: Vector!
  var shadowCenterVectorMid2: Vector!
  var shadowDistToCenter: Float!
  let shader = SKShader(fileNamed: "curveGradientShader.fsh")
  var positiveDir = true
  var isCleanLine = false
  
  public var id = -1
  init(){
    setID()
    initNode()
    getSunrisePeakSunset()
  }
  
  init(_ millis : Int){
    startMillis = millis
    setID()
    initNode()
    getSunrisePeakSunset()
  }
  
  func hideLineNodes(){
    lineNode.isHidden = true
    if(!isCleanLine){
     lineShadowNode.isHidden = true
    }
  }
  
  func hideTextNodes(){
    for label in timeText{
      label.isHidden = true
    }
    sunriseText.isHidden = true
    sunsetText.isHidden = true
    dateText.isHidden = true
  }
  
  func onDestroy() ->SKNode?{
    let r = node.parent
    node.removeAllChildren()
    node.removeFromParent()
    return r
  }
  
  func initNode(){
    let fontSizeText = GlobalstandardFontSize * Globalscale
    for _ in 0 ... 8{
      let label = SKLabelNode(fontNamed: "Helvetica Bold")
      label.isHidden = true
      label.fontSize = CGFloat(fontSizeText)
      label.horizontalAlignmentMode = .center
      label.verticalAlignmentMode = .top
      node.addChild(label)
      timeText.append(label)
    }
    
    sunriseText.isHidden = true
    sunriseText.horizontalAlignmentMode = .center
    sunriseText.verticalAlignmentMode = .top
    sunriseText.fontSize = CGFloat(fontSizeText)
    node.addChild(sunriseText)
    sunsetText.isHidden = true
    sunsetText.horizontalAlignmentMode = .center
    sunsetText.verticalAlignmentMode = .top
    sunsetText.fontSize = CGFloat(fontSizeText)
    node.addChild(sunsetText)
    dateText.isHidden = true
    dateText.horizontalAlignmentMode = .center
    dateText.verticalAlignmentMode = .top
    dateText.fontSize = CGFloat(fontSizeText)
    node.addChild(dateText)
    
    
    
    //newShadowNode.blendMode = SKBlendMode.replace
    node.addChild(lineShadowNode)
    shader.attributes = [
      SKAttribute(name: "center_point", type: .vectorFloat2),
      SKAttribute(name: "minmax_dist", type: .vectorFloat2),
      SKAttribute(name: "reverse", type: .float)
    ]
    node.addChild(lineNode)
    isCleanLine = false
  }
  
  func makeCleanLine(){
    lineShadowNode.removeFromParent()
    dateText.removeFromParent()
    sunsetText.removeFromParent()
    sunriseText.removeFromParent()
    for time in timeText{
      time.removeFromParent()
    }
    isCleanLine = true
  }
  
  func setID(){
    if(id == -1){
      id = sunlineIDTally
      sunlineIDTally += 1
    }
  }
  
  public func setLabelPosDist(dist: Float){
    labelposDist = dist
  }
  
  public func updateLabelText(text: String){
    dateText.text = text
    dateText.isHidden = !canShowLabel()
    dateText.position = getLabelPos().toCGPoint()
    dateText.zRotation = CGFloat(getLabelAngle())
  }
  
  public func invert(){
    eulerArray.reverse()
  }
  
  public func add(polar: Polar){
    eulerArray.append(polar)
  }
  
  public func update3DVector(){
    array3D = polarTo3D(polar: eulerArray)
  }
  
  public func update2DVector(){
    point3DToXY(fillArray: &array2D, point3D: array3D)
  }
  
  public func getPolar(index: Int) -> Polar{
    
    if(eulerArray.count >= index + 1) {
      return eulerArray[index]
    }
    
/*    if(abs(GlobalmillisOfLastYearUpdate -  startMillis) > 1000 * 60 * 60 * 24){
      updatePositionYearMath(startMillis)
    }*/
    return sunPositionOwnMath(millis: startMillis + Int(Globalprecision * 1000 * 60 * 60) * (index))
  }
  
  public func get2DPoints() -> [Vector]{
    return array2D
  }
  
  public func get2DPoint(index: Int) -> Vector{
    return array2D[index]
  }
  
  public func updatePath(){
    path = getPath()
    cgPath = path.cgPath
  }
  
  public func updateNodes(Gcontext: CGContext?){
    lineNode.path = cgPath
    lineNode.lineWidth = path.lineWidth
    lineNode.strokeColor = getColor()
    
    if(!isCleanLine){
      
    
    //Get shadow path
    Gcontext?.beginPath()
    Gcontext?.addPath(shadowPath.cgPath)
    Gcontext?.setLineWidth(CGFloat(GlobalsW))
    Gcontext?.replacePathWithStrokedPath()
    
    lineShadowNode.fillColor = getColor()
    lineShadowNode.strokeColor = UIColor.clear
    

    lineShadowNode.fillShader = shader
    lineShadowNode.path = Gcontext?.path
    
    lineShadowNode.setValue(SKAttributeValue(vectorFloat2: shaderAttrCenter() ?? vector_float2(0.0,0.0)),
                            forAttribute: "center_point")
    lineShadowNode.setValue(SKAttributeValue(vectorFloat2: shaderAttrMinmax() ?? vector_float2(0.0,1.0)),
                            forAttribute: "minmax_dist")
    var reverseAttr:Float = 1.0
    if(!positiveDir){
      reverseAttr = -1.0
    }
    lineShadowNode.setValue(SKAttributeValue(float: reverseAttr), forAttribute: "reverse")
    Gcontext?.beginPath()
    lineShadowNode.isHidden = false
    }
    lineNode.isHidden = false
  }
  
  public func getPath() -> UIBezierPath {
    sunriseInView = false
    sunsetInView = false
    update2DVector()
    let bezierPath = UIBezierPath()
    shadowPath.removeAllPoints()
    var startShadow = false
    
    var first = true
    resetLabelPos()
    var lastVector: Vector!
    var prevVector: Vector!
    
    var fSP: Vector!
    var fSD: Vector!
    var fI = 0
    var lSP: Vector!
    var lSD: Vector!
    var lI = 0
    
    var angle: Float = 0
    var positionFound = false
    timeLabels.removeAll()
    
    var canfind = false
    
    if(array2D.count > 0){
      var i = 0
      
      if(!sunriseLoaded && array2D[0].inView()){
        sunriseLabel.payloadString = getHourMinStringFromMillis(millis: array2D[0].payload)
        sunriseLoaded = true
      }
      
      if(!sunsetLoaded && array2D[array2D.count - 1].inView()){
        sunsetLabel.payloadString = getHourMinStringFromMillis(millis: array2D[array2D.count - 1].payload)
        sunsetLoaded = true
      }
      
      
      while(i < array2D.count){
        let coordinates = array2D[i]
 
        if(coordinates.inView()){
          if(first){
            first = false
            lastVector = coordinates
            bezierPath.move(to: lastVector.toCGPoint())
            prevVector = coordinates
            startShadow = true
            sunriseLabel.setX(coordinates.x())
            sunriseLabel.setY(coordinates.y())
            sunriseInView = true
            fI = i
          }else{
            if(i == array2D.count - 1){
              sunsetLabel.setX(coordinates.x())
              sunsetLabel.setY(coordinates.y())
              sunsetInView = true
              sunsetLabel.setPayload(coordinates.payload)
            }
            

            angle = lastVector.angleTo(to: coordinates)

            let payloadHourDiff = abs(Double(coordinates.getPayload()) / (1000 * 60 * 60) - floor(Double(coordinates.getPayload()) / (1000 * 60 * 60)))

            if(payloadHourDiff == 0 && (i > 4 && i < array2D.count - 5 || !sunriseExist)){
              coordinates.setZ(angle - Float.pi / 2)
              var append = Vector(coordinates.x(), coordinates.y(), coordinates.z())
              append.setPayload(coordinates.getPayload())
              append.payloadString = coordinates.payloadString
              timeLabels.append(append)
            }
            
            if(!positionFound && coordinates.inBoundary() &&
              payloadHourDiff > 0.2 && payloadHourDiff < 0.8
              && i > 4 && i < array2D.count - 5){
              labelAngle = angle
              updateLabelPos(pos: Vector(coordinates.x() - cos(labelAngle - Float.pi/2) * labelposDist * Globalscale,coordinates.y() - sin(labelAngle - Float.pi/2) * labelposDist * Globalscale))
              
              positionFound = true
              }
            if(i % 4 == 0 || i == array2D.count-1 || self.id == yearline.id){
              let sUnitVector = Vector(-(prevVector.y() - coordinates.y()),prevVector.x() - coordinates.x())
              sUnitVector.normalize()
              
              if(startShadow){
                startShadow = false
                shadowPath.move(to: CGPoint(x: Double(prevVector.x() + sUnitVector.x() * GlobalsW / 2),
                                            y: Double(prevVector.y() + sUnitVector.y() * GlobalsW / 2)))
                fSP = prevVector
                fSD = sUnitVector
              }
              bezierPath.addLine(to: coordinates.toCGPoint())
              shadowPath.addLine(to: CGPoint(x: Double(coordinates.x() + sUnitVector.x() * GlobalsW / 2),
                                             y: Double(coordinates.y() + sUnitVector.y() * GlobalsW / 2)))
              lSP = coordinates
              lSD = sUnitVector
              lI = i
              canfind = true
              }
            lastVector = coordinates
          }
          i += 1
          
        }else{
          i = min(i + 5, max(array2D.count - 1,i + 1))
          bezierPath.move(to: coordinates.toCGPoint())
          prevVector = coordinates
          startShadow = true
        }
        
      }
    }
    if(!isCleanLine && canfind){
      //Calculate shadow center
      let det = lSD.x() * fSD.y() - lSD.y() * fSD.x()
      // var u:Float = 1.0
      var t:Float = 1.0
      var u:Float = 1.0
      positiveDir = true
      if(abs(det) < 0.001){
        //Parrallel
        t = 100000
        u = 100000
      }else{
        let p1 = fSP.x() * lSD.y()
        let p2 = fSP.y() * lSD.x()
        let p3 = lSD.x() * lSP.y()
        let p4 = lSD.y() * lSP.x()
        
        let p5 = fSD.x()*fSP.y()
        let p6 = fSD.x()*lSP.y()
        let p7 = fSD.y()*fSP.x()
        let p8 = fSD.y()*lSP.x()
        t = (p1 - p2 + p3 - p4) / det
        if(t < 0){
          positiveDir = false
        }
        t = abs(t)
        u = abs((p5-p6-p7+p8) / det)
      }
      
      let per = Vector(lSP.x() - fSP.x(),lSP.y() - fSP.y())

      per.normalize()
      per.rotate2D(a: -90)

      var dist = (u + t) / 5
      if(!positiveDir){
        dist *= -1
      }
      
      let mp = array2D[(fI + lI) / 2]
      shadowCenterVector = Vector(mp.x() + per.x() * dist,mp.y() + per.y() * dist)
      
     /* let bezierPath2 = UIBezierPath()
      bezierPath2.lineWidth = GloballineWidth * CGFloat(Globalscale)
      bezierPath2.addArc(withCenter: shadowCenterVector.toCGPoint(), radius: CGFloat(sqrt(mp.squaredDist2DTo(to: shadowCenterVector))), startAngle: CGFloat(shadowCenterVector.angleTo(to: fSP)), endAngle: CGFloat(shadowCenterVector.angleTo(to: lSP)), clockwise: !positiveDir)*/
      
      //Convert shadow center to screen coordinates
      shadowCenterVector.toScreenCoords()
      mp.toScreenCoords()
      shadowDistToCenter = sqrt(mp.squaredDist2DTo(to: shadowCenterVector))
      //return bezierPath2
    }
 
    
    
    bezierPath.lineWidth = GloballineWidth * CGFloat(Globalscale)
    
    return bezierPath
  }
  
  public func shaderAttrCenter() -> vector_float2?{
    if(shadowCenterVector == nil){
      return nil
    }
    
    var r =  vector_float2(Float(shadowCenterVector.x()),
                  Float(shadowCenterVector.y()))

    return r
  }
 
  public func setShaderINV(){
    var r = shaderAttrCenter()
    if(r != nil){
      r!.y = Float(UIScreen.main.nativeBounds.height) - r!.y
    }
    
    lineShadowNode.setValue(SKAttributeValue(vectorFloat2: r ?? vector_float2(0.0,0.0)),
                            forAttribute: "center_point")
  }
  
  public func resetShaderFromINV(){
    lineShadowNode.setValue(SKAttributeValue(vectorFloat2: shaderAttrCenter() ?? vector_float2(0.0,0.0)),
                            forAttribute: "center_point")
  }
  
  public func shaderAttrMinmax() -> vector_float2?{
    if(shadowCenterVector == nil){
      return nil
    }
    
    var r:vector_float2!

    if(positiveDir){
      r =  vector_float2(Float(shadowDistToCenter - GlobalsW * (scaleX() + scaleY()) / 2),
                         Float(shadowDistToCenter))
    }else{
      r =  vector_float2(Float(shadowDistToCenter),
                         Float(shadowDistToCenter + GlobalsW * (scaleX() + scaleY()) / 2))
    }
    return r
  }

  
  public func snapLabelsToOtherLine(sunline: Sunline){
    if(timeLabels.count > 0){
      for i in 0 ... timeLabels.count - 1{
        var bestPoint = Vector()
        var bestDist = Float.infinity
        for point in sunline.get2DPoints(){
          let dist = point.squaredDist2DTo(to: timeLabels[i])
          if(dist < bestDist){
            bestDist = dist
            bestPoint = point
          }
        }
        timeLabels[i].setX(bestPoint.x())
        timeLabels[i].setY(bestPoint.y())
      }
    }
  }
  
  public func resetLabelPos(){
    labelPos = Vector()
    labelPosIsNull = true
  }
  
  public func updateLabelPos(pos: Vector){
    labelPos = pos
    labelPosIsNull = false
  }
  public func canShowLabel() -> Bool{
    return (!labelPosIsNull && !Globalcalibrating)
  }
  public func getLabelPos() -> Vector{
    return labelPos
  }
  
  public func getLabelAngle() -> Float{
    return labelAngle
  }
  
  public func setColor(color : UIColor){
    self.drawColor = color
    self.sunsetText.fontColor = color
    self.sunriseText.fontColor = color
    self.dateText.fontColor = color
    for labels in timeText {
      labels.fontColor = color
    }
  }
  
  public func getColor() -> UIColor {
    return self.drawColor
  }
  
  public func setStartMillis(_ millis: Int){
    startMillis = millis
  }
  
  public func getStartMillis() -> Int{
    return startMillis
  }
  
  public func size() -> Int{
    return Int(24 / Globalprecision)
  }
  
  public func getSunrisePeakSunset() -> [String]{
    
    var time = startMillis
    let saveTime = time
    sunRiseSetNoonTime = [-1,-1,-1]
    
    var returnString = ["No sunrise","No sunset","No noon","00:00"]
    var returnStringAlt = [-Float.infinity,-Float.infinity,-Float.infinity]
    var timeIterator: Polar!
    var lastAlt = -Float.infinity
    
    //Look for sunrise, sunset and noon
    
    //Rough search
    let horalt = degToRad(0.83)
    var roughI: [Float] = [0,0,0]
    let fineInterval: Float = 1 / 60
    let roughInterval: Float = 1 / 3
    var i:Float = 0
    while(i <= 24){
      timeIterator = getSunPosition(millis: time)
      if(abs(timeIterator.alt() + horalt) < abs(returnStringAlt[0] + horalt)){
        //Update sunrise
        if(lastAlt < timeIterator.alt()){
         returnStringAlt[0] = timeIterator.alt()
          roughI[0] = i
        }
      }
      
      if(abs(timeIterator.alt() + horalt) < abs(returnStringAlt[1] + horalt)){
        //Update sunset
        if(lastAlt > timeIterator.alt()){
          returnStringAlt[1] = timeIterator.alt()
          roughI[1] = i
        }
      }
      
      //Update solar noon
      if(returnStringAlt[2] < timeIterator.alt()){
        returnStringAlt[2] = timeIterator.alt()
        roughI[2] = i
      }
      time += Int(1000 * 60 * 60 * roughInterval)
      lastAlt = timeIterator.alt()
      
      
      
      i += roughInterval
    }
    
    //reset
    returnStringAlt = [-Float.infinity,-Float.infinity,-Float.infinity]
    lastAlt = -Float.infinity
    var startI = max(roughI[0] - roughInterval,0)
    time = saveTime + Int(1000 * 60 * 60 * startI)
    

    var sunrise: Float = 0
    var sunset: Float = 0
    //Sunrise
    i = startI
    while(i <= min(roughI[0] + roughInterval, 24)){
      timeIterator = getSunPosition(millis: time)
      if(abs(timeIterator.alt() + horalt) < abs(returnStringAlt[0] + horalt)){
        //Update sunrise
        if(lastAlt < timeIterator.alt()){
          returnString[0] = getTimeString(time)
          sunRiseSetNoonTime[0] = time
          returnStringAlt[0] = timeIterator.alt()
          sunrise = i
        }
      }
      time += Int(1000 * 60 * 60 * fineInterval)
      lastAlt = timeIterator.alt()
      
      i += fineInterval
    }
    
    //Reset
    returnStringAlt = [-Float.infinity,-Float.infinity,-Float.infinity]
    lastAlt = -Float.infinity
    
    startI = max(roughI[1] - roughInterval,0)
    time = saveTime + Int(1000 * 60 * 60 * startI)
    
    //Sunset
    i = startI
    while(i <= min(roughI[1] + roughInterval,24)){
      timeIterator = getSunPosition(millis: time)
      if(abs(timeIterator.alt() + horalt) < abs(returnStringAlt[1] + horalt)){
        //Update sunset
        if(lastAlt > timeIterator.alt()){
          returnString[1] = getTimeString(time)
          sunRiseSetNoonTime[1] = time
          returnStringAlt[1] = timeIterator.alt()
          sunset = i
        }
      }
      time += Int(1000 * 60 * 60 * fineInterval)
      lastAlt = timeIterator.alt()
      
      
      i += fineInterval
    }
    
    //Reset
    returnStringAlt = [-Float.infinity,-Float.infinity,-Float.infinity]
    startI = max(roughI[2] - roughInterval,0)
    time = saveTime + Int(1000 * 60 * 60 * startI)
    
    //Noon
    i = startI
    while(i <= min(roughI[2] + roughInterval,24)){
      timeIterator = getSunPosition(millis: time)
      
      //Update solar noon
      if(returnStringAlt[2] < timeIterator.alt()){
        returnString[2] = getTimeString(time)
        sunRiseSetNoonTime[2] = time
        returnStringAlt[2] = timeIterator.alt()
      }
      time += Int(1000 * 60 * 60 * fineInterval)
      
      i += fineInterval
    }
    
    //Day length
    var lengthString: [String]!
    if(sunset > sunrise){
      lengthString = ["\(Int(sunset - sunrise))","\(Int(mod(sunset - sunrise, 1) * 100 * (60 / 100)))"]
    }else{
      lengthString = ["\(Int(24 - (sunrise - sunset)))","\(Int(mod(24 - (sunrise - sunset), 1) * 100 * (60 / 100)))"]
    }
    
    //Make sure it's 2 decimals
    if(lengthString[0].count == 1){
      lengthString[0] = "0\(lengthString[0])"
    }
    if(lengthString[1].count == 1){
      lengthString[1] = "0\(lengthString[1])"
    }
    returnString[3] = "\(lengthString[0]):\(lengthString[1])"
    
    if(!sunriseExist){
      returnString[0] = "--:--"
      returnString[1] = "--:--"
      if(eulerArray.count != 0){
        returnString[3] = "24:00"
      }else{
        returnString[2] = "--:--"
        returnString[3] = "00:00"
      }
    }
    
    return returnString
  }
  
}
