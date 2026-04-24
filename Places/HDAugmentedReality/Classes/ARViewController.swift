import UIKit
import AVFoundation
import CoreLocation
import CoreMotion
import GLKit
import ReplayKit
import MapKit
import PopMenu
import Firebase

class ARViewController: UIViewController, AVCapturePhotoCaptureDelegate, RPPreviewViewControllerDelegate
{
    /// Orientation mask for view controller. Make sure orientations are enabled in project settings also.
    open var interfaceOrientationMask: UIInterfaceOrientationMask = UIInterfaceOrientationMask.all

    open var menuButtonImage: UIImage?
    {
        didSet
        {
            GlobalmenuButton?.setImage(self.menuButtonImage, for: UIControl.State())
        }
    }

    //===== Private
    fileprivate var initialized: Bool = false
  
    fileprivate var cameraSession: AVCaptureSession = AVCaptureSession()

    fileprivate var canvasView: CanvasView? = nil
    fileprivate var mapView: MapView!
    fileprivate var cameraLayer: AVCaptureVideoPreviewLayer?    // Will be set in init

    fileprivate var cameraOutput: AVCapturePhotoOutput!
  
    fileprivate var cameraOutputAdded = false
    fileprivate var previosRegion: Int = 0

    fileprivate var currentHeading: Double = 0
    fileprivate var lastLocation: CLLocation?
    fileprivate var didLayoutSubviews: Bool = false
  
    let languages = ["Dansk", "Deutsch", "English"]
    let language_code = ["da", "de", "en"]
    var pickerdata = 0 //language (1 is units)
  
    var motionManager:CMMotionManager?
    var rotationMatrix = GLKMatrix4()
    var projectionPerspectiveMatrix = GLKMatrix4()
    var rotatedProjectionMatrix = GLKMatrix4()

    //==========================================================================================================================================================
    //                                                        Init
    //==========================================================================================================================================================
    init()
    {
        super.init(nibName: nil, bundle: nil)
        dBug("ARVC init()")
        //self.initializeInternal()
    }
    
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        dBug("ARVC required public init?(coder aDecoder: NSCoder)")
        //self.initializeInternal()
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dBug("ARVC override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)")
        //self.initializeInternal()
        
    }

    internal func initializeInternal()
    {
        dBug("ARVC initializeInternal()")
        if self.initialized
        {
            dBug("ARVC initializeInternal() 1")
            return
        }
        dBug("ARVC initializeInternal() 2")
        self.initialized = true;
      
        

        Globalwidth = Int(self.view.bounds.width)
        Globalheight = Int(self.view.bounds.height)
        Globalscale = Float(sqrt(pow(Double(Globalwidth), 2) + pow(Double(Globalheight), 2)) / sqrt(pow(414, 2) + pow(736, 2)))
      
      //Setup perspective projection matrix
      let aspectRatio = Double(Globalheight) / Double(Globalwidth);
    
      
      let zNear = tan(FOV_Y)
      self.projectionPerspectiveMatrix = GLKMatrix4MakeFrustum(-1, 1, Float(-aspectRatio), Float(aspectRatio), Float(zNear), 2000)
      
      motionManager = CMMotionManager()
      motionManager?.deviceMotionUpdateInterval = 1.0 / FPS

//      motionManager.showsDeviceMovementDisplay = true
      dBug("Starting motion manager")
      //asyncQonDraw()
      let oq = OperationQueue.init()
      GlobalRequiredReadings = 10
        
      
      if ((CMMotionManager.availableAttitudeReferenceFrames().rawValue & CMAttitudeReferenceFrame.xTrueNorthZVertical.rawValue) == 0) {
        let alert = UIAlertController(title: lString("error"), message: "Accelerometer, Compass or Location not available", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lString("ok"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
      }else{
        motionManager?.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical,to: oq, withHandler: { (deviceMotion, error) -> Void in
          dBug("Motion Manager Response")
          if(error == nil && !Globalfrozen){
           dBug("SUCCESSFULL RESPONSE")
           dBug("Readings \(GlobalRequiredReadings)")
           GlobalmagAccAvailable = ((deviceMotion?.magneticField.accuracy) != nil)
            if(GlobalmagAccAvailable){
              if(GlobalRequiredReadings != 0){
                GlobalRequiredReadings-=1
              }
              let attitude = deviceMotion!.attitude
              let rot = attitude.rotationMatrix
              GlobalRotM11 = Float(rot.m11)
              GlobalRotM12 = Float(rot.m12)
              GlobalRotM13 = Float(rot.m13)
              
              GlobalRotM21 = Float(rot.m21)
              GlobalRotM22 = Float(rot.m22)
              GlobalRotM23 = Float(rot.m23)
              
              GlobalRotM31 = Float(rot.m31)
              GlobalRotM32 = Float(rot.m32)
              GlobalRotM33 = Float(rot.m33)
              GlobalmagAcc = Int(deviceMotion!.magneticField.accuracy.rawValue)
            }
          }else{
            dBug("Motion Manager Error \(error.debugDescription)")
          }
        })
      }
  }

  func mainLoop(){
      
      dBug("MLOOP")
      if(GlobalDebug && GlobalDebugLoopCount > 0){
        GlobalDebugLoopCount -= 1
        if(GlobalDebugLoopCount == 0){
          let alert = UIAlertController(title: "Done", message: "Debug experiment conducted, please restart the app and share the file on prompt. Thank you Björn!", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: lString("ok"), style: .cancel, handler: nil))
           self.present(alert, animated: true)
        }
      }
      if(GlobalmagAccAvailable){
        dBug("GlobalmagAccAvailable")
        let acc = GlobalmagAcc
        self.handleDeviceMotionUpdate()
        dBug("GlobalRequiredReadings \(GlobalRequiredReadings)")
        if(GlobalRequiredReadings == 0){
          dBug("GlobalreadyToStartDraw")
          GlobalreadyToStartDraw = true
        }
        
        let lastAcc = GlobalcompassAccuracy
        GlobalcompassAccuracy = Int(acc)
        dBug("GlobalcompassAccuracy \(GlobalcompassAccuracy)")
        
        if(GlobalCurrentView != 0){
          GlobalcalibrationWarningLabel.isHidden = true
        }else if(GlobalcompassAccuracy != lastAcc){
          GlobalcalibrationWarningLabel.isHidden = false
          GlobalcalibrationWarningLabel.text = "\((Gb?.localizedString(forKey: "compass_warning", value: nil, table: nil))!) \(getCompassReliabilityString())"
          if(GlobalcompassAccuracy == 2){
            GlobalcalibrationWarningLabel.isHidden = true
          }
          
          if(GlobalcalibrateViewController != nil){
            GlobalcalibrateViewController.updateAccuracy()
          }
        }
      }
    if (showMediaView()){
      GlobalcalibrationWarningLabel.isHidden = true
    }
    if(!Globalfrozen){
      if(updatePseudoOrientation()){
        if(mapView != nil){
          mapView.updateScreenOrientation()
        }
      }
      if(GlobalCurrentView == 0){
        if(!Globaltoolbar!.isHidden && showMediaView() && !Globaltakingscreenshot){
          dBug("Toolbarhide")
          Globaltoolbar?.hide(true)
        }else if(Globaltoolbar!.isHidden && !showMediaView()){
          dBug("Toolbarunhide")
          Globaltoolbar?.hide(false)
        }
      }else{
        dBug("Toolbarremain")
        Globaltoolbar?.hide(Globaltoolbar!.isHidden)
      }

      if(GlobalshowCalMSG && Globalcalibrating){
        dBug("Manual Calibration")
        let calMSG = UIAlertController(title: (Gb?.localizedString(forKey: "manual_calibration", value: nil, table: nil))!, message: (Gb?.localizedString(forKey: "drag_the_yellow_circle_onto_the_sun", value: nil, table: nil))!, preferredStyle: .alert)
        calMSG.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "ok", value: nil, table: nil), style: .default))
        
        GlobalshowCalMSG = false
        if(Globalorientation == Orientation.LANDSCAPE){
          calMSG.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        self.present(calMSG, animated: false)
      }
    }
    if(GlobalupdateCameraButton){
      updateCaptureButton()
      GlobalupdateCameraButton = false
    }
    if(GlobalupdateAllButtons){
      updateAllButtons()
      GlobalupdateAllButtons = false
    }
    if(GlobalupdateUnits){
      canvasView?.drawmode.updateBlock()
      GlobalupdateUnits = true
    }
  }
  
  func asyncQonDraw(){
    dBug("asyncQonDraw()")
    DispatchQueue.global(qos: .userInitiated).async{
      while(true){
   
        if(!GlobalArView){
          break
        }
        let start = DispatchTime.now()

        
        OperationQueue.main.addOperation {
          dBug("READINGS LEFT \(GlobalRequiredReadings)")
          if(GlobalreadyToStartDraw){
            self.canvasView?.onDraw(false)
            GlobalreadyToDraw = true
            dBug("GlobalreadyToDraw")
          }
          
           self.mainLoop()
        }
        
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let sleep = 1000000 / FPS - Double(nanoTime / 1000)
 //       self.changeFPS(Double(1000000000 / nanoTime))
        if(sleep > 0){
          usleep(UInt32(sleep))
        }
      }
    }
  }
  
  
  func changeFPS(_ val: Double){
    dBug("changeFPS \(val)")
    FPS = val
    if(GlobalisRecording && FPS > 30){
      FPS = 30
    }
    if(FPS > targetFPS){
      FPS = targetFPS
    }
    sceneView?.preferredFramesPerSecond = Int(FPS)
    motionManager?.deviceMotionUpdateInterval = 1.0 / FPS
  }
  
    func handleDeviceMotionUpdate(){
      dBug("handleDeviceMotionUpdate")
      let saveMatrix = GlobalprojectionMatrix
      
      self.rotationMatrix = GLKMatrix4RotateZ(GLKMatrix4Make(GlobalRotM11, GlobalRotM21, GlobalRotM31, 0,
                                                             GlobalRotM12, GlobalRotM22, GlobalRotM32, 0,
                                                             GlobalRotM13, GlobalRotM23, GlobalRotM33, 0,
                                                             0, 0, 0, 1), Float( -Double.pi / 2))
      setRotationMatrix(matrix: self.rotationMatrix)
      
      self.rotatedProjectionMatrix = GLKMatrix4Multiply(projectionPerspectiveMatrix,rotationMatrix)
      setProjectionMatrix(matrix: self.rotatedProjectionMatrix)
      dBug("Globalalt \(Globalalt)")
      if(Globalalt < -1.5){
        setProjectionMatrix(matrix: saveMatrix)
      }
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
      
        self.stopCamera()
      
    }
  
    open override func viewWillAppear(_ animated: Bool)
    {
      super.viewWillAppear(animated)
      dBug("ViewWillAppear")
      if(GlobalCurrentView == 0){
        onViewWillAppear()
      }
      
    }
    
    open override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        dBug("ViewDidAppear")
        if(GlobalCurrentView == 0){
          onViewDidAppear()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        dBug("ViewDiddisAppear")
        onViewDidDisappear()
    }
    
    open override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        dBug("ViewDidLayoutSubviews")
        //onViewDidLayoutSubviews()
    }
    
    fileprivate func onViewWillAppear()
    {
      // Camera layer if not added
        dBug("OnViewWillAppear")
        if self.cameraLayer?.superlayer == nil { self.loadCamera() }
        
        // Set orientation and start camera
        self.setOrientation(UIApplication.shared.statusBarOrientation)

        self.startCamera(notifyLocationFailure: true)
        if(!cameraOutputAdded){
        
        cameraOutput = AVCapturePhotoOutput()
        cameraSession.addOutput(cameraOutput)
          
        cameraOutputAdded = true
        dBug("CameraOutputAdded")
        }
    }
  
  
    fileprivate func onViewDidAppear()
    {
      dBug("OnViewDidAppear")
      onViewDidLayoutSubviews()
      self.layoutUi()
      self.initializeInternal()
      asyncQonDraw()
    }
    
    fileprivate func onViewDidDisappear()
    {
      // print("Stopped camera")
        //stopCamera()
    }
  
  
    @objc internal func menuButtonTap()
    {

      GlobalmenuActive = true
      let menuViewController = PopMenuViewController(sourceView: GlobalmenuButton, actions: [])
      
      if(GlobalCurrentView == 0){
        let mapAction = PopMenuDefaultAction(title: lString("mapview"), image: UIImage(named: "ic_map"), color: .blue)
        mapAction.font = UIFont(name: "SofiaPro-Bold", size: 22)!
        mapAction.view.tag = 0
        menuViewController.addAction(mapAction)
      }else if(GlobalCurrentView == 1){
        let mapAction = PopMenuDefaultAction(title: lString("augmentedreality"), image: UIImage(named: "ic_augmented_icon"), color: .blue)
        mapAction.view.tag = 7
        menuViewController.addAction(mapAction)
      }
      
      let dataAction = PopMenuDefaultAction(title: lString("data"), image: UIImage(named: "ic_sunset_white"))
      dataAction.view.tag = 1
      menuViewController.addAction(dataAction)
      
      if(canvasView != nil){
        let calibrateAction = PopMenuDefaultAction(title: lString("calibrate"), image: UIImage(named: "ic_cal_icon"))
        calibrateAction.view.tag = 2
        menuViewController.addAction(calibrateAction)
      }
      
      let settingsAction = PopMenuDefaultAction(title: lString("settings"), image: UIImage(named: "ic_gear"))
      settingsAction.view.tag = 3
      menuViewController.addAction(settingsAction)

      if(GlobalhasPremium && canvasView != nil){
        let analemmaAction = PopMenuDefaultAction(title: lString("analemma"), image: UIImage(named: "ic_yearline"))
        analemmaAction.view.tag = 4
        menuViewController.addAction(analemmaAction)
      }
      
      let helpAction = PopMenuDefaultAction(title: lString("help"), image: UIImage(named: "ic_help"))
      helpAction.view.tag = 5
      menuViewController.addAction(helpAction)

      if(!GlobalhasPremium){
        var premiumAction:PopMenuDefaultAction!
        if(GlobalhasPremium){
          premiumAction = PopMenuDefaultAction(title: lString("premium"), image: UIImage(named: "ic_star"))
        }else{
          premiumAction = PopMenuDefaultAction(title: lString("premium"), image: UIImage(named: "ic_star"), color: .purple)
        }
        premiumAction.font = UIFont(name: "SofiaPro-Bold", size: 22)!
        premiumAction.view.tag = 8
        menuViewController.addAction(premiumAction)
      }
      
      let cancelAction = PopMenuDefaultAction(title: lString("cancel"), image: UIImage(named: "ic_undo"), color: .red)
      cancelAction.view.tag = 6
      menuViewController.addAction(cancelAction)
      menuViewController.delegate = self
      
      menuViewController.appearance.popMenuFont = UIFont(name: "SofiaPro-Light", size: 18)!
      menuViewController.appearance.popMenuColor.backgroundColor = .solid(fill: .white)
      menuViewController.appearance.popMenuColor.actionColor = .tint(.darkGray)
      menuViewController.appearance.popMenuItemSeparator = .fill(.darkGray, height: 1)
      menuViewController.appearance.popMenuBackgroundStyle  = .none()
      menuViewController.appearance.popMenuActionCountForScrollable = 10 // default 6
      menuViewController.appearance.popMenuScrollIndicatorHidden = true // default false
      menuViewController.appearance.popMenuScrollIndicatorStyle = .black // default .white
      
      menuViewController.didDismiss = { selected in
        if !selected {
          GlobalmenuActive = false
        }
      }
      
      if(Globalorientation == Orientation.LANDSCAPE && UIDevice.current.userInterfaceIdiom == .phone){
        menuViewController.appearance.popMenuActionHeight = menuViewController.appearance.popMenuActionHeight - 6
      }
      
      present(menuViewController, animated: true, completion: nil)
      
      let actionWidth:Float = 95
      if(Globalorientation == Orientation.LANDSCAPE){
        let xOffset:Float = -(Float(menuViewController.appearance.popMenuActionHeight) * Float(menuViewController.actions.count)) / 2 + actionWidth
        menuViewController.containerView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2)).concatenating(CGAffineTransform(translationX: CGFloat(xOffset), y: 32))
      }
      return
        //self.presentingViewController?.dismiss(animated: true, completion: nil)
      let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
  
      if(GlobalCurrentView == 0){
          alert.addAction(UIAlertAction(title: lString("mapview"), style: .default) { _ in
          GlobalArView = false
          GlobalmenuActive = false
          GlobalButtonCol = UIColor.gray
          self.canvasView?.removeFromSuperview()
          self.canvasView = nil
          self.cameraLayer?.removeFromSuperlayer()
          self.cameraLayer = nil
          self.stopCamera()
            
          setDrawing(false)
            
          DispatchQueue.main.async {
            ARlatitude = latitude
            ARlongtitude = longtitude
            GlobalcalibrationWarningLabel.isHidden = true
            Globalorientation = Orientation.PORTRAIT
            Globaltoolbar?.updateOrientation()
            self.mapView = MapView(frame: self.view.bounds)
            self.view.addSubview(self.mapView)
            self.view.sendSubviewToBack(self.mapView)
            GlobalCurrentView = 1
            updateAllButtons()
          }
        })
      }else if(GlobalCurrentView == 1){
        alert.addAction(UIAlertAction(title: lString("augmentedreality"), style: .default) { _ in
          GlobalmenuActive = false
          GlobalButtonCol = UIColor.white
          self.mapView.removeFromSuperview()
          self.mapView = nil
          GlobalMapTimeZone = nil
          GlobalCurrentView = 0
          updateAddressFromLocation(location: CLLocation(latitude: ARlatitude, longitude: ARlongtitude))
          updateLocationForMath(location: CLLocation(latitude: ARlatitude, longitude: ARlongtitude))
          
          DispatchQueue.main.async {
            for view in self.view.subviews {
              view.removeFromSuperview()
            }
            //Restart ar view
            self.onViewWillAppear()
            self.didLayoutSubviews = false
            self.viewDidLayoutSubviews()

            
            updateTimeToLive()
            let millis = currentMillis()
            updatePositionYearMath(millis)
            setSunPos(millis: millis)
            updateSunTimeLabel(label1Millis: millis)
            updateDayLine()
            updateSummerAndWinterLine()
            updateAllButtons()
            GlobalArView = true
            self.asyncQonDraw()
          }
        })
      }
  
      
      alert.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "data", value: nil, table: nil), style: .default) { _ in
 
        //let dataView = DataViewController()
       // self.present(dataView, animated: true, completion: nil)
        GlobalArView = false
        GlobalmenuActive = false
        self.present(DataViewController(), animated: true)
      })

      alert.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "calibrate", value: nil, table: nil), style: .default) { _ in
        GlobalArView = false
        GlobalmenuActive = false
        GlobalcalibrateViewController = CalibrateViewController()
        self.present(GlobalcalibrateViewController, animated: true)
      })
      
      var showCameraButton = false
      if #available(iOS 10.0, *) {
        showCameraButton = true
      }
      if(!GlobalhasPremium){
        showCameraButton = false
      }
      
      let settingsAlert = UIAlertAction(title: Gb?.localizedString(forKey: "settings", value: nil, table: nil), style: .default){ _ in
        GlobalArView = false
        GlobalmenuActive = false
        self.present(SettingsViewController(), animated: true)
      }

      if(GlobalhasPremium && canvasView != nil){
      alert.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "analemma", value: nil, table: nil), style: .default) { _ in
        GlobalshowYearline = !GlobalshowYearline
        GlobalmenuActive = false
        })
      }
      alert.addAction(settingsAlert)
      alert.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "help", value: nil, table: nil), style: .default) { _ in
        GlobalArView = false
        GlobalmenuActive = false
        self.present(HelpViewController(), animated: true)
      })
      
      if(!GlobalPremiumForever){
        
        let premiumaction = UIAlertAction(title: lString("premium"), style: .default) { _ in
          GlobalArView = false
          GlobalmenuActive = false
          self.present(Globalstore, animated: true)
        }
        premiumaction.setValue(UIColor.purple, forKey: "titleTextColor")
        alert.addAction(premiumaction)
        

      }

      
      alert.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "cancel", value: nil, table: nil), style: .cancel) { _ in
        GlobalmenuActive = false
      })
      
      if let popoverPresentationController = alert.popoverPresentationController{
        popoverPresentationController.sourceView = self.view
        popoverPresentationController.sourceView = GlobalmenuButton
        popoverPresentationController.sourceRect = (GlobalmenuButton?.bounds)!
        if(Globalorientation == Orientation.LANDSCAPE){
          popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }else{
          popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
      }

      
      present(alert, animated: true)
      if(Globalorientation == Orientation.LANDSCAPE){
        alert.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2) )
      }
    }
  
    func featureNotReady(){
      let ac = UIAlertController(title: "Sorry!", message: "This feauture is not ready yet", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "ok", value: nil, table: nil), style: .default))
      present(ac, animated: true)
    }
    
    open override var prefersStatusBarHidden : Bool
    {
        return true
    }
    
    fileprivate func onViewDidLayoutSubviews()
    {
        dBug("OnViewDidLayoutSubviews")
        // Executed only first time when everything is layouted
        if !self.didLayoutSubviews
        {
            self.didLayoutSubviews = true
            
            if self.canvasView == nil { self.loadOverlay() }
          
            // Close button
            self.addMenuButton()
    
            
            // Layout
            self.layoutUi()
            
            self.view.layoutIfNeeded()
        }
        
        
    }
    //==========================================================================================================================================================                                                        Camera
    //==========================================================================================================================================================
  
     @objc func startRecording(){
      //Screen recorder
      dBug("startRecording")
      let recorder = RPScreenRecorder.shared()
      recorder.isMicrophoneEnabled = true
      recorder.startRecording{ [unowned self] (error) in
        
        if let unwrappedError = error{
          let errocode = (unwrappedError as NSError).code

          if(errocode == RPRecordingErrorCode.userDeclined.rawValue){
             return
          }
          
          let alert = UIAlertController(title: lString("recording_error"), message: lString("recording_error_desc"), preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: lString("ok"), style: .cancel, handler: nil))
          self.present(alert, animated: true)
          GlobalisRecording = false
          GlobalupdateCameraButton = true
        }else{
          print("Started recording")
          GlobalisRecording = true
          self.changeFPS(30)
          GlobalupdateCameraButton = true
        }
      }
    }
  
    @objc func stopRecording() {
      dBug("stopRecording")
      GlobalisRecording = false
      let recorder = RPScreenRecorder.shared()
      recorder.stopRecording { [unowned self] (preview, error) in
        if let unwrappederror = error{
          let alert = UIAlertController(title: lString("recording_error"), message: unwrappederror.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: lString("ok"), style: .cancel, handler: nil))
          self.present(alert, animated: true)
        }
        guard preview != nil else {
          return
        }
        
        let alert = UIAlertController(title: Gb?.localizedString(forKey: "recordingfinished", value: nil, table: nil), message: Gb?.localizedString(forKey: "editordelete", value: nil, table: nil), preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: Gb?.localizedString(forKey: "delete", value: nil, table: nil), style: .destructive, handler: { (action: UIAlertAction) in
            recorder.discardRecording(handler: { () -> Void in
          })
        })
        
        let editAction = UIAlertAction(title: Gb?.localizedString(forKey: "edit", value: nil, table: nil), style: .default, handler: { (action: UIAlertAction) -> Void in
          
          if let unwrappedPreview = preview {
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
              unwrappedPreview.modalPresentationStyle = UIModalPresentationStyle.popover
              unwrappedPreview.popoverPresentationController?.sourceRect = CGRect.zero
              unwrappedPreview.popoverPresentationController?.sourceView = self.view
            }else{
              //Phone
              if #available(iOS 13.0, *){
                //unwrappedPreview.modalPresentationStyle = .fullScreen
                GlobalArView = true
              }else{
                GlobalArView = false
              }
            }
            
            unwrappedPreview.previewControllerDelegate = self
            
            self.present(unwrappedPreview, animated: true, completion: nil)
          }
        })
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        
        if(Globalorientation == Orientation.LANDSCAPE){
          alert.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        self.present(alert, animated: false, completion: nil)
        
        self.changeFPS(targetFPS)
        GlobalupdateCameraButton = true
      }
    }

    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      dismiss(animated: true)
      GlobalArView = true
    }
  
  
    fileprivate func loadCamera()
    {
        dBug("loadCamera()")
        self.cameraLayer?.removeFromSuperlayer()
        self.cameraLayer = nil
        
        //===== Video device/video input
        let captureSessionResult = ARViewController.createCaptureSession()
        guard captureSessionResult.error == nil, let session = captureSessionResult.session else
        {
            return
        }
        
        self.cameraSession = session
      
        //===== View preview layer
        dBug("View preview layer")
        let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession)
        if (cameraLayer != nil)
        {
            dBug("Set Camera Layer")
            cameraLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
            cameraLayer.drawsAsynchronously = true
            self.view.layer.insertSublayer(cameraLayer, at: 0)
            self.cameraLayer = cameraLayer
        }
    }
    
    /// Tries to find back video device and add video input to it. This method can be used to check if device has hardware available for augmented reality.
    open class func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?)
    {
        dBug("CreateCaptureSession()")
        var error: NSError?
        var captureSession: AVCaptureSession?
        var backVideoDevice: AVCaptureDevice?
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        
        // Get back video device
        if videoDevices != nil
        {
            for captureDevice in videoDevices
            {
              if (captureDevice as AnyObject).position == AVCaptureDevice.Position.back
                {
                    dBug("BackVideoDevice")
                    backVideoDevice = captureDevice as? AVCaptureDevice
                    break
                }
            }
        }
        
        if backVideoDevice != nil
        {
            var videoInput: AVCaptureDeviceInput!
            do {
              videoInput = try AVCaptureDeviceInput(device: backVideoDevice!)
            } catch let error1 as NSError {
                error = error1
                videoInput = nil
            }
            if error == nil
            {
                captureSession = AVCaptureSession()
              
                if captureSession!.canAddInput(videoInput)
                {
                    dBug("Video added to capture session")
                    captureSession!.addInput(videoInput)
                }
                else
                {
                    error = NSError(domain: "HDAugmentedReality", code: 10002, userInfo: ["description": "Error adding video input."])
                }
            }
            else
            {
                error = NSError(domain: "HDAugmentedReality", code: 10001, userInfo: ["description": "Error creating capture device input."])
            }
        }
        else
        {
            error = NSError(domain: "HDAugmentedReality", code: 10000, userInfo: ["description": "Back video device not found."])
        }
        
        return (session: captureSession, error: error)
    }
    
    fileprivate func startCamera(notifyLocationFailure: Bool)
    {
      dBug("startCamera()")
      if(!(self.cameraSession.isRunning)){
        dBug("Start camera")
        self.cameraSession.startRunning()
      }
    }
    
    fileprivate func stopCamera()
    {
        dBug("StopCamera()")
        self.cameraSession.stopRunning()
    }
    
    //==========================================================================================================================================================                                               Overlay
    //=====================================================================================
  
    fileprivate func loadOverlay()
    {
      dBug("LOAD OVERLAY()")
      GlobalToolbarHeight = 48 + max(Globalnotchsize - 10,0)
      
      self.canvasView = CanvasView()
      self.canvasView?.initialize()
      self.view.addSubview(self.canvasView!)
      GlobalCurrentView = 0
      
      dBug("CanvasView done")
      
      GlobalAllButtons.removeAll()
      
      GloballiveButton = createButton(image: GloballiveImage!, labelText: (Gb?.localizedString(forKey: "live", value: nil, table: nil))!, place: 1)
      GloballiveButton.addTarget(self, action: #selector(liveClicked), for: .touchUpInside)
      self.view.addSubview(GloballiveButton)
      updateLiveButton()
 
      
      GlobalcalendarButton = createButton(image: GlobalcalendarImage!, labelText: (Gb?.localizedString(forKey: "date", value: nil, table: nil))!, place: 2)
      GlobalcalendarButton.addTarget(self, action: #selector(calendarClicked), for: .touchUpInside)
      self.view.addSubview(GlobalcalendarButton)
      updateCalendarButton()
      
      GlobalcameraButton = createButton(image: GlobalcameraImage!, labelText: (Gb?.localizedString(forKey: "capture", value: nil, table: nil))!, place: 3)
      GlobalcameraButton.addTarget(self, action: #selector(cameraClicked), for: .touchUpInside)
      self.view.addSubview(GlobalcameraButton)
      updateCaptureButton()
      
      GlobalfreezeButton = createButton(image: GlobalfreezeImage!, labelText: (Gb?.localizedString(forKey: "freeze", value: nil, table: nil))!, place: 4)
      GlobalfreezeButton.addTarget(self, action: #selector(freezeClicked), for: .touchUpInside)
      self.view.addSubview(GlobalfreezeButton)
      updateFreezeButton()
      
      GlobaldrawButton = createButton(image: GlobaldrawImage!, labelText: (Gb?.localizedString(forKey: "draw", value: nil, table: nil))!, place: 5)
      GlobaldrawButton.addTarget(self, action: #selector(drawClicked), for: .touchUpInside)
      self.view.addSubview(GlobaldrawButton)
      updateDrawButton()
      
      GloballineButton = createButton(image: GloballineImage!, labelText: (Gb?.localizedString(forKey: "line", value: nil, table: nil))!, place: 1)
      GloballineButton.addTarget(self, action: #selector(lineClicked), for: .touchUpInside)
      self.view.addSubview(GloballineButton)
      updateLineButton()
      
      GlobalundoButton = createButton(image: GlobalundoImage!, labelText: (Gb?.localizedString(forKey: "undo", value: nil, table: nil))!, place: 2)
      GlobalundoButton.addTarget(self, action: #selector(undoClicked), for: .touchUpInside)
      self.view.addSubview(GlobalundoButton)
      updateUndoButton()
      
      GlobaldeleteButton = createButton(image: GlobaldeleteImage!, labelText: (Gb?.localizedString(forKey: "clear", value: nil, table: nil))!, place: 3)
      GlobaldeleteButton.addTarget(self, action: #selector(deleteClicked), for: .touchUpInside)
      self.view.addSubview(GlobaldeleteButton)
      updateDeleteButton()
      
      GlobaloverlayTrackingModeButton = createButton(image: GlobalcurrentLocationImage!, labelText: lString("here"), place: 3)
      GlobaloverlayTrackingModeButton.addTarget(self, action: #selector(overlayTrackingModeButtonClicked), for: .touchUpInside)
      self.view.addSubview(GlobaloverlayTrackingModeButton)
      updateOverlayTrackingModeButton()
      
      GlobalmapButton = createButton(image: GlobalmapImage!, labelText: lString("street"), place: 4)
      GlobalmapButton.addTarget(self, action: #selector(mapClicked), for: .touchUpInside)
      self.view.addSubview(GlobalmapButton)
      updateMapButton()
      
      GlobalsearchButton = createButton(image: GlobalsearchImage!, labelText: lString("search"), place: 5)
      GlobalsearchButton.addTarget(self, action: #selector(searchClicked), for: .touchUpInside)
      self.view.addSubview(GlobalsearchButton)
      updateSearchButton()
      
      //Premiumbutton
      GlobalpremiumButton = createButton(image: GlobalpremiumImage!, labelText: (Gb?.localizedString(forKey: "get_premium", value: nil, table: nil))!, place: 3)
      GlobalpremiumButton.addTarget(self, action: #selector(premiumClicked), for: .touchUpInside)
      GlobalbuttonLabels[GlobalpremiumButton]?.frame = getPremiumLabelFrame(place: 3, buttons: 5)
      self.view.addSubview(GlobalpremiumButton)
      updatePremiumButton()
      
      dBug("Buttons done")
      
      //Toolbar
      Globaltoolbar = Toolbar(frame: CGRect(x: 0, y: 0, width: Globalwidth, height: GlobalToolbarHeight))
      self.view.addSubview(Globaltoolbar!)
      
      GlobalcalibrationWarningLabel = UILabel(frame: CGRect(x: 8, y: 48 + max(Globalnotchsize - 10,0), width: Globalwidth - 16, height: 32))
      GlobalcalibrationWarningLabel.numberOfLines = 0
      GlobalcalibrationWarningLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
      GlobalcalibrationWarningLabel.font = UIFont.systemFont(ofSize: 12)
      GlobalcalibrationWarningLabel.textColor = UIColor.red
      GlobalcalibrationWarningLabel.text = ""
      self.view.addSubview(GlobalcalibrationWarningLabel)
      
      dBug("Toolbar done")
    }
  
  func createButton(image: UIImage,labelText: String, place: Int) -> UIButton{

    //UI button
    let button = UIButton(frame: getButtonFrame(place: place, buttons: 5))
    button.setImage(image, for: .normal)
    button.tintColor = GlobalButtonCol
    
    //Label
    let label = UILabel(frame: getLabelFrame(place: place, buttons: 5))
    label.center = getLabelCenter(place: place, buttons: 5)
    label.textAlignment = .center
    label.textColor = .white
    label.text = labelText
    GlobalbuttonLabels[button] = label
    
    self.view.addSubview(label)
    GlobalAllButtons.append(button)
    return button
  }
  
  @objc func liveClicked(sender: UIButton!){
    if(!Globallive){
      updateTimeToLive()
      updateDayLine()
      self.mapView?.updateSunlineCol()
      self.mapView?.sunMapOverlay?.renderPaths()
    }
    updateLiveButton()
    if(GlobalCurrentView == 1){
      mapView.sunMapOverlay.setNeedsDisplay()
    }
  }
  
  @objc func freezeClicked(sender: UIButton!){
    Globalfrozen = !Globalfrozen
    let settings = AVCapturePhotoSettings()
    let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
    let previewFormat = [
      kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
      kCVPixelBufferWidthKey as String: 160,
      kCVPixelBufferHeightKey as String: 160
    ]
    settings.previewPhotoFormat = previewFormat
    GlobaloverlayImage = canvasView?.sceneAsImage()
    cameraOutput.capturePhoto(with: settings, delegate: self)
    
    if(Globalfrozen){
      self.stopCamera()
    }else{
      self.startCamera(notifyLocationFailure: true)
    }
    updateFreezeButton()
    
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "102",
         AnalyticsParameterItemName: "Freeze Button Click",
         AnalyticsParameterContentType: "Freeze Button Click"])
  }
  
  @objc func lineClicked(sender: UIButton!){
    GlobalisDrawingLine = !GlobalisDrawingLine
    updateLineButton()
  }
  
  @objc func undoClicked(sender: UIButton!){
    canvasView?.drawmode.undoStroke()
  }
  
  @objc func deleteClicked(sender: UIButton!){
    canvasView?.drawmode.deleteStrokes()
    updateClearButton()
  }
  
  @objc func overlayTrackingModeButtonClicked(sender: UIButton!){
    mapView?.nextOverlayTrackingMode()
    updateOverlayTrackingModeButton()
  }
  
  @objc func mapClicked(sender: UIButton!){
    mapView?.nextMapType()
    updateAllButtons()
  }
  
  @objc func searchClicked(sender: UIButton!){
    if(mapView != nil){
      mapView.search()
    }
    updateSearchButton()
  }
  
  @objc func drawClicked(sender: UIButton!){
    setDrawing(!Globaldrawing)
    if (Globaldrawing) {
      let ct = GlobalBlockedIshours ? "Draw mode w/ Sun-hours units" : "Draw mode w/ Irradiance units"
      Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "101",
           AnalyticsParameterItemName: "Draw Mode Start",
           AnalyticsParameterContentType: ct])
    }
    canvasView?.drawmode.updateBlockHourLabel()
    updateClearButton()
  }
  
  @objc func premiumClicked(sender: UIButton!){
    GlobalArView = false
    GlobalmenuActive = false
    Globalstore.modalPresentationStyle = .fullScreen
    self.present(Globalstore, animated: true)
    updatePremiumButton()
  }
  
  @objc func calendarClicked(sender: UIButton!){
    DispatchQueue.main.async {
      self.changeFPS(5)
      GlobalArView = false
      DatePickerDialog().show((Gb?.localizedString(forKey: "choose_date", value: nil, table: nil))!, doneButtonTitle: (Gb?.localizedString(forKey: "ok", value: nil, table: nil))!, cancelButtonTitle: (Gb?.localizedString(forKey: "cancel", value: nil, table: nil))!, datePickerMode: .date) {
        (date) -> Void in
        if let dt = date {
          let formatter = DateFormatter()
          formatter.dateFormat = "MM/dd/yyyy"
          
          var millis = dt.millisecondsSince1970
          updateTime(millis)
          updateDayLine()
          self.mapView?.limitToDayTime(millis)
          self.mapView?.updateSunlineCol()
          self.mapView?.sunMapOverlay?.renderPaths()
        }
      GlobalArView = true
      self.changeFPS(targetFPS)
      self.asyncQonDraw()
      }
    }
  }
  
@IBAction func cameraClicked(sender: UIButton!){
  if(GlobalcameraisScreenshot){
    let settings = AVCapturePhotoSettings()
    let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
    let previewFormat = [
      kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
      kCVPixelBufferWidthKey as String: 160,
      kCVPixelBufferHeightKey as String: 160
    ]
    settings.previewPhotoFormat = previewFormat
    
    GlobaltakingscreenshotWhole = true
    
    UIGraphicsBeginImageContext(inFrontView!.frame.size)
    
    let bpath = UIBezierPath(rect: inFrontView.frame)
    UIColor.gray.setFill()
    bpath.fill(with: CGBlendMode.normal, alpha: CGFloat(Float(180) / Float(255)))
    
    var newImage:UIImage!
    if(Globalorientation == Orientation.LANDSCAPE){
      newImage = imageRotatedByDegrees(oldImage: UIGraphicsGetImageFromCurrentImageContext()!,deg: CGFloat(-90))
    }else{
      newImage = UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    UIGraphicsEndImageContext()

    GlobaloverlayImage = newImage
    inFrontView.image = GlobaloverlayImage
    inFrontView.isHidden = false
    
    cameraOutput.capturePhoto(with: settings, delegate: self)
    
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "100",
         AnalyticsParameterItemName: "Camera Button Click",
         AnalyticsParameterContentType: "Take picture"])
    }else{
      if !GlobalisRecording {
       self.startRecording()
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterItemID: "100",
             AnalyticsParameterItemName: "Camera Button Click",
             AnalyticsParameterContentType: "Start recording"])
       } else {
       self.stopRecording()
      }
    }
  }
  
  func waitAndSave(){
    
    let size = GlobalcapturedImage.size
    
    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    UIGraphicsBeginImageContext(size)
    GlobalcapturedImage!.draw(in: areaSize)
    
    let overlayImage = canvasView!.sceneAsImage()
    overlayImage.draw(in: areaSize)

    let bpath = UIBezierPath(rect: areaSize)
    UIColor.gray.setFill()
    bpath.fill(with: CGBlendMode.normal, alpha: CGFloat(Float(180) / Float(255)))
    
    var newImage:UIImage!
    newImage = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()

    GlobaloverlayImage = newImage
    inFrontView.image = GlobaloverlayImage
    inFrontView.isHidden = false
    
    Globaltakingscreenshot = true
    GlobalwaitAndSave = 4
    Globalinstance = self
  }
  
  func addOverlayToPicture(){
    let size = GlobalcapturedImage.size

    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    UIGraphicsBeginImageContext(size)
    
    GlobalcapturedImage!.draw(in: areaSize)
    
    let saveWidth = Globalwidth
    let saveHeight = Globalheight
    
    Globalwidth = Int(size.width)
    Globalheight = Int(size.height)
    
    let overlayImage =  canvasView!.sceneAsImage()
    overlayImage.draw(in: areaSize)
    var newImage:UIImage!
    if(Globalorientation == Orientation.LANDSCAPE){
      newImage = imageRotatedByDegrees(oldImage: UIGraphicsGetImageFromCurrentImageContext()!,deg: CGFloat(-90))
    }else{
      newImage = UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    UIGraphicsEndImageContext()
    
    GlobalsaveImage = newImage
    Globalwidth = saveWidth
    Globalheight = saveHeight
    Globaltakingscreenshot = false
  }
  
  func savePicture(){
    UIImageWriteToSavedPhotosAlbum(GlobalsaveImage, self,  #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  
  
  // callBack from take picture
  func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    if(Globalfrozen && GlobaltakingscreenshotWhole){
      //Already saved when we froze
      waitAndSave()
    } else if  let sampleBuffer = photoSampleBuffer,
      let previewBuffer = previewPhotoSampleBuffer,
      let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {

      let dataProvider = CGDataProvider(data: dataImage as CFData)
      let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
      
      let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
      
      let imageWidth = image.size.width
      let imageHeight = image.size.height
      var width = imageWidth
      var height = imageHeight
      let screenAspect = self.view.frame.width / self.view.frame.height
      if(imageWidth / imageHeight > screenAspect){
        //photo is wider than screen
        width = height * screenAspect
      }else if(imageWidth / imageHeight < screenAspect){
        //photo is taller than screen
        height = width / screenAspect
      }

      let origin = CGPoint(x: (imageHeight - height)/2, y: (imageWidth - width)/2)
      let size = CGSize(width: height, height: width)
      let imageCropped = image.crop(rect: CGRect(origin: origin, size: size))
      
      GlobalcapturedImage = imageCropped
      if(GlobaltakingscreenshotWhole){
      waitAndSave()
      }
    } else {
      GlobaltakingscreenshotWhole = false
    }
    
    
  }
  
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
    if let error = error{
      let ac = UIAlertController(title: Gb?.localizedString(forKey: "save_error", value: nil, table: nil), message: error.localizedDescription, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "ok", value: nil, table: nil), style: .default))
      if(Globalorientation == Orientation.LANDSCAPE){
        ac.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
      }
      present(ac, animated: false)
    }else{
      let ac = UIAlertController(title: Gb?.localizedString(forKey: "saved", value: nil, table: nil), message: Gb?.localizedString(forKey: "saved_to_photos", value: nil, table: nil), preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: Gb?.localizedString(forKey: "ok", value: nil, table: nil), style: .default))
      if(Globalorientation == Orientation.LANDSCAPE){
        ac.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
      }
      self.present(ac,animated: false)
    }

  }
  
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
    
    fileprivate func layoutUi()
    {
      dBug("layoutUi()")
      self.cameraLayer?.frame = self.view.bounds
      self.canvasView?.frame = self.view.bounds
    }
    //==========================================================================================================================================================
    //                                                        Rotation/Orientation
    //==========================================================================================================================================================
    open override var shouldAutorotate : Bool
    {
        return true
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask(rawValue: self.interfaceOrientationMask.rawValue)
    }
    
    fileprivate func setOrientation(_ orientation: UIInterfaceOrientation)
    {
        dBug("setOrientation()")
        if self.cameraLayer?.connection?.isVideoOrientationSupported != nil
        {
            if let videoOrientation = AVCaptureVideoOrientation(rawValue: Int(orientation.rawValue))
            {
                self.cameraLayer?.connection?.videoOrientation = videoOrientation
            }
        }
      
    }

    //==========================================================================================================================================================
    //                                                       UI/==========================================================================================================================================================
    func addMenuButton()
    {
        dBug("AddMenuButton()")
        GlobalmenuButton?.removeFromSuperview()
        
        if self.menuButtonImage == nil
        {
            let bundle = Bundle(for: ARViewController.self)
            let path = bundle.path(forResource: "ic_menu", ofType: "png")
          
            if let path = path
            {
                self.menuButtonImage = UIImage(contentsOfFile: path)
            }
        }
        
        // Menu button - make it customizable
        let menuButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
        menuButton.setImage(menuButtonImage, for: UIControl.State());
      
        menuButton.frame = CGRect(x: CGFloat(self.view.bounds.size.width) - CGFloat((40 + GlobalmenuButtonOffset)), y: CGFloat(GlobalmenuButtonOffset + max(Globalnotchsize - 10, 0)), width: 40,height: 40)
        menuButton.addTarget(self, action: #selector(ARViewController.menuButtonTap), for: UIControl.Event.touchUpInside)
        menuButton.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleBottomMargin]
        self.view.addSubview(menuButton)
        GlobalmenuButton = menuButton
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

extension UIImage {
  func crop( rect: CGRect) -> UIImage {
    var rect = rect
    rect.origin.x*=self.scale
    rect.origin.y*=self.scale
    rect.size.width*=self.scale
    rect.size.height*=self.scale
    
    let imageRef = self.cgImage!.cropping(to: rect)
    let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
    return image
  }
}

extension ARViewController: PopMenuViewControllerDelegate {
  
  // This will be called when a menu action was selected
  func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
    switch popMenuViewController.actions[index].view.tag {
    case 0:
      //Goto map view
      popMenuViewController.dismiss(animated: true, completion: {
        GlobalArView = false
        GlobalmenuActive = false
        GlobalButtonCol = UIColor.gray
        self.canvasView?.removeFromSuperview()
        self.canvasView = nil
        self.cameraLayer?.removeFromSuperlayer()
        self.cameraLayer = nil
        self.stopCamera()
        
        setDrawing(false)
        
        DispatchQueue.main.async {
          ARlatitude = latitude
          ARlongtitude = longtitude
          GlobalcalibrationWarningLabel.isHidden = true
          Globalorientation = Orientation.PORTRAIT
          Globaltoolbar?.updateOrientation()
          self.mapView = MapView(frame: self.view.bounds)
          self.view.addSubview(self.mapView)
          self.view.sendSubviewToBack(self.mapView)
          GlobalCurrentView = 1
          updateAllButtons()
        }
      })
 
    case 1:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Goto data
      GlobalArView = false
      GlobalmenuActive = false
      let dataPresent = DataViewController()
      dataPresent.modalPresentationStyle = .fullScreen
      self.present(dataPresent, animated: true)
    case 2:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Goto calibrate
      GlobalArView = false
      GlobalmenuActive = false
      GlobalcalibrateViewController = CalibrateViewController()
      GlobalcalibrateViewController.modalPresentationStyle = .fullScreen
      self.present(GlobalcalibrateViewController, animated: true)
    case 3:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Goto settings
      GlobalArView = false
      GlobalmenuActive = false
      let settingsPresent = SettingsViewController()
      settingsPresent.modalPresentationStyle = .fullScreen
      self.present(settingsPresent, animated: true, completion: {
        self.mapView?.sunMapOverlay?.renderPaths()
        self.mapView?.updateOverlay()
      })
    case 4:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Toggle analemma
      GlobalshowYearline = !GlobalshowYearline
      GlobalmenuActive = false
    case 5:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Goto help
      GlobalArView = false
      GlobalmenuActive = false
      let helpPresent = HelpViewController()
      helpPresent.modalPresentationStyle = .fullScreen
      self.present(helpPresent, animated: true)
    case 6:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Dismiss
      GlobalmenuActive = false
    case 7:
      popMenuViewController.dismiss(animated: true, completion: {
        //Goto augmented view
        GlobalmenuActive = false
        GlobalButtonCol = UIColor.white
        self.mapView.removeFromSuperview()
        self.mapView = nil
        self.cameraOutputAdded = false
        GlobalMapTimeZone = nil
        GlobalCurrentView = 0
        updateAddressFromLocation(location: CLLocation(latitude: ARlatitude, longitude: ARlongtitude))
        updateLocationForMath(location: CLLocation(latitude: ARlatitude, longitude: ARlongtitude))
        
        DispatchQueue.main.async {
          for view in self.view.subviews {
            view.removeFromSuperview()
          }
          //Restart ar view
          self.onViewWillAppear()
          self.didLayoutSubviews = false
          self.onViewDidLayoutSubviews()
          
          updateTimeToLive()
          let millis = currentMillis()
          updatePositionYearMath(millis)
          setSunPos(millis: millis)
          updateSunTimeLabel(label1Millis: millis)
          updateDayLine()
          updateSummerAndWinterLine()
          GlobalArView = true
          updateAllButtons()
          self.asyncQonDraw()
        }
      })
 
    case 8:
      popMenuViewController.dismiss(animated: true, completion: nil)
      //Goto premium
      GlobalArView = false
      GlobalmenuActive = false
      Globalstore.modalPresentationStyle = .fullScreen
      self.present(Globalstore, animated: true)
    default:
      popMenuViewController.dismiss(animated: true, completion: nil)
      GlobalmenuActive = false
    }
  }
  
}
