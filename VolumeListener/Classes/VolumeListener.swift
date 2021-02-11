import UIKit
import AVFoundation
import CoreLocation

public protocol VolumeListenerDelegate {
    func didChangedVolume(volumeListner: VolumeListener)
}

public class VolumeListener: NSObject, CLLocationManagerDelegate {
    static let shared = VolumeListener()
    var delegate: VolumeListenerDelegate? = nil

    public var isWait = true

    private var locationManager = CLLocationManager()
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var progressObserver: NSKeyValueObservation!
    
    private var triggerCnt = 3
    private var clickedCnt = 0
    private var spaceTime = 0.1
    private var checkSpaceTimer: Timer? = nil
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    let reachability = try! VLReachability()

    public static func sharedInstance() -> VolumeListener {
        return shared
    }
    
    public func setWait(wait: Bool) {
        self.isWait = wait
    }
    
    public func startListener(triggerCnt: Int = 3, delegate: VolumeListenerDelegate? = nil) {
        self.delegate = delegate
        self.triggerCnt = triggerCnt
        print( "startListener")
        
        setRechability()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
//        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        
        playMusic()
        
//        do {
//            try audioSession.setActive(true)
//        } catch {
//            print("cannot activate session")
//        }
//
        UIApplication.shared.beginReceivingRemoteControlEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    private func playMusic(){
//        guard let path = Bundle.main.path(forResource: "nonesound.mp3", ofType: nil) else { return }
        guard let url = Bundle(for: VolumeListener.self).url(forResource: "phone_sound", withExtension: "mp3") else {return}
//        let url = URL(fileURLWithPath: path)
//        do{
            if(self.audioPlayer != nil && self.audioPlayer!.isPlaying){
                self.audioPlayer?.stop()
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.numberOfLoops = 1

                try audioSession.setActive(true)
                print("Session is Active")
            } catch {
                print(error)
            }

            self.audioPlayer?.play()
            
//        } catch{
//
//        }
    }
    
    func stopListenr() {
        isWait = true
    }
    
    private func initState() {
        checkSpaceTimer?.invalidate()
        checkSpaceTimer = nil
        spaceTime = 0
        clickedCnt = 0
    }
    
    private func setRechability() {
        self.reachability.whenReachable = { reachability in
            print("test")
            if reachability.connection == .wifi {
                print("11Reachable via WiFi")
                
                self.locationManager.startUpdatingLocation()
            } else {
                print("11Reachable via Cellular")
                
                self.locationManager.startUpdatingLocation()
            }
        }
        
        self.reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

    }
    
    @objc private func volumeDidChange(notification: NSNotification) {
        if isWait == false {
            initState()
            return
        }
        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        print("Device Volume:\(volume)")
        
        clickedCnt += 1
        if checkSpaceTimer == nil {
            checkSpaceTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkSpaceTime), userInfo: nil, repeats: true)
            spaceTime = 0
        }
        
        if clickedCnt >= self.triggerCnt {
            isWait = false
            delegate?.didChangedVolume(volumeListner: self)
        }
    }

    @objc private func checkSpaceTime() {
        spaceTime += 0.1
        if spaceTime > 0.5 {
            initState()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.last)
    }
}

