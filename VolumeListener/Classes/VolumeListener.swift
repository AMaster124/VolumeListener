import UIKit
import AVFoundation
import CoreLocation
import MediaPlayer

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
    private var spaceTime: Double = 0
    private var prevSpaceTime = -0.1
    private var checkSpaceTimer: Timer? = nil
    
    private var audioPlayer: AVAudioPlayer? = nil
    
    private var oldVolume: Float = 0
    
    let reachability = try! VLReachability()

    public static func sharedInstance() -> VolumeListener {
        return shared
    }
    
    private func setWait(wait: Bool) {
        self.isWait = wait
    }
    
    public func stopListener() {
        setWait(wait: false)
        audioPlayer?.stop()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("didEnterBackground"), object: nil)
    }
    
    public func startListener(triggerCnt: Int = 3, delegate: VolumeListenerDelegate? = nil) {
        setWait(wait: true)
        self.delegate = delegate
        self.triggerCnt = triggerCnt
        print( "startListener")
        
        setRechability()
        playMusic()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name(rawValue: "didEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAudioSessionEvent), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc func onAudioSessionEvent(notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification {
            if notification.userInfo?[AVAudioSessionInterruptionTypeKey] as! UInt == AVAudioSession.InterruptionType.began.rawValue {
//                print("Interruption began!")
            } else {
//                print("Interruption ended!")
                playMusic()
            }
        }

    }
    
    @objc func didEnterBackground() {
        if self.isWait {
//            MPVolumeView.setVolume(0.5)
            if self.audioPlayer?.isPlaying != true {
                playMusic()
            }
        }
    }
    
    private func playMusic(){
        guard let url = Bundle(for: VolumeListener.self).url(forResource: "nonesound", withExtension: "mp3") else {return}
        if(self.audioPlayer != nil && self.audioPlayer!.isPlaying){
            self.audioPlayer?.stop()
        }

        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.numberOfLoops = -1
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("Session is Active")
            
        } catch {
            print(error)
        }

        self.audioPlayer?.play()
        self.audioPlayer?.delegate = self

//        audioSession.addObserver(self, forKeyPath: "outputVolume", options: .old, context: nil)
    }
    
//    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//      if keyPath == "outputVolume" {
//        print("got in here")
//      }
//    }

    private func initState() {
        checkSpaceTimer?.invalidate()
        checkSpaceTimer = nil
        spaceTime = 0
        prevSpaceTime = -0.1
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
        if isWait == false || spaceTime-prevSpaceTime < 0.1 {
            initState()
            return
        }
        prevSpaceTime = spaceTime
        
        if spaceTime == 0 {
            clickedCnt = 0
        }

        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float

        print("Device Volume:\(volume)", spaceTime, prevSpaceTime)

//        if(volume != 0 && volume != 1 && volume == oldVolume) {
//            return
//        }
        
        oldVolume = volume
        
        clickedCnt += 1
        if checkSpaceTimer == nil {
            checkSpaceTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.checkSpaceTime), userInfo: nil, repeats: true)
            spaceTime = 0
            prevSpaceTime = -0.1
        }
        
        if clickedCnt >= self.triggerCnt {
            stopListener()
            delegate?.didChangedVolume(volumeListner: self)
        }
    }

    @objc private func checkSpaceTime() {
        spaceTime += 0.05
        if spaceTime > 5 {
            initState()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.last)
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            slider?.setValue(volume, animated: false)
        }
    }
}

extension VolumeListener: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur")
    }
    
    public func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("audioPlayerBeginInterruption")
    }
    
    public func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("audioPlayerEndInterruption")
    }
}
