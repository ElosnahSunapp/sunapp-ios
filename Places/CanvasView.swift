
import UIKit
import GLKit
import SpriteKit
import Firebase

extension UIView {
  func asImage() -> UIImage{
    if #available(iOS 10.0, *) {
      let renderer = UIGraphicsImageRenderer(bounds: bounds)
      return renderer.image { rendererContext in
        layer.render(in: rendererContext.cgContext)
      }
    } else {
      UIGraphicsBeginImageContext(self.frame.size)
      self.layer.render(in:UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return UIImage(cgImage: image!.cgImage!)
      }
    }
  }

public var debugStart: DispatchTime!

func start(){
  if(GlobaldebugSpeed){
    debugStart = DispatchTime.now()
  }
}
func printDebugTime(_ msg: String){
  if(GlobaldebugSpeed){
    let end = DispatchTime.now()
    let nanoTime = end.uptimeNanoseconds - debugStart.uptimeNanoseconds
    print("\(msg) \(nanoTime / 10000)")
  }
}

class SKSceneMod: SKScene {
  override func didFinishUpdate() {
    super.didFinishUpdate()
    dBug("SKScene DidFinishUpdate()")
    if(GlobalwaitAndSave > 0){
      GlobalwaitAndSave -= 1
      if(GlobalwaitAndSave == 2){
        Globalinstance.addOverlayToPicture()
        Globalunhide = false
        Globalinstance.savePicture()
      }
      if(GlobalwaitAndSave == 0){
        GlobaltakingscreenshotWhole = false
        inFrontView.isHidden = true
      }
    }
  }
}

class CanvasView: UIView {
  
  var drawColor = UIColor.white
  
  var horizonPoints = 0
  var canDrawHorizonText = false
  
  private var lastPoint: CGPoint!
  private var bezierPath: UIBezierPath!
  private var drawLineFunctionPath: UIBezierPath! = UIBezierPath()
  
  private var drawHorizonAreaPath: UIBezierPath! = UIBezierPath()
  private var pointCounter: Int = 0
  private let pointLimit: Int = 128
  private var preRenderImage: UIImage!
  @IBOutlet weak var imageView: UIImageView?
  private let sunImage = UIImage(named: "sunSprite.png")
  private let sunSprite = SKSpriteNode(imageNamed: "sunSprite.png")
  private let logoSprite = SKSpriteNode(imageNamed: "ic_launcher.png")
  
  private var horizonLine = UIBezierPath()
  private var showHorizonLine = false
  private var horizonColor = UIColor.gray
  
  private var currentFontAttributes =  [
    convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont(),
    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white,
    ] as [String : Any]
  
  private var dragging = -1
  private var startX = 0
  private var startY = 0
  private var startEuler = Polar()
  private var clickmillis = 0
  private var calculating = false
  private var drawing = false
  
  private var sunPos: Vector!
  private var couldFindsunPos = false
  
  public var drawmode: Drawmode!
  public var skScene: SKSceneMod!

  public var horNode: SKShapeNode!
  public var horLine: SKShapeNode!
  public var horText: SKLabelNode!
  
  public var compassText = [SKLabelNode?]()
  public var sunTimeText1: SKLabelNode!
  public var sunTimeText2: SKLabelNode!
  
  public var blewHorText: SKLabelNode!
  public var sunAppText: SKLabelNode!
  public var screendetail1Text: SKLabelNode!
  public var screendetail2Text: SKLabelNode!
  public var screendetail3Text: SKLabelNode!
  
  
  
  public let fiveRed = SKShapeNode()
  public var fiveRedPath: UIBezierPath! = UIBezierPath()
  public let fiveYellow = SKShapeNode()
  public var fiveYellowPath: UIBezierPath! = UIBezierPath()
  public let fiveOrange = SKShapeNode()
  public var fiveOrangePath: UIBezierPath! = UIBezierPath()
  public let twoWhite = SKShapeNode()
  public var twoWhitePath: UIBezierPath! = UIBezierPath()
  
  fileprivate var horizonAnchor : Vector = Vector(0,0)
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    dBug("Canvas View Normal Init")
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    dBug("Canvas View Required Init")
  }
  
  func initialize(){
    dBug("Canvas View Initialize()")
    
    sceneView = SKView(frame: CGRect(x: 0, y: 0, width: Globalwidth, height: Globalheight))
    dBug("SKView size (\(Globalwidth),\(Globalheight))")
    //sceneView.showsFPS = true
    sceneView.showsNodeCount = false
    sceneView.shouldCullNonVisibleNodes = true
    sceneView.preferredFramesPerSecond = Int(targetFPS)
    
    inFrontView = UIImageView(frame: CGRect(x: 0, y: 0, width: Globalwidth, height: Globalheight))
    inFrontView.isHidden = true
    
    
    self.backgroundColor = UIColor(white: 1, alpha: 0)
    initBezierPath()
    
    
    self.layer.shouldRasterize = true
    self.drawmode = Drawmode()

    sceneView.backgroundColor = SKColor.clear
    
    addSubview(sceneView)
    addSubview(inFrontView)
    
    if let view = sceneView as SKView? {
      dBug("SKSceneMod")
      skScene = SKSceneMod(size: view.frame.size)
      
      skScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      skScene.scaleMode = .aspectFit
      skScene.backgroundColor = SKColor.clear
      view.isAsynchronous = true
      view.presentScene(skScene)
      view.ignoresSiblingOrder = true
      view.shouldCullNonVisibleNodes = true
    }
    
    
    horNode = SKShapeNode(rectOf: CGSize(width: Globalwidth, height: Globalheight))
    horNode.alpha = CGFloat(Float(160) / Float(255))
    horNode.fillColor = UIColor.gray
    horNode.strokeColor = UIColor.clear
    horNode.zPosition = 1
    horNode.blendMode = SKBlendMode.replace
    skScene.addChild(horNode)
    
    horLine = SKShapeNode()
    horLine.zPosition = 2
    
    let fontSizeText = GlobalstandardFontSize * Globalscale
    let fontSizeTextBigger = GlobalmediumFontSize * Globalscale
    
    horText = SKLabelNode(fontNamed: "Helvetica Bold")
    horText.isHidden = true
    horText.fontSize = CGFloat(fontSizeText)
    horText.horizontalAlignmentMode = .center
    horText.verticalAlignmentMode = .top
    horText.fontColor = UIColor.white
    horText.zPosition = 2
    
    skScene.addChild(horText)
    skScene.addChild(horLine)
    skScene.addChild(sunline.node)
    yearline.makeCleanLine()
    skScene.addChild(yearline.node)
    skScene.addChild(winterline.node)
    skScene.addChild(summerline.node)
    skScene.addChild(reverseSunline.node)
    
    for _ in 0 ... 6 {
      let compasslabel = SKLabelNode(fontNamed: "Helvetica Bold")
      compasslabel.fontSize = CGFloat(fontSizeText)
      compasslabel.horizontalAlignmentMode = .center
      compasslabel.zPosition = 3
      skScene.addChild(compasslabel)
      compassText.append(compasslabel)
    }

    sunSprite.isHidden = true
    skScene.addChild(sunSprite)
    
    sunTimeText1 = SKLabelNode(fontNamed: "Helvetica Bold")
    sunTimeText1.fontSize = CGFloat(fontSizeText)
    sunTimeText1.horizontalAlignmentMode = .center
    sunTimeText1.fontColor = UIColor.yellow
    sunTimeText1.isHidden = true
    
    sunTimeText2 = SKLabelNode(fontNamed: "Helvetica Bold")
    sunTimeText2.fontSize = CGFloat(fontSizeText)
    sunTimeText2.horizontalAlignmentMode = .center
    sunTimeText2.fontColor = UIColor.yellow
    sunTimeText2.isHidden = true
    skScene.addChild(sunTimeText1)
    skScene.addChild(sunTimeText2)
  
    skScene.addChild(drawmode.node)
    
    
    blewHorText = SKLabelNode(fontNamed: "Helvetica Bold")
    blewHorText.isHidden = true
    blewHorText.fontColor = UIColor.white
    blewHorText.fontSize = CGFloat(fontSizeText)
    blewHorText.zPosition = 5
    
    sunAppText = SKLabelNode(fontNamed: "Helvetica Bold")
    sunAppText.isHidden = true
    sunAppText.fontColor = UIColor.black
    sunAppText.fontSize = CGFloat(fontSizeTextBigger)
    sunAppText.horizontalAlignmentMode = .left
    sunAppText.verticalAlignmentMode = .top
    sunAppText.zPosition = 5
    
    screendetail1Text = SKLabelNode(fontNamed: "Helvetica Bold")
    screendetail1Text.isHidden = true
    screendetail1Text.fontColor = UIColor.black
    screendetail1Text.fontSize = CGFloat(fontSizeTextBigger)
    screendetail1Text.horizontalAlignmentMode = .left
    screendetail1Text.verticalAlignmentMode = .top
    screendetail1Text.zPosition = 5
    
    screendetail2Text = SKLabelNode(fontNamed: "Helvetica Bold")
    screendetail2Text.isHidden = true
    screendetail2Text.fontColor = UIColor.black
    screendetail2Text.fontSize = CGFloat(fontSizeTextBigger)
    screendetail2Text.horizontalAlignmentMode = .left
    screendetail2Text.verticalAlignmentMode = .top
    screendetail2Text.zPosition = 5
    
    screendetail3Text = SKLabelNode(fontNamed: "Helvetica Bold")
    screendetail3Text.isHidden = true
    screendetail3Text.fontColor = UIColor.black
    screendetail3Text.fontSize = CGFloat(fontSizeTextBigger)
    screendetail3Text.horizontalAlignmentMode = .left
    screendetail3Text.verticalAlignmentMode = .top
    screendetail3Text.zPosition = 5
    
    skScene.addChild(blewHorText)
    skScene.addChild(sunAppText)
    skScene.addChild(screendetail1Text)
    skScene.addChild(screendetail2Text)
    skScene.addChild(screendetail3Text)
    
    logoSprite.isHidden = true
    skScene.addChild(logoSprite)
    
    fiveRed.lineWidth = CGFloat(5)
    fiveRed.strokeColor = UIColor.red
    skScene.addChild(fiveRed)
    
    fiveOrange.lineWidth = CGFloat(5)
    fiveOrange.strokeColor = UIColor.orange
    skScene.addChild(fiveOrange)
    
    fiveYellow.lineWidth = CGFloat(5)
    fiveYellow.strokeColor = UIColor.yellow
    skScene.addChild(fiveYellow)
    
    twoWhite.lineWidth = CGFloat(2)
    twoWhite.strokeColor = UIColor.white
    twoWhite.zPosition = 3
    skScene.addChild(twoWhite)
    dBug("Canvas View Initialize Done")
  }
  
  func initBezierPath() {
    dBug("Canvas View initBezierPath")
    bezierPath = UIBezierPath()
    bezierPath.lineCapStyle = CGLineCap.round
    bezierPath.lineJoinStyle = CGLineJoin.round
  }
  
  
  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if (newWindow == nil) {
      
    } else {
    Analytics.logEvent(AnalyticsEventScreenView,
    parameters: [AnalyticsParameterScreenName: "AR View",
                 AnalyticsParameterScreenClass: "CanvasView"])
    }
  }
  
  
  func sceneAsImage() -> UIImage {
   //return sceneView.asImage()
   winterline.setShaderINV()
   summerline.setShaderINV()
   sunline.setShaderINV()
   let texture = sceneView.texture(from: skScene)
   let im = UIImage(cgImage: texture!.cgImage())
   winterline.resetShaderFromINV()
   summerline.resetShaderFromINV()
   sunline.resetShaderFromINV()
   return im
  }
  
  // Touch handling
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    dBug("Canvas View touchesBegan")
    let touch: AnyObject? = touches.first
    
    Globaltouching = true
    let point = touch!.location(in: self)
    touchLogic(touchEvent: TouchEvent.ACTION_DOWN,point: point)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    dBug("Canvas View touchesMoved")
    let touch: AnyObject? = touches.first
    
    let point = touch!.location(in: self)
    touchLogic(touchEvent: TouchEvent.ACTION_MOVE,point: point)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    dBug("Canvas View touchesEnded")
    let touch: AnyObject? = touches.first
    Globaltouching = false
    
    let point = touch!.location(in: self)
    touchLogic(touchEvent: TouchEvent.ACTION_UP,point: point)
  }
  func touchLogic(touchEvent: TouchEvent, point: CGPoint){
    dBug("Canvas View touchLogic")
    let XconvInt = Int(point.x) - Globalwidth/2
    let YconvInt = Globalheight/2 - Int(point.y)
    if(Globaldrawing && !Globalcalibrating){
      if(GlobalhasPremium){
        self.drawmode.handleDrawing(touchEvent: touchEvent, x: XconvInt, y: YconvInt)
      }
    }else{
      if(!Globalcalibrating){
        if(GlobalhasPremium){
         manipulateTheSun(touchEvent: touchEvent, x: XconvInt, y: YconvInt)
        }
      }else{
      handleManualCalibration(touchEvent: touchEvent, x: XconvInt, y: YconvInt)
      }
    }
  }
  
  
  func handleManualCalibration(touchEvent: TouchEvent, x: Int, y: Int){
    dBug("Canvas View handleManualCalibration")
    if(Globalcalibrating){
      if(touchEvent == TouchEvent.ACTION_UP){
        Globalcalibrating = false
        updateLines3DVectors()
      }
      saveAndResetAzimuthOffset()
      saveAndResetVerticalOffset()
      let sunAzimuth = convertToPolar(pointXY: Vector(Float(x), Float(y))).az()
      loadAzimuthOffset()
      var sunPos2D = Vector()
      if(convertToXY(fillArray: &sunPos2D, polar: getSunPos())){
        let interval = sqrt(Float(Globalheight * Globalwidth))/sqrt(1920 * 1080) * 400
        setVerticalOffset(offset: min(max((GlobalhorizonVector.y() * (sunPos2D.x() - Float(x)) + GlobalhorizonVector.x() * (sunPos2D.y() - Float(y))), -interval),interval))
        print(GlobalverticalOffset)
      }else{
        loadVerticalOffset()
      }
      
      
      setAzimuthOffset(offset: getSunPos().az() - sunAzimuth)
      }
    }
  
  func manipulateTheSun(touchEvent: TouchEvent, x: Int, y: Int){
    dBug("Canvas View manipulateTheSun")
    if(touchEvent == TouchEvent.ACTION_UP){
      endDragging()
      
      findClosestSun(x,y)
    }else{
      
      if(touchEvent == TouchEvent.ACTION_DOWN){
        onTouchPressed(x,y)
      } else if(touchEvent == TouchEvent.ACTION_MOVE){
        setDraggingMode(x,y)
      }
      
      //Drag along day line
      if(dragging == 1 && !GlobalmanualCalibration){
        dragAlongDayLine(x,y)
        //TODO: Reset time 2
      }
      
      //Drag along yearline
      /*
       if(dragging == 2 && !GlobalmanualCalibration){
       dragAlongYearLine(x,y)
       //TODO: Reset time 2
       }
       
       */
      
    }
    
  }
  
  
  func onTouchPressed(_ x: Int, _ y: Int){
    startX = x
    startY = y
    startEuler = convertToPolar(pointXY: Vector(Float(x),Float(y)))
    self.dragging = 0
    clickmillis = currentMillis()
  }
  
  func setDraggingMode(_ x: Int, _ y: Int){
    //Dragging the sun
    
    if(dragging == 0){
      let euler = convertToPolar(pointXY: Vector(Float(x),Float(y)))
      if(abs(startEuler.az() - euler.az()) > degToRad(2)){
        dragging = 1
      }
      
      //Drag along yearline
      if(false/*showYearline*/){
        if(abs(startEuler.zenith() - euler.zenith()) > 4){
          dragging = 2
        }
      }else{
        if(abs(startEuler.zenith() - euler.zenith()) > degToRad(2)){
          dragging = 1
        }
      }
    }
    
    if(dragging == 0 && currentMillis() - clickmillis > 400){
      dragging = 1
    }
    
    
  }
  
  func dragAlongDayLine(_ x: Int,_ y: Int){
    
    let euler = convertToPolar(pointXY: Vector(Float(x),Float(y)))
    
    let date = Date(timeIntervalSince1970: TimeInterval(usingMillis() / 1000))
    let cal = Calendar.current
    let day = cal.ordinality(of: .day, in: .year, for: date)
    
    
    
    let closest: Dual = findClosestSunByDate(day: day!, point: euler)
    
    
    let setmillis = sunline.startMillis + Int(1000 * 60 * 60 * Globalprecision) * closest.int
    
    updateTime(setmillis)
    
  }
  
  func endDragging(){
    if(dragging == 1 && !GlobalmanualCalibration){
      //   updateyearline()
    }
    
    if(dragging == 2 && !GlobalmanualCalibration){
      //TODO: anylineisFine = false
      //   updatedayline()
    }
    self.dragging = -1
  }
  
  func dayToMillis(day: Int) -> Int{
    dBug("Canvas View dayToMillis \(day)")
    let date = Date()
    let calendar = NSCalendar.current
    
    var dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
    
    // dateComponents.year = 2018
    dateComponent.month = 1
    dateComponent.hour = 1
    dateComponent.minute = 0
    dateComponent.second = 0
    dateComponent.day = day
    
    // Create date from components
    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: dateComponent)!.millisecondsSince1970
  }
  
  func findClosestSunByDate(day: Int, point: Polar) -> Dual{
    
    anydayline.setStartMillis(dayToMillis(day: day))
    //  anydayline.setStartMillis(newYearMillis + 1000 * 60 * 60 * 24 * day)
    
    
    let indexCount = Int(24 / Globalprecision)
    let startIndex = Int(indexCount / 2)
    var hmap = [Int : Float]()
    let returnDual = Dual()
    
    returnDual.int = findLowPeak(i: 0, j: indexCount - 1, index: startIndex, hmap: &hmap, point: point)
    
    
    if(returnDual.int != -1){
      returnDual.float = hmap[returnDual.int]!
    }
    
    return returnDual
  }
  
  func findLowPeak(i: Int, j: Int, index: Int, hmap: inout [Int : Float], point: Polar) -> Int{
    
    var mid: Float = -1
    
    let midIndex = (index + anydayline.size()) % anydayline.size()
    if(hmap[midIndex] != nil){
      mid = hmap[midIndex]!
    }else{
      mid = distanceBetweenEuler(from: point, to: anydayline.getPolar(index: midIndex))
      hmap[midIndex] = mid
    }
    
    var left: Float = -1
    let leftIndex = (max(index-1, i) + anydayline.size()) % anydayline.size()
    if(hmap[leftIndex] != nil){
      left = hmap[leftIndex]!
    }else{
      left = distanceBetweenEuler(from: point, to: anydayline.getPolar(index: leftIndex))
      hmap[leftIndex] = left
    }
    
    var right: Float = -1
    let rightIndex = (min(index+1, j) + anydayline.size()) % anydayline.size()
    if(hmap[rightIndex] != nil){
      right = hmap[rightIndex]!
    }else{
      right = distanceBetweenEuler(from: point, to: anydayline.getPolar(index: rightIndex))
      hmap[rightIndex] = right
    }
    
    /*  print("Any size \(index)")
     print("Left \(leftIndex), mid \(midIndex), right \(rightIndex)")
     print("Left \(left), mid \(mid), right \(right)")*/
    
    if(mid <= left && mid <= right){
      return index
    }else if(left > right){
      if((index + 1 + j) / 2 == index){
        return -1
      }
      return findLowPeak(i:min(index + 1, j), j: j, index: (index + 1 + j) / 2, hmap: &hmap, point: point)
    } else {
      if((index - 1 + i) / 2 == index){
        return -1
      }
      return findLowPeak(i: i, j: max(index + 1, i), index: (index - 1 + i) / 2, hmap: &hmap, point: point)
    }
    
  }
  
  
  func findClosestSun(_ x: Int, _ y: Int){
    let dX = abs(x - startX)
    let dY = abs(y - startY)
    
    let touchslop: Double = 10
    if(sqrt(pow(Double(dX), 2) + pow(Double(dY),2)) <= touchslop && currentMillis() - clickmillis <= 500 && !GlobalmanualCalibration){
      
      let euler = convertToPolar(pointXY: Vector(Float(x),Float(y)))
      
      
      //Touch above horizon
      if(euler.alt() >= 0){
    //    print("Start millis \(currentMillis() - Int(floor(Float(currentMillis()) / 1000)) * 1000)")
        
        let startMillis = currentMillis()
        
        //TODO: Reset time
        
        let rough_search_precision = 19
        
        //Rough search
        var closest_sun_day = [-1,-1]
        var index_of_day = [-1,-1]
        
        var closest_sun_distance = [Float.infinity,Float.infinity]
        
        var allclosest = [Dual]()
        
        var i = 0
        while(i <= 365){
          allclosest.append(findClosestSunByDate(day: i, point: euler))
          i+=rough_search_precision
        }
        
        
        var firstFound = false
        var secondFound = false
        
        for i in 0..<allclosest.count{
          let closest = allclosest[i]
          
          if(closest.float <= allclosest[((i + allclosest.count + 1) % allclosest.count)].float
            && closest.float <= allclosest[((i + allclosest.count - 1) % allclosest.count)].float){
            
            if(!firstFound){
              
              closest_sun_distance[0] = closest.float
              closest_sun_day[0] = i * rough_search_precision
              firstFound = true
            }else{
              
              closest_sun_distance[1] = closest.float
              closest_sun_day[1] = i * rough_search_precision
              secondFound = true
            }
          }
        }
        
        
     //   print("Mid millis \(currentMillis() - Int(floor(Float(currentMillis()) / 1000)) * 1000)")
        
        //fine search day 1
        closest_sun_distance = [Float.infinity,Float.infinity]
        
        
        var closest = Dual()
        var q: Int = Int()
        var closest_rough = closest_sun_day[0]
        
        for i in (closest_rough - (rough_search_precision / 2 - 1))...(closest_rough + (rough_search_precision / 2 + 1)){
          
          q = i % 365
          if(q < 0){
            q += 365
          }
          
          closest = findClosestSunByDate(day: i, point: euler)
          if(closest.float < closest_sun_distance[0]){
            closest_sun_distance[0] = closest.float
            closest_sun_day[0] = q
            index_of_day[0] = closest.int
          }
        }
        
        var setmillis = 0
        
        
        //fine search day 2
        if(secondFound){
          closest_sun_distance = [Float.infinity,Float.infinity]
          closest_rough = closest_sun_day[1]
          
          for i in (closest_rough - (rough_search_precision / 2 - 1))...(closest_rough + (rough_search_precision / 2 + 1)){
            
            q = i % 365
            if(q < 0){
              q += 365
            }
            
            closest = findClosestSunByDate(day: i, point: euler)
            if(closest.float < closest_sun_distance[1]){
              closest_sun_distance[1] = closest.float
              closest_sun_day[1] = q
              index_of_day[1] = closest.int
            }
          }
        }
        
        
        //Snap to summer or winterline
        if(abs(closest_sun_day[0] - 172) < 4){
          closest_sun_day[0] = 172
        }
        
        if(abs(closest_sun_day[0] - 355) < 4){
          closest_sun_day[0] = 355
        }

        setmillis = dayToMillis(day: closest_sun_day[0])
        setmillis = setmillis + Int(Globalprecision * 1000 * 60 * 60) * index_of_day[0]
        

        updateTime(setmillis)
        
        updateDayLine()
        
        
        if(secondFound){
          setmillis = dayToMillis(day: closest_sun_day[1])
          setmillis = setmillis + Int(Globalprecision * 1000 * 60 * 60) * index_of_day[1]
          updateTime2(setmillis)
          updateDayLine2()
        }
        
    //    print("End millis \(currentMillis() - Int(floor(Float(currentMillis()) / 1000)) * 1000)")
      }
      
    }
    
    
  }
  
  
  
  
  
  
  
  
  
  
  func beginStroke(point: CGPoint){
    lastPoint = point
    pointCounter = 0
  }
  
  func moveStroke(point: CGPoint){
    
    bezierPath.move(to: lastPoint)
    bezierPath.addLine(to: point)
    lastPoint = point
    
    pointCounter += 1
    
    if pointCounter == pointLimit {
      pointCounter = 0
      renderToImage()
      setNeedsDisplay()
      bezierPath.removeAllPoints()
    }
    else {
      setNeedsDisplay()
    }
  }
  
  
  
  
  override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    touchesEnded(touches!, with: event)
  }
  
  
  func renderToImage() {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
    if preRenderImage != nil {
      preRenderImage.draw(in: self.bounds)
    }
    
    bezierPath.lineWidth = GloballineWidth
    drawColor.setFill()
    drawColor.setStroke()
    
    bezierPath.stroke()
    
    preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
  }
  
  
  override func draw(_ rect: CGRect){
    dBug("Canvas View Draw()")
    if(GlobalreadyToDraw){
      CanvasView.performdraw(rect: rect, canvasView: self)
    }
  }
  
  
  
  class func performdraw(rect: CGRect, canvasView: CanvasView){
    dBug("Canvas View Performdraw()")
    let context = UIGraphicsGetCurrentContext()
    
    //Cant draw while calculating
    while(canvasView.calculating){
      usleep(100)
    }
    dBug("Canvas View Performdraw()2")
    canvasView.drawing = true
    
    start()
    let begin = debugStart
    
    
    if(!Globalcalibrating){
    
    if(!GlobalcloseToWinter){
      canvasView.drawTimeLabels(sunline: winterline, reverse: false)
      canvasView.drawSunriseSunsetLabel(sunline: winterline)
    }else{
     winterline.hideTextNodes()
    }
    if(!GlobalreallycloseToWinter){
      winterline.updateNodes(Gcontext: context)
    }else{
      winterline.hideLineNodes()
    }
      
    if(!GlobalcloseToSummer){
      
      canvasView.drawTimeLabels(sunline: summerline, reverse: false)
      
      canvasView.drawSunriseSunsetLabel(sunline: summerline)
    }else{
      summerline.hideTextNodes()
    }
    if(!GlobalreallycloseToSummer){
      summerline.updateNodes(Gcontext: context)
    }else{
      summerline.hideLineNodes()
    }
    
    sunline.drawColor.setStroke()
    sunline.updateNodes(Gcontext: context)
    canvasView.drawTimeLabels(sunline: sunline, reverse: false)
    canvasView.drawSunriseSunsetLabel(sunline: sunline)
    
    if(Globalshowbothtimes){
      // reverseSunline.snapLabelsToOtherLine(sunline: sunline)
      canvasView.drawTimeLabels(sunline: reverseSunline, reverse: true)
    }else{
      reverseSunline.hideTextNodes()
    }
      
    if(GlobalshowYearline){
      yearline.updateNodes(Gcontext: context)
    }else{
      yearline.hideLineNodes()
    }
    printDebugTime("lines")
    
    start()
    //Draw drawmode

    canvasView.drawmode.context = context
    
    canvasView.drawmode.drawDrawing(canvasView)
    

    printDebugTime("Drawmode")
    
    }else {
      sunline.hideLineNodes()
      winterline.hideLineNodes()
      summerline.hideLineNodes()
      yearline.hideLineNodes()
      
      sunline.hideTextNodes()
      winterline.hideTextNodes()
      summerline.hideTextNodes()
    }
      
    start()
    var sunWidth:Float = 40
    if(Globalcalibrating && Globaltouching){
      sunWidth = 60
    }
    
    canvasView.sunSprite.isHidden = true
    canvasView.sunTimeText1.isHidden = true
    canvasView.sunTimeText2.isHidden = true
    
    if(canvasView.couldFindsunPos && GlobalsunPos.alt() > -degToRad(2)){
      let pos = canvasView.sunPos!
      canvasView.sunSprite.position = pos.toCGPoint()
      canvasView.sunSprite.scale(to: CGSize(width: Double(sunWidth * Globalscale), height: Double(sunWidth * Globalscale)))
      canvasView.sunSprite.isHidden = false
      
      if(GlobalsunPos.alt() > degToRad(2)){
        
        if(!Globalcalibrating){
        canvasView.sunTimeText1.isHidden = false
        canvasView.sunTimeText1.text = Globaltime1
        canvasView.sunTimeText1.position = CGPoint(x: Double(pos.x() - cos(pos.z()) * 30 * Globalscale),
                                                   y: Double(pos.y() - sin(pos.z()) * 30 * Globalscale))
        canvasView.sunTimeText1.zRotation = CGFloat(pos.z() + Float.pi / 2)
        
        if(Globalshowbothtimes){
          canvasView.sunTimeText2.isHidden = false
          canvasView.sunTimeText2.text = Globaltime2
          canvasView.sunTimeText2.position = CGPoint(x: Double(pos.x() - cos(pos.z()) * -42 * Globalscale),
                                                     y: Double(pos.y() - sin(pos.z()) * -42 * Globalscale))
          canvasView.sunTimeText2.zRotation = CGFloat(pos.z() + Float.pi / 2)
          
          }
        }
      }
    }
    
    printDebugTime("Sun")
    
    start()
   
    if(canvasView.showHorizonLine && Globalalt > -degToRad(45)){
     // canvasView.horizonColor.setStroke()
     // canvasView.horizonLine.stroke()
      canvasView.horLine.isHidden = false
      canvasView.horLine.path = canvasView.horizonLine.cgPath
      canvasView.horLine.lineWidth = canvasView.horizonLine.lineWidth
      canvasView.horLine.strokeColor = canvasView.horizonColor
    }else{
      canvasView.horLine.isHidden = true
    }
    
    canvasView.horNode.path = canvasView.drawHorizonAreaPath.cgPath
    

    canvasView.drawHorizonText()

    canvasView.blewHorText.isHidden = true
    if(Globalalt < -degToRad(35)){
      var angle:Float = 0
      if(Globalorientation == Orientation.LANDSCAPE){
        angle = -Float.pi / 2
      }
      canvasView.blewHorText.isHidden = false
      canvasView.blewHorText.text = (Gb?.localizedString(forKey: "below_horizon", value: nil, table: nil))!
      canvasView.blewHorText.position = CGPoint(x: 0,y: 0)
      canvasView.blewHorText.zRotation = CGFloat(angle)
      
    }
    
    printDebugTime("Horizon")
    
    
    canvasView.sunAppText.isHidden = true
    canvasView.screendetail1Text.isHidden = true
    canvasView.screendetail2Text.isHidden = true
    canvasView.screendetail3Text.isHidden = true
    canvasView.logoSprite.isHidden = true
    
    start()
    if(showMediaView()){
      var startX = 12 * Globalscale - Float(Globalwidth / 2)
      var startY = Float(Globalheight / 2) - 12 * Globalscale
      let increment = -(GlobalmediumFontSize + 6) * Globalscale
      var angle:Float = 0
      if(Globalorientation == Orientation.LANDSCAPE){
        angle = -Float.pi / 2
        startY = Float(Globalheight / 2) - 12 * Globalscale
        startX = Float(Globalwidth / 2) - 12 * Globalscale
        }
      var y = startY
      var x = startX
      
      canvasView.logoSprite.isHidden = false
      if(Globalorientation == Orientation.LANDSCAPE){
       canvasView.logoSprite.position = CGPoint(x: Double(x - GlobalmediumFontSize * Globalscale / 2), y: Double(y - GlobalmediumFontSize * Globalscale / 2))
      }else{
       canvasView.logoSprite.position = CGPoint(x: Double(x + GlobalmediumFontSize * Globalscale / 2), y: Double(y - GlobalmediumFontSize * Globalscale / 2))
      }
      
      canvasView.logoSprite.scale(to: CGSize(width: Double(GlobalmediumFontSize * Globalscale), height: Double(GlobalmediumFontSize * Globalscale)))
      canvasView.logoSprite.zRotation = CGFloat(angle)

      
      var titleXOffset:Float = 0
      var titleYOffset:Float = 0
      if(Globalorientation == Orientation.PORTRAIT){
        titleXOffset = Float((GlobalmediumFontSize * Globalscale)) * 1.1
      }
      if(Globalorientation == Orientation.LANDSCAPE){
        titleYOffset = -Float((GlobalmediumFontSize * Globalscale)) * 1.1
      }
      
      canvasView.sunAppText.text = "Sun App"
      canvasView.sunAppText.isHidden = false
      canvasView.sunAppText.position = CGPoint(x: Double(x + titleXOffset),
                                               y: Double(y + titleYOffset))
      canvasView.sunAppText.zRotation = CGFloat(angle)
      
      if(Globalorientation == Orientation.PORTRAIT){
        y += increment
      }
      if(Globalorientation == Orientation.LANDSCAPE){
        x += increment
      }
      
      if(Globalcity != ""){
        
        var useText = Globalcity
        if(GlobalshortAddress != ""){
          useText = GlobalshortAddress
        }
        
        canvasView.screendetail1Text.text = useText
        canvasView.screendetail1Text.isHidden = false
        canvasView.screendetail1Text.position = CGPoint(x: Double(x),
                                                 y: Double(y))
        canvasView.screendetail1Text.zRotation = CGFloat(angle)

        if(Globalorientation == Orientation.PORTRAIT){
          y += increment
        }
        if(Globalorientation == Orientation.LANDSCAPE){
          x += increment
        }
      }
      var thisLabel = GlobalscreenshotTime1
      if(Globaldrawing){
        thisLabel = (Globaltoolbar?.label1Text)!
      }
      
      canvasView.screendetail2Text.text = thisLabel
      canvasView.screendetail2Text.isHidden = false
      canvasView.screendetail2Text.position = CGPoint(x: Double(x),
                                                      y: Double(y))
      canvasView.screendetail2Text.zRotation = CGFloat(angle)

      if(Globalorientation == Orientation.PORTRAIT){
        y += increment
      }
      if(Globalorientation == Orientation.LANDSCAPE){
        x += increment
      }
      if(Globalshowbothtimes){
        
        canvasView.screendetail3Text.text = GlobalscreenshotTime2
        canvasView.screendetail3Text.isHidden = false
        canvasView.screendetail3Text.position = CGPoint(x: Double(x),
                                                        y: Double(y))
        canvasView.screendetail3Text.zRotation = CGFloat(angle)

      }
    }
    printDebugTime("Media view")
    
    start()
    canvasView.drawCompass()
    printDebugTime("Compass")
 
    start()
    canvasView.twoWhite.path = canvasView.twoWhitePath.cgPath
    canvasView.fiveRed.path = canvasView.fiveRedPath.cgPath
    canvasView.fiveYellow.path = canvasView.fiveYellowPath.cgPath
    canvasView.fiveOrange.path = canvasView.fiveOrangePath.cgPath
    printDebugTime("Drawline")
    
    canvasView.drawing = false
    
    if(GlobaldebugSpeed){
      let end = DispatchTime.now()
      let nanoTime = end.uptimeNanoseconds - (begin?.uptimeNanoseconds)!
      print("Total \(nanoTime / 10000)")
    }
    // return image
    dBug("Canvas View Performdraw()3")
  }
  
  func drawSunriseSunsetLabel(sunline: Sunline){
    sunline.sunriseText.isHidden = true
    sunline.sunsetText.isHidden = true
    var usePath = fiveYellowPath
    switch sunline.getColor(){
    case UIColor.red:
      usePath = fiveRedPath
      break
    case UIColor.orange:
      usePath = fiveOrangePath
      break
    default:
      usePath = fiveYellowPath
    }
    if(sunline.sunriseExist){
      
      let dist: Float = 40
      
      var angle = -GlobalhorizonAngle - Float.pi / 4
      
      var to = Vector(sunline.sunriseLabel.x() + cos(angle) * dist * Globalscale * 0.56,sunline.sunriseLabel.y() - sin(angle) * dist * Globalscale * 0.56)
      if(to.inView() && sunline.sunriseInView){

        drawLine(from: sunline.sunriseLabel,
                 to: to,
                 path: usePath)
        
        sunline.sunriseText.text = sunline.sunriseLabel.payloadString
        sunline.sunriseText.isHidden = false
        sunline.sunriseText.position = CGPoint(x: Double(sunline.sunriseLabel.x() + cos(angle) * (dist * Globalscale)),
                                               y: Double(sunline.sunriseLabel.y() - sin(angle) * (dist * Globalscale)))
        sunline.sunriseText.zRotation = CGFloat(-angle - Float.pi / 2)
        
      }
      
      angle = -GlobalhorizonAngle + Float.pi / 4
      to = Vector(sunline.sunsetLabel.x() + cos(angle) * dist * Globalscale * 0.56,sunline.sunsetLabel.y() - sin(angle) * dist * Globalscale * 0.56)
      if(to.inView() && sunline.sunsetInView){
        drawLine(from: sunline.sunsetLabel,
                 to: to,
                 path: usePath)
        
        sunline.sunsetText.text = sunline.sunsetLabel.payloadString
        sunline.sunsetText.isHidden = false
        sunline.sunsetText.position = CGPoint(x: Double(sunline.sunsetLabel.x() + cos(angle) * (dist * Globalscale)),
                                              y: Double(sunline.sunsetLabel.y() - sin(angle) * (dist * Globalscale)))
        sunline.sunsetText.zRotation = CGFloat(-angle - Float.pi / 2)
        
      }
    }
  }
  
  func drawTimeLabels(sunline: Sunline, reverse: Bool){
    var dist: Float = 28 * Globalscale
    var removetextDist: Float = 0
    if(reverse){
      dist = -dist
      removetextDist = -13 * Globalscale
    }
    
    let col = sunline.getColor()
    
    var i = 0
    for timetext in sunline.timeText{
      timetext.isHidden = true
    }
    
    var usePath = fiveYellowPath
    switch sunline.getColor(){
    case UIColor.red:
      usePath = fiveRedPath
      break
    case UIColor.orange:
      usePath = fiveOrangePath
      break
    default:
      usePath = fiveYellowPath
    }
    
    for timelabel in sunline.timeLabels{
      let to = Vector(timelabel.x() - cos(timelabel.z()) * dist * 0.47,timelabel.y() - sin(timelabel.z()) * dist * 0.47)

      if(to.inView()){
        drawLine(from: timelabel,to: to ,path: usePath)
 
       
      sunline.timeText[i].text = timelabel.payloadString
      sunline.timeText[i].isHidden = false
      sunline.timeText[i].position = CGPoint(x: Double(timelabel.x() - cos(timelabel.z()) * (dist - removetextDist)),
                                             y: Double(timelabel.y() - sin(timelabel.z()) * (dist - removetextDist)))
      sunline.timeText[i].zRotation = CGFloat(timelabel.z() + Float.pi / 2)
      i = i + 1
      }
    }
    
  }
  
  func drawHorizonText(){
    horText.isHidden = true
    if(canDrawHorizonText){
      horText.isHidden = false
      let string = (Gb?.localizedString(forKey: "horizon", value: nil, table: nil))!
      let hoverDist =  Float(GlobalstandardFontSize) * 1.6 * Globalscale
      let hoverVector = Vector(-GlobalhorizonVector.y() * hoverDist,GlobalhorizonVector.x() * hoverDist)
      
      horText.text = string
      horText.position = CGPoint(x: Double(horizonAnchor.x() - hoverVector.x()), y: Double(horizonAnchor.y() - hoverVector.y()))
      horText.zRotation = CGFloat(GlobalhorizonAngle - Float.pi / 2)
      //print("\(horText.position.x) , \(horText.position.y)")
    }
  }
  
  
  var lastLineWidth: Float = -1
  func drawLine(from: Vector, to: Vector, path: UIBezierPath?){
    if(from.inView() || to.inView()){
      path?.move(to: from.toCGPoint())
      path?.addLine(to: to.toCGPoint())
      //drawLineFunctionPath.stroke()

    }
  }
  
  
  //On Draw defines things to draw for the draw method
  //If a function is called draw then it will draw directly
  func onDraw(_ bypass: Bool){
    dBug("Canvas onDraw()")
    //Update sun pos
    updateSun(usingMillis())
    
    //Cant calculate while drawing
    while(calculating || drawing){
      usleep(100)
    }
    dBug("Canvas onDraw()2")
    //var begin = DispatchTime.now()
    
    
    calculating = true
    clear()
    
    //Draw sun
    self.couldFindsunPos = false
    var pos = Vector()
    var posPlus = Vector()
    if(point3DToXY(fillArray: &pos, point3D: getSunPos3D()) && point3DToXY(fillArray: &posPlus, point3D: getSunPos3DPlus())){
      //The Z coordinate gets to hold the perpendicular direction of the suns movement
      var angle = pos.angleTo(to: posPlus) - Float.pi / 2
      if(southernMode()){
        angle += Float.pi
      }
      self.sunPos = pos
      self.sunPos.setZ(angle)
      
      self.couldFindsunPos = true
      // print("Pos \(pos[0]), \(pos[1])")
    }
    
    
    //var start = DispatchTime.now()
    if(GlobalshowYearline){
      yearline.updatePath()
    }
    
    if(!GlobalreallycloseToSummer){
      summerline.updatePath()
    }
    if(!GlobalcloseToSummer){
      summerline.updateLabelText(text: GlobalsolsticeLabel)
    }
    
    if(!GlobalreallycloseToWinter){
      winterline.updatePath()
    }
    if(!GlobalcloseToWinter){
      winterline.updateLabelText(text: GlobalsolticeLabel)
    }
    
    sunline.updatePath()
    sunline.updateLabelText(text: GlobaltodayLabel)
    
    if(Globalshowbothtimes){
      reverseSunline.getPath()
      reverseSunline.updateLabelText(text: GlobalreverseLabel)
    }
    
    //  var end = DispatchTime.now()
    //  var nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    // print("Get paths \(nanoTime / 1000000)")
    
    
    onDrawHorizon()
    if(!bypass){
      OperationQueue.main.addOperation {
        self.setNeedsDisplay()
        Globaltoolbar?.updateLabel1FromMillis(usingMillis())
      }
    }
    calculating = false
    /*    end = DispatchTime.now()
     nanoTime = end.uptimeNanoseconds - begin.uptimeNanoseconds
     print("onDraw \(nanoTime / 1000000)")*/
    dBug("Canvas onDraw()3")
  }
  
  func onDrawHorizon(){
    dBug("Canvas onDrawHorizon()")
    showHorizonLine = false
    //Find horizon function
    var base = Vector()
    if(convertToXY(fillArray: &base, polar: Polar(altitude: 0,azimuth: Globalheading))){
      //Find horizon/edge intersection points
      horizonPoints = 0
      canDrawHorizonText = false
      var point1 = Vector()
      var point2 = Vector()
      
      let xBound = Vector(Float(-Globalwidth / 2 - 5),Float(Globalwidth / 2 + 5))
      let yBound = Vector(Float(-Globalheight / 2 - 5),Float(Globalheight / 2 + 5))
      
      //Left edge
      var t = (xBound.x() - base.x()) / GlobalhorizonVector.x()
      var y = GlobalhorizonVector.y() * t + base.y()
      if(y >= yBound.x() && y <= yBound.y()){
        point1 = Vector(xBound.x(),y)
        if(t > 0){
          self.horizonAnchor = Vector(xBound.x(),y)
        }
        horizonPoints += 1
      }
      

      //Top edge
      t = (yBound.x() - base.y()) / GlobalhorizonVector.y()
      var x = GlobalhorizonVector.x() * t + base.x()
      if(x >= xBound.x() && x <= xBound.y()){
        if(horizonPoints == 0){
          point1 = Vector(x,yBound.x())
        }
        if(horizonPoints == 1){
          point2 = Vector(x,yBound.x())
        }
        if(t > 0){
          self.horizonAnchor = Vector(x,yBound.x())
        }
        horizonPoints += 1
      }
      
      //Right edge
      t = (xBound.y() - base.x()) / GlobalhorizonVector.x()
      y = GlobalhorizonVector.y() * t + base.y()
      if(y >= yBound.x() && y <= yBound.y()){
        if(horizonPoints == 0){
          point1 = Vector(xBound.y(),y)
        }
        if(horizonPoints == 1){
          point2 = Vector(xBound.y(),y)
        }
        if(t > 0){
          self.horizonAnchor = Vector(xBound.y(),y)
        }
        horizonPoints += 1
      }
      
      
      
      //Bottom edge
      t = (yBound.y() - base.y()) / GlobalhorizonVector.y()
      x = GlobalhorizonVector.x() * t + base.x()
      if(x >= xBound.x() && x <= xBound.y()){
        if(horizonPoints == 0){
          point1 = Vector(x,yBound.y())
        }
        if(horizonPoints == 1){
          point2 = Vector(x,yBound.y())
        }
        if(t > 0){
          self.horizonAnchor = Vector(x,yBound.y())
        }
        horizonPoints += 1
      }
      
      
      drawHorizonAreaPath.removeAllPoints()
      if(horizonPoints >= 2){
        //Two intersection points, so we can draw line
        horizonLine = getLinePath(point1: point1, point2: point2)
        showHorizonLine = true
        
   
        canDrawHorizonText = true
        var count = 0
        while(!self.horizonAnchor.inBoundary()){
          
          self.horizonAnchor.move(dir: GlobalhorizonVector,dist: -0.5)
          count += 1
          if(count > Globalwidth){
            canDrawHorizonText = false
            break
          }
        }
        
        let topLeftXY = Vector(xBound.x(),yBound.y())
        let topRightXY = Vector(xBound.y(),yBound.y())
        let bottomLeftXY = Vector(xBound.x(),yBound.x())
        let bottomRightXY = Vector(xBound.y(),yBound.x())
        
        let topLeft = convertToPolar(pointXY: topLeftXY).alt() > 0
        let topRight = convertToPolar(pointXY: topRightXY).alt() > 0
        let bottomLeft = convertToPolar(pointXY: bottomLeftXY).alt() > 0
        let bottomRight = convertToPolar(pointXY: bottomRightXY).alt() > 0
        
        
        
        if(topLeft && !topRight){
          drawHorizonAreaPath.move(to: topRightXY.toCGPoint())

          if(!bottomRight){
            drawHorizonAreaPath.addLine(to: bottomRightXY.toCGPoint())
          }
          if(!bottomLeft){
            drawHorizonAreaPath.addLine(to: bottomLeftXY.toCGPoint())
          }
          drawHorizonAreaPath.addLine(to: point1.toCGPoint())
          drawHorizonAreaPath.addLine(to: point2.toCGPoint())
          
        }else if(topRight && !bottomRight){
          drawHorizonAreaPath.move(to: bottomRightXY.toCGPoint())
          if(!bottomLeft){
            drawHorizonAreaPath.addLine(to: bottomLeftXY.toCGPoint())
          }
          if(!topLeft){
            drawHorizonAreaPath.addLine(to: topLeftXY.toCGPoint())
            drawHorizonAreaPath.addLine(to: point2.toCGPoint())
            drawHorizonAreaPath.addLine(to: point1.toCGPoint())
          }else{
            drawHorizonAreaPath.addLine(to: point1.toCGPoint())
            drawHorizonAreaPath.addLine(to: point2.toCGPoint())
          }
        }else if(bottomRight && !bottomLeft){
          drawHorizonAreaPath.move(to: bottomLeftXY.toCGPoint())
          if(!topLeft){
            drawHorizonAreaPath.addLine(to: topLeftXY.toCGPoint())
          }
          if(!topRight){
            drawHorizonAreaPath.addLine(to: topRightXY.toCGPoint())
          }
          drawHorizonAreaPath.addLine(to: point2.toCGPoint())
          drawHorizonAreaPath.addLine(to: point1.toCGPoint())
        }else if(bottomLeft && !topLeft){
          drawHorizonAreaPath.move(to: topLeftXY.toCGPoint())
          if(!topRight){
            drawHorizonAreaPath.addLine(to: topRightXY.toCGPoint())
          }
          if(!bottomRight){
            drawHorizonAreaPath.addLine(to: bottomRightXY.toCGPoint())
          }
          drawHorizonAreaPath.addLine(to: point2.toCGPoint())
          drawHorizonAreaPath.addLine(to: point1.toCGPoint())
        }
        
      }else{
        if(convertToPolar(pointXY: Vector(0,0)).alt() < 0){
          drawHorizonAreaPath.move(to: CGPoint(x: xBound.xI(), y: yBound.yI()))
          drawHorizonAreaPath.addLine(to: CGPoint(x: xBound.yI(), y: yBound.yI()))
          drawHorizonAreaPath.addLine(to: CGPoint(x: xBound.yI(), y: yBound.xI()))
          drawHorizonAreaPath.addLine(to: CGPoint(x: xBound.xI(), y: yBound.xI()))
        }
      }
    }
  }
  
  var heading : Float = 0
  func drawCompass(){
    dBug("Canvas drawCompass()")
    let az = Globalheading
    if(az >= 0){
      heading = az
    }
    
    let FOV_X = Float(FOV_Y * Double(Globalwidth) /  Double(Globalheight))
    var leftHeading = heading - FOV_X / 2
    var rightHeading = heading + FOV_X / 2
    
    if(Globalorientation == Orientation.LANDSCAPE){
      leftHeading = heading - Float(FOV_Y) / 2
      rightHeading = heading + Float(FOV_Y) / 2
    }
    
    let FOV = subtractAZ(rightHeading, leftHeading) * 180 / Float.pi
    

    
    var interval = Float(Globalwidth) / FOV
    if(Globalorientation == Orientation.LANDSCAPE){
     interval = Float(Globalheight) / FOV
    }
    var headingscan = leftHeading
    var pointX : Double = 0
    
    var smallestPointY = Double(Float(Globalheight) * 0.99)
    var mediumPointY = Double(Float(Globalheight) * 0.985)
    var largePointY = Double(Float(Globalheight) * 0.98)
    var textPointY = Double(Float(Globalheight) * 0.975)
    if(Globalorientation == Orientation.LANDSCAPE){
      smallestPointY = Double(Globalheight) - smallestPointY
      mediumPointY = Double(Globalheight) - mediumPointY
      largePointY = Double(Globalheight) - largePointY
      textPointY = Double(Globalheight) - textPointY
    }
    
    
    let height = Double(Globalheight)
    var pointY = smallestPointY
    
    var yOffset: Double = Double(GlobalbuttonOffsetBottom + GlobalbuttonHeight + 4)
    if(Globaltakingscreenshot/* || !GlobalhasPremium*/){
      yOffset = 0
    }
    UIColor.white.setStroke()
    
    var textIndex = 0
    for compasslabel in compassText{
      compasslabel?.isHidden = true
    }
    for i in 0 ... Int(ceil(FOV)) {
      headingscan = round(addAZ(leftHeading,Float(i) / 180 * Float.pi) * 180 / Float.pi)
      if(headingscan >= 360){
        headingscan -= 360
      }
      pointX = Double(Float(i) * interval)
      pointY = smallestPointY
      
      if(headingscan.truncatingRemainder(dividingBy: 5) == 0){
        pointY = mediumPointY
      }
      if(headingscan.truncatingRemainder(dividingBy: 15) == 0){
        pointY = largePointY
        
        var string = "\(Int(headingscan))"
        if(headingscan < 0){
          string = "\(Int(headingscan + 360))"
        }
        if(headingscan == 0){
          string = (Gb?.localizedString(forKey: "north", value: nil, table: nil))!
        }
        
        if(headingscan == 45){
          string = (Gb?.localizedString(forKey: "ne", value: nil, table: nil))!
        }
        
        if(headingscan == 90){
          string = (Gb?.localizedString(forKey: "east", value: nil, table: nil))!
        }
        
        if(headingscan == 135){
          string = (Gb?.localizedString(forKey: "se", value: nil, table: nil))!
        }
        
        if(headingscan == 180){
          string = (Gb?.localizedString(forKey: "south", value: nil, table: nil))!
        }
        
        if(headingscan == 225){
          string = (Gb?.localizedString(forKey: "sw", value: nil, table: nil))!
        }
        
        if(headingscan == 270){
          string = (Gb?.localizedString(forKey: "west", value: nil, table: nil))!
        }
        
        if(headingscan == 315){
          string = (Gb?.localizedString(forKey: "nw", value: nil, table: nil))!
        }
        if(Globalorientation == Orientation.PORTRAIT){
          compassText[textIndex]?.isHidden = false
          compassText[textIndex]?.text = string
          compassText[textIndex]?.position = CGPoint(x: pointX - Double(Globalwidth) / 2,y: -Double(Globalheight) / 2 + (Double(Globalheight) - textPointY) + yOffset)
          compassText[textIndex]?.zRotation = 0
        }
        if(Globalorientation == Orientation.LANDSCAPE){
          compassText[textIndex]?.isHidden = false
          compassText[textIndex]?.text = string
          compassText[textIndex]?.position = CGPoint(x: textPointY - Double(Globalwidth / 2),y:Double(Globalheight / 2) - pointX)
          compassText[textIndex]?.zRotation = CGFloat(-Float.pi / 2)
        }
        textIndex += 1
      }
      if(Globalorientation == Orientation.PORTRAIT){
        drawLine(from: Vector(Float(pointX - Double(Globalwidth) / 2),Float(-height / 2 + yOffset + (height - pointY))), to: Vector(Float(pointX - Double(Globalwidth) / 2),Float(-height / 2 + yOffset)), path: twoWhitePath)
      }
      if(Globalorientation == Orientation.LANDSCAPE){
      drawLine(from: Vector(Float(pointY) - Float(Globalwidth / 2),Float(Globalheight / 2) - Float(pointX)), to: Vector(Float(-Globalwidth / 2),Float(Globalheight / 2) - Float(pointX)), path: twoWhitePath)
      }
    }
  }
  
  public func getLinePath(point1: Vector, point2: Vector) -> UIBezierPath {
    let linePath = UIBezierPath()
    linePath.move(to: CGPoint(x: Double(point1.x()),y: Double(point1.y())))
    linePath.addLine(to: CGPoint(x: Double(point2.x()),y: Double(point2.y())))
    linePath.lineWidth = GloballineWidth * CGFloat(Globalscale)
    return linePath
  }
  
  
  func clear() {
    dBug("Canvas clear()")
    preRenderImage = nil
    bezierPath?.removeAllPoints()
    fiveRedPath?.removeAllPoints()
    fiveYellowPath?.removeAllPoints()
    fiveOrangePath?.removeAllPoints()
    twoWhitePath?.removeAllPoints()
  }
  
  // MARK: - Other
  
  func hasLines() -> Bool {
    return preRenderImage != nil || !bezierPath.isEmpty
  }
  
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
