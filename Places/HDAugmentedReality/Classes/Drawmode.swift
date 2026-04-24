//
//  Drawmode.swift
//  Places
//
//  Created by Phillip Løjmand on 16/08/2018.
//  Copyright © 2018 casafox. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

public var sphereDotsCalculated = false
public var sphereDots = [Polar]()

class Drawmode {
  var azAngleStarts  = [Int]()
  
  let blockPrecision:Float = 1
  var blockFunction = [Float : Float]()
  var blockFunctionStroke = [Float : Float]()
  
  var stroke = Stroke()
  var strokes = Strokes()
  
  private var drawAreaPath: UIBezierPath! = UIBezierPath()
  private var drawAreaPathPoints = 0
  
  
  private var drawAreaPathTop: UIBezierPath! = UIBezierPath()
  private var drawAreaPathPointsTop = 0
  
  private var drawAreaPathStroke: UIBezierPath! = UIBezierPath()
  private var drawAreaPathStrokePoints = 0
  
  private var lastSecond = Vector()
  private var lastThird = Vector()
  
  private var lastSecondTop = Vector()
  private var lastThirdTop = Vector()
  
  private var lasttoStroke = Vector()
  
  private var topVectorsGround = [CGPoint()]
  
  private var blockedCache: [Float: TwoFloats] = [:]
  
  public var node = SKNode()
  private var grayArea = SKShapeNode()
  private var areaStroke = SKShapeNode()
  private var areaText = [SKLabelNode]()
  
  var context: CGContext!
  var pathForStroke: [CGPath] = []
  
  init(){
    dBug("DRAMODE INIT")
    if(!sphereDotsCalculated){
    sphereDots = generateSphereDots(N: 7000)
    dBug("Calculating weights")
    calculateWeightOfSphereDots()
    dBug("Weights calculated")
    destroyEmptyDots()
    calcIrradiation()
    }
    initializeBlockFunction()
    topVectorsGround.removeAll()
    strokes.removeAll()
    stroke.clear()
    drawAreaPathStroke.lineWidth = GloballineWidth
    
    grayArea.alpha = CGFloat(Float(160) / Float(255))
    grayArea.fillColor = UIColor.gray
    grayArea.strokeColor = UIColor.clear

    //grayArea.blendMode = SKBlendMode.screen
    node.addChild(grayArea)
    node.zPosition = 2
    
    areaStroke.strokeColor = UIColor.red
    areaStroke.zPosition = 2
    node.addChild(areaStroke)
    for _ in 0 ... 10{
      let label = SKLabelNode(fontNamed: "Helvetica Bold")
      label.isHidden = true
      label.fontSize = CGFloat(GlobalstandardFontSize * Globalscale)
      label.horizontalAlignmentMode = .center
      node.addChild(label)
      areaText.append(label)
    }
  }
  
  public func generateSphereDots(N: Int) -> [Polar] {
    dBug("Generate Sphere Dots")
    var dots = [Polar]()
    var Ncount = 0
    let a: Double = 4 * Double.pi / Double(N)
    let d = sqrt(a)
    let M0 = round(Double.pi / d)
    let d0 = Double.pi / M0
    let dp = a / d0
    var ze: Double!
    var Mp: Int!
    var p: Double!
    
    for m in 0..<Int(M0/2 + 1){
      azAngleStarts.append(Ncount)
      ze = Double.pi * (Double(m) + 0.5) / M0
      Mp = Int(round(2 * Double.pi * sin(ze) / dp))
      
      for n in 0..<Mp{
        p = 2 * Double.pi * Double(n) / Double(Mp)
        dots.append(Polar(zenith: Float(ze), azimuth: Float(p)))
        Ncount += 1
      }
    }
    dBug("Created sphere of \(Ncount) dots")
    return dots
  }
  
  public func calculateWeightOfSphereDots(){
    dBug("Calculate Weight Of SphereDots")
    let minuteInterval: Int = 10
    let hourInterval: Double = Double(minuteInterval) / 60
    
    var time = newYearMillis
    var sunPosition: Polar!
    var interval = [0,0]
    var zeIndex: Int!
    var index: Int!
    var i:Double = 0
    var lasti:Double = -1
    while(i<=365.25){
      if(floor(lasti) != floor(i)){
        updatePositionYearMath(time)
      }
      sunPosition = sunPositionMath(millis: time)
      
      if(sunPosition.zenith() < degToRad(90.76)){
        interval[0] = 0
        interval[1] = azAngleStarts.count - 1
        zeIndex = findValeyZeDist(ze: sunPosition.zenith(), interval: &interval)
        
        interval[0] = azAngleStarts[zeIndex]
        interval[1] = azAngleStarts[min(zeIndex +  1, azAngleStarts.count - 1)]
        
        if(interval[0] == interval[1]){
          interval[1] = sphereDots.count - 1
        }
        index = findValeyDist(az: sunPosition.az(), interval: &interval)
        sphereDots[index].addPayload(minuteInterval)
      }
      
      time += 1000 * 60 * minuteInterval
      lasti = i
      i += hourInterval / 24
    }
  }
  
  func destroyEmptyDots(){
    dBug("Destroy Empty Dots")
    var i = 0
    var removed = 0
    while(i < sphereDots.count){
      if(sphereDots[i].getPayload() == 0){
        sphereDots.remove(at: i)
        removed += 1
      }else{
        i += 1
      }
    }
    dBug("Removed \(removed) dots")
    dBug("\(sphereDots.count) relevant dots")
  }
  
  func calcIrradiation(){
    var totalIrradiation: Double = 2500 //kWh/m2 yearly
    let trope: Double = 22.5
    if(abs(latitude) > trope){
      totalIrradiation = pow((90 - abs(latitude)) / (90 - trope),2) * 2000 + 500 //Approx
    }
    
    var totalEffect: Double = 0
    var i = 0
    while(i < sphereDots.count){
      sphereDots[i].setEffect(Double(cos(sphereDots[i].zenith())))
      totalEffect += sphereDots[i].getEffect()
      i += 1
    }
    
    //Adjust effect
    let effectmult = totalIrradiation / totalEffect
    i = 0
    while(i < sphereDots.count){
      sphereDots[i].setEffect(sphereDots[i].getEffect() * effectmult)
      i += 1
    }
  }
  
  func findValeyDist(az: Float, interval: inout [Int]) -> Int{
    let check: Int = (interval[0] + interval[1]) / 2
    var left = check - 1
    if(left < interval[0]){
      left = interval[1]
    }
    var right = check + 1
    if(right > interval[1]){
      right = interval[0]
    }
    
    var checkDist: Float = abs(sphereDots[check].az() - az)
    if(checkDist > Float.pi){
      checkDist = abs(checkDist - 2 * Float.pi)
    }
    
    var leftDist: Float = abs(sphereDots[left].az() - az)
    if(leftDist > Float.pi){
      leftDist = abs(leftDist - 2 * Float.pi)
    }
    
    var rightDist: Float = abs(sphereDots[right].az() - az)
    if(rightDist > Float.pi){
      rightDist = abs(rightDist - 2 * Float.pi)
    }
    
    if(checkDist <= leftDist && checkDist <= rightDist){
      return check
    }else{
      if(leftDist < rightDist){
        interval[1] = left
      } else {
        interval[0] = right
      }
      if(interval[0] == interval[1]){
        return check
      }
      return findValeyDist(az: az, interval: &interval)
    }
    
    
  }
  
  func findValeyZeDist(ze: Float, interval: inout [Int]) -> Int{
    let check: Int = (interval[0] + interval[1]) / 2
    let left = max(check - 1, 0)
    let right = min(check + 1, azAngleStarts.count - 1)
    
    let checkDist: Float = abs(sphereDots[azAngleStarts[check]].zenith() - ze)
    let leftDist: Float = abs(sphereDots[azAngleStarts[left]].zenith() - ze)
    let rightDist: Float = abs(sphereDots[azAngleStarts[right]].zenith() - ze)
    
    if(checkDist <= leftDist && checkDist <= rightDist){
      return check
    }else{
      if(leftDist < rightDist){
        interval[1] = left
      }else{
        interval[0] = right
      }
      return findValeyZeDist(ze:ze, interval: &interval)
    }
  }
  
  public func initializeBlockFunction(){
    clearBlockStroke()
    clearBlock()
  }
  
  func clearBlockStroke(){
    var i:Float = 0
    while(i < 360){
      blockFunctionStroke[i] = Float(0)
      i+=blockPrecision
    }
  }
  
  
  func clearBlock(){
    var i:Float = 0
    while(i < 360){
      blockFunction[i] = Float(0)
      i+=blockPrecision
    }
  }
  
  func updateBlockFunctionWithStroke() -> Bool{
    var matters = false
    var i: Float = 0
    while(i < 360){
      if(blockFunctionStroke[i]! > blockFunction[i]!){
        blockFunction[i] = blockFunctionStroke[i]
        matters = true
      }
      i += blockPrecision
    }
    return matters
  }


  func handleDrawing(touchEvent: TouchEvent, x: Int, y: Int){


    let point3D = xyTo3DPoint(pointXY: Vector(Float(x),Float(y)))
    point3D.normalize()
    point3D.setZ(max(point3D.z(),0))
    let polar = point3DToPolar(point3D: point3D)
    
    if(GlobalisDrawingLine){
      //Make line
      if(touchEvent == TouchEvent.ACTION_DOWN){
        startLine(polar)
      }else{
        updateLine(x, y)
      }
    }else{
      stroke.add(polar)
      if(stroke.size() >= 2){
        lineSegmentToBlockFunctionStroke(stroke.get(stroke.size() - 2), stroke.get(stroke.size() - 1))
      }
    }
    
    updateBlockHourLabel()
    
    if(touchEvent == TouchEvent.ACTION_UP){
      if(updateBlockFunctionWithStroke()){
        strokes.append(stroke)
        stroke = Stroke()
      }else{
        stroke.clear()
        clearBlockStroke()
      }
    }

  }

  func startLine(_ polar: Polar){
    stroke = Stroke()
    for _ in 0 ... 14 {
      stroke.add(polar)
    }
  }
  
  func updateLine(_ x: Int, _ y: Int){
    let point3D = xyTo3DPoint(pointXY: Vector(Float(x),Float(y)))
    point3D.normalize()
    point3D.setZ(max(point3D.z(),0))
    let polar = point3DToPolar(point3D: point3D)
    
    let lines = stroke.size()
    if(lines > 0){
      let avg = Vector()
      var from = stroke.get(0)
      var to = Polar()
      stroke.set(lines - 1, point3D)
      
      let dist = sqrt(point3D.squaredDist3DTo(to: stroke.get3D(0))) / 2
      
      if(dist < 0.95){
        clearBlockStroke()
        for i in 1 ... lines - 1{
          let startWeight = (Float(0.5 - Double(i) / Double(lines - 1)) * (1 - pow(dist, 10)) + 0.5)
          
          avg.setX(stroke.get3D(0).x() * startWeight + point3D.x() * (1 - startWeight))
          avg.setY(stroke.get3D(0).y() * startWeight + point3D.y() * (1 - startWeight))
          avg.setZ(stroke.get3D(0).z() * startWeight + point3D.z() * (1 - startWeight))
        
          avg.normalize()
          to = point3DToPolar(point3D: avg)
          stroke.set(i, to)
          
          //Add line to strokeblock function
          lineSegmentToBlockFunctionStroke(from,to)
          from = to
        }
      }
    }
  }
  
  func lineSegmentToBlockFunctionStroke(_ from: Polar,_ to: Polar){
    let azStart:Float = getAzForBlockFunction(v: from.az())
    
    let azEnd:Float = getAzForBlockFunction(v: to.az())
    
    var mult = 1
    
    if(abs(azStart - azEnd) > 180){
      mult = -1
    }
    
    let diff:Float = min(min(abs(azEnd - azStart),abs(azEnd - (azStart + 360))),abs(azEnd - (azStart - 360)))
    var p:Float = 0
    var k = azStart

    while(p <= 1) {
     
      k += blockPrecision * signum(azEnd - azStart) * Float(mult) * signum(p)
      
      if(k < 0) {k += 360}
      if(k >= 360) {k -= 360}
      
      p += blockPrecision / diff
      
      var blockValue = from.alt()
      if(azStart != azEnd){
        blockValue = from.alt() * (1 - p) + to.alt() * p
      }
      if(blockValue > 0){
        
        blockFunctionStroke[k] = blockValue
      }
    }
  }
  
  func getAzForBlockFunction(v: Float) -> Float{
    var a = (round(radToDeg(v) / blockPrecision) * blockPrecision).remainder(dividingBy: 360)
    if(a < 0){
      a += 360
    }
    return a
  }
  
  func getBlocked(_ hours: Bool) -> [Double]{
    var sunHours:[Double] = [0,0]
    var adder: Double = 0
    for dot in sphereDots{
      if(hours){
        adder = Double(dot.payload) / 60
      }else{
        adder = dot.getEffect()
      }
      sunHours[0] += adder
      
      let az = getAzForBlockFunction(v: dot.az())
      let block1 = blockFunctionStroke[az]
      let block2 = blockFunction[az]

      if(block1 == 0 && block2 == 0){
        sunHours[1] += adder
      }else if(block1! <= dot.alt() && block2! <= dot.alt()){
        sunHours[1] += adder
      }
    }
    return sunHours
  }
  
  
  func getBlocked(_ a: Float, _ b: Float, _ hours: Bool ) -> [Float]{
    var from = a
    var to = b
    if(to < from){
      to += 360
    }
    if(to == from){
      from = 0
      to = 360
    }
    var sunHours: [Float] = [0,0]
    var adder: Float = 0
    for i in 0 ... sphereDots.count - 1{
      if(hours){
        adder = Float(sphereDots[i].payload) / 60
      }else{
        adder = Float(sphereDots[i].getEffect())
      }
      
      //Total sun hours
      sunHours[0] += adder
      
      let azForBlock: Float = getAzForBlockFunction(v: sphereDots[i].az())
      var maxBlock = blockFunctionStroke[azForBlock]
      let normal = blockFunction[azForBlock]
      if(normal! > maxBlock!){
        maxBlock = normal
      }
      if(azForBlock >= from && azForBlock <= to){
        if(maxBlock! >= sphereDots[i].alt()){
          sunHours[1] += adder
        }
      }
    }
    return sunHours
  }
  
  func updateBlockHourLabel(){
    blockedCache.removeAll()
    let hours = getBlocked(GlobalBlockedIshours)
    let p = Int(hours[1] / hours[0] * 100)
    let text = "\(Int(hours[1])) \(getUnit()) (\(p) %)"
    if(Globaldrawing){
      Globaltoolbar?.setBlockedSunHours(text)
    }
  }
  
  func getUnit() -> String{
    if (GlobalBlockedIshours){
      return (Gb?.localizedString(forKey: "hours", value: nil, table: nil))!
    }
    return "kWh/m\u{00B2}"
  }
  
  
  func drawDrawing(_ canvasView: CanvasView){

    if(drawAreaPathStroke.lineWidth != GloballineWidth * CGFloat(Globalscale)){
      drawAreaPathStroke.lineWidth = GloballineWidth * CGFloat(Globalscale)
    }
    pathForStroke.removeAll()
    let strokeColor = UIColor.red
    var from = Vector()
    var to = Vector()
    var bottomFrom = Vector()
    var bottomTo = Vector()
    var textLocation = Vector()
    
    var next:Float!
    var check:Float!
    var check2:Float!
    let increment:Float = blockPrecision
    var skipped:Int = 0
    let maxSkip:Int = 5
    var i:Float = 0
    
    strokeColor.setStroke()
    UIColor.gray.setFill()
    while(i < 360){
      next = i + increment
      check2 = next
      skipped = 0
      repeat {
        check = check2
        check2 = check2 + increment
        if(check2 > 360){
          break
        }
        skipped += 1
      } while(skipped < maxSkip && isAlmostStraight(next, i , check, mod(check2,360)))

      
      if(getBlock(i) > 0 && getBlock(mod(check, 360)) > 0){
        drawAreaSegment(canvasView, &from, &to, &bottomFrom, &bottomTo, mod(check,360), i, check >= 360)
      }
      
      i = check
    }
    completeAreaSegment()
    

    grayArea.path = context.path
    context.beginPath()

    for path in pathForStroke{
      context.addPath(path)
    }
    areaStroke.lineWidth = GloballineWidth * CGFloat(Globalscale)
    areaStroke.path = context.path

  
    i = 0
    i = outArea(increment, i)
    var textIndex = 0
    for arealabel in areaText{
      arealabel.isHidden = true
    }
    repeat{

      i = nextArea(increment, i)
      i = drawAreaText(canvasView, &textLocation, increment, i,textIndex)
      textIndex += 1
    
    }while(i < 359)

  }
  
  func outArea(_ increment: Float, _ i: Float) -> Float{
    var tempi = i
    while(getBlock(tempi) > 0 && tempi < 360 - increment){
      tempi += increment
    }
    return tempi
  }
  
  func nextArea(_ increment: Float, _ i: Float) -> Float{
   var tempi = i
    while(getBlock(tempi) == 0 && tempi < 360 - increment){
      tempi += increment
    }
    return tempi
  }
  
  
  func drawAreaText(_ canvasView: CanvasView,_ textLocation: inout Vector, _ increment: Float, _ i: Float, _ textIndex: Int) -> Float {

    let k: Float = findPlaceForText(increment, i)
    let j: Float = outArea(increment, max(i,k))

    if(k != -1 && convertToXY(fillArray: &textLocation, polar: Polar(altitude: getBlock(k) / 2, azimuth: degToRad(k)))){
      var blockedhours:Float! = nil
      var twoFloats = blockedCache[i]
      if(twoFloats != nil){
        if(twoFloats?.float1 == j){
          blockedhours = twoFloats?.float2
        }
      }
      
      if(blockedhours == nil){
        twoFloats = TwoFloats(j,getBlocked(i,j,GlobalBlockedIshours)[1])
        blockedCache[i] = twoFloats
        blockedhours = twoFloats?.float2
      }
      let hours = "\(Int(blockedhours))  \(getUnit())"
      
      areaText[textIndex].text = hours
      areaText[textIndex].isHidden = false
      areaText[textIndex].position = textLocation.toCGPoint()
      areaText[textIndex].zRotation = CGFloat(GlobalhorizonAngle - Float.pi / 2)
      
    }
    return j
  }
  
  func findPlaceForText(_ increment: Float, _ i: Float) -> Float{
    var j: Float = i
    var dist: Float = 0
    while(getBlock(j) > 0){
      j = mod(j + increment, 360)
      dist += increment
      if(dist >= 360){
        dist = 360
        break
      }
    }
    
    j = i
    
    var foundPlaceForText = false
    var finalDist: Float = 0
    var dist2: Float = 0
    
    while(getBlock(j) > 0){
      j = mod(j + increment, 360)
      dist2 += increment
      if(getBlock(j) > degToRad(8)){
        foundPlaceForText = true
        if(abs(dist2 - finalDist) <= abs(dist / 2 - finalDist)){
          finalDist = dist2
        }
      }
      if(dist2 >= 360){
        dist2 = 360
        break
      }
    }
    
    var k: Float = mod(i + finalDist, 360)
    if(!foundPlaceForText){
      k = -1
    }
    
    return k
  }
  
  func isAlmostStraight(_ first: Float, _ second: Float, _ third: Float, _ fourth: Float) -> Bool{
      return abs((getBlock(first) - getBlock(second)) - (getBlock(third) - getBlock(fourth))) < degToRad(1.4)
  }
  
  func getBlock(_ i: Float) -> Float{

    let a = blockFunction[i]!
    return max(a, blockFunctionStroke[i]!)
  }
  
  func drawAreaBottomSegment(_ canvasView: CanvasView, _ first: Vector, _ second: Vector, _ third: Vector, _ fourth: Vector, _ last: Bool){
  
      //Should draw what's already there
     // print("lastthird \(lastThird.x()), third \(third.x())")
      if(drawAreaPathPoints == 0 || (!second.inView() && !third.inView()) || (drawAreaPathPoints >= 3 && !(lastSecond.x() == first.x() && lastSecond.y() == first.y()))){
        if(drawAreaPathPoints > 0 ){
        drawAreaPath.addLine(to: lastThird.toCGPoint())
        //drawAreaPath.fill(with: CGBlendMode.normal, alpha: CGFloat(Float(160) / Float(255)))
        context?.addPath(drawAreaPath.cgPath)
        
        drawAreaPath.removeAllPoints()
        drawAreaPathPoints = 0
        }
        if((first.inView() || fourth.inView())){
        drawAreaPath.move(to: fourth.toCGPoint())
        drawAreaPath.addLine(to: first.toCGPoint())
        drawAreaPath.addLine(to: second.toCGPoint())
        drawAreaPathPoints = 3
        }
      }else{
        drawAreaPath.addLine(to: second.toCGPoint())
        
        drawAreaPathPoints += 1
      }

    lastThird = Vector(third.x(),third.y())
    lastSecond = Vector(second.x(),second.y())
    
  }
  
  
  func drawAreaTopSegment(_ canvasView: CanvasView, _ first: Vector, _ second: Vector, _ third: Vector, _ fourth: Vector, _ last: Bool){
    
    //Should draw what's already there
    // print("lastthird \(lastThird.x()), third \(third.x())")
    if(drawAreaPathPointsTop == 0 || (!second.inView() && !third.inView()) || (drawAreaPathPointsTop >= 3 && !(lastSecondTop.x() == first.x() && lastSecondTop.y() == first.y()))){
      if(drawAreaPathPointsTop > 0 ){
        concludeTopLinePoints()
      //  drawAreaPathTop.fill(with: CGBlendMode.normal, alpha: CGFloat(Float(160) / Float(255)))
        context?.addPath(drawAreaPathTop.cgPath)
        drawAreaPathTop.removeAllPoints()
        drawAreaPathPointsTop = 0
      }
      if((first.inView() || fourth.inView())){
        drawAreaPathTop.move(to: fourth.toCGPoint())
        drawAreaPathTop.addLine(to: first.toCGPoint())
        drawAreaPathTop.addLine(to: second.toCGPoint())
        topVectorsGround.append(third.toCGPoint())
        drawAreaPathPointsTop = 3
      }
    }else{
      drawAreaPathTop.addLine(to: second.toCGPoint())
      topVectorsGround.append(third.toCGPoint())
      drawAreaPathPointsTop += 1
    }
    
    lastThirdTop = Vector(third.x(),third.y())
    lastSecondTop = Vector(second.x(),second.y())
    
  }
  
  func drawLineSegment(_ canvasView: CanvasView, _ from: Vector, _ to: Vector){
    if(drawAreaPathStrokePoints == 0 || !to.inView() ||
      (drawAreaPathStrokePoints >= 1 && !(lasttoStroke.x() == from.x() && lasttoStroke.y() == from.y()))){
      if(drawAreaPathStrokePoints > 0 ){
        drawAreaPathStroke.addLine(to: lasttoStroke.toCGPoint())
        pathForStroke.append(drawAreaPathStroke.cgPath)
        drawAreaPathStroke.removeAllPoints()
        drawAreaPathStrokePoints = 0
      }
      if(from.inView()){
        drawAreaPathStroke.move(to: from.toCGPoint())
        drawAreaPathStroke.addLine(to: to.toCGPoint())
        drawAreaPathStrokePoints = 2
      }
    }else{
      drawAreaPathStroke.addLine(to: to.toCGPoint())
      drawAreaPathStrokePoints += 1
    }
    
    lasttoStroke = Vector(to.x(),to.y())
  }
  
  
  func completeAreaSegment(){
    if(drawAreaPathPoints > 0 ){
      drawAreaPath.addLine(to: lastThird.toCGPoint())
     // drawAreaPath.fill(with: CGBlendMode.normal, alpha: CGFloat(Float(160) / Float(255)))
      context?.addPath(drawAreaPath.cgPath)
      drawAreaPath.removeAllPoints()
      drawAreaPathPoints = 0
    }
    if(drawAreaPathPointsTop > 0 ){
      concludeTopLinePoints()
     // drawAreaPathTop.fill(with: CGBlendMode.normal, alpha: CGFloat(Float(160) / Float(255)))
      context?.addPath(drawAreaPathTop.cgPath)
      drawAreaPathTop.removeAllPoints()
      drawAreaPathPointsTop = 0
    }
    if(drawAreaPathStrokePoints > 0){
      drawAreaPathStroke.addLine(to: lasttoStroke.toCGPoint())
      pathForStroke.append(drawAreaPathStroke.cgPath)
      drawAreaPathStroke.removeAllPoints()
      drawAreaPathStrokePoints = 0
    }
  }
  
  func concludeTopLinePoints(){
    drawAreaPathTop.addLine(to: lastThirdTop.toCGPoint())
    while(topVectorsGround.count > 0){
      drawAreaPathTop.addLine(to: topVectorsGround.removeLast())
    }
  }
  
  func drawAreaSegment(_ canvasView: CanvasView, _ from: inout Vector, _ to: inout Vector, _ bottomFrom: inout Vector, _ bottomTo: inout Vector, _ next: Float, _ i: Float, _ last: Bool){
    let fromPolar = Polar(altitude: getBlock(i), azimuth: degToRad(i))
    let toPolar = Polar(altitude: getBlock(next), azimuth: degToRad(next))
    
    let fromBottomPolar = Polar(altitude: 0, azimuth: degToRad(i))
    let toBottomPolar = Polar(altitude: 0, azimuth: degToRad(next))
    
    let fromHalfPolar = Polar(altitude: Float.pi / 4, azimuth: degToRad(i))
    let toHalfPolar = Polar(altitude: Float.pi / 4, azimuth: degToRad(next))
    
    
    var successes = 0
    
    //Gray area
    if(convertToXY(fillArray: &from, polar: fromPolar)){
      successes += 1
    }
    
    if(convertToXY(fillArray: &to, polar: toPolar)){
      successes += 1
    }
    
    if(getBlock(i) > Float.pi / 4 && getBlock(next) > Float.pi / 4){
      if(convertToXY(fillArray: &bottomFrom, polar: fromHalfPolar)){
        successes += 1
      }
      if(convertToXY(fillArray: &bottomTo, polar: toHalfPolar)){
        successes += 1
      }
      if(successes == 4){
        if(next > i){
          drawAreaTopSegment(canvasView, from, to, bottomTo, bottomFrom, last)
        }else{
          drawAreaTopSegment(canvasView, to, from, bottomFrom, bottomTo, last)
        }
      }
    }else{
      if(convertToXY(fillArray: &bottomFrom, polar: fromBottomPolar)){
        successes += 1
      }
      if(convertToXY(fillArray: &bottomTo, polar: toBottomPolar)){
        successes += 1
      }
      if(successes == 4){
        if(next > i){
          drawAreaBottomSegment(canvasView, from, to, bottomTo, bottomFrom, last)
        }else{
          drawAreaBottomSegment(canvasView, to, from, bottomFrom, bottomTo, last)
        }
      }
    }
    
    if(successes == 4){
      
      
      
      //Extra on top of half pi
      successes = 2
      
      if(getBlock(i) > Float.pi / 4 && getBlock(next) > Float.pi / 4){
        to = Vector(bottomTo.x(),bottomTo.y())
        from = Vector(bottomFrom.x(),bottomFrom.y())

        if(convertToXY(fillArray: &bottomFrom, polar: fromBottomPolar)){
          successes += 1
        }
        if(convertToXY(fillArray: &bottomTo, polar: toBottomPolar)){
          successes += 1
        }
        if(successes == 4){
          
          if(next > i){
            drawAreaBottomSegment(canvasView, from, to, bottomTo, bottomFrom, last)
          }else{
            drawAreaBottomSegment(canvasView, to, from, bottomFrom, bottomTo, last)
          }
        }
      }
    }
    
    
    
    //Line on top
    successes = 0
    if(convertToXY(fillArray: &from, polar: fromPolar)){
      successes += 1
    }
    
    if(convertToXY(fillArray: &to, polar: toPolar)){
      successes += 1
    }
    
    if(successes == 2){
      if(next > i){
        drawLineSegment(canvasView, from, to)
       // canvasView.drawLine(from: from, to: to, linewidth: Float(GloballineWidth))
      }else{
        //canvasView.drawLine(from: to, to: from, linewidth: Float(GloballineWidth))
        drawLineSegment(canvasView, to, from)
      }
    }

  
  }
  
  func updateBlock(){
    updateBlockFunction()
    updateBlockHourLabel()
  }
  
  func undoStroke(){
    if(Globalstrokes > 0){
      strokes.removeLast()
      updateBlockFunction()
      updateBlockHourLabel()
    }
  }
  
  func deleteStrokes(){
    if(Globalstrokes > 0){
      strokes.removeAll()
      updateBlockFunction()
      updateBlockHourLabel()
    }
  }
  
  func updateBlockFunction(){
    clearBlock()
    clearBlockStroke()
    for innerstroke in strokes.get() {
      for i in 0 ... innerstroke.size() - 2 {
        lineSegmentToBlockFunctionStroke(innerstroke.get(i), innerstroke.get(i + 1))
      }
    }
    updateBlockFunctionWithStroke()
    clearBlockStroke()
    
    if(stroke.size() >= 2){
      for i in 0 ... stroke.size() - 2 {
        lineSegmentToBlockFunctionStroke(stroke.get(i), stroke.get(i + 1))
      }
    }
  }
  
}
