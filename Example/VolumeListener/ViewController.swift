//
//  ViewController.swift
//  VolumeListener
//
//  Created by AMaster124 on 02/09/2021.
//  Copyright (c) 2021 AMaster124. All rights reserved.
//

import UIKit
import VolumeListener

class ViewController: UIViewController {
    @IBOutlet weak var btnHelp: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        VolumeListener.sharedInstance().startListener(triggerCnt: 3, delegate: self)
    }

    @IBAction func onBtnHelp(_ sender: Any) {
        if VolumeListener.sharedInstance().isWait {
            sendRequest()
            VolumeListener.sharedInstance().stopListener()
        } else {
            VolumeListener.sharedInstance().startListener(triggerCnt: 3, delegate: self)
            btnHelp.setTitle("구조요청", for: .normal)
            btnHelp.backgroundColor = .blue
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendRequest() {
        btnHelp.setTitle("구조요청중...", for: .normal)
        btnHelp.backgroundColor = .red
        self.view.layoutIfNeeded()
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "테스트"
        content.body = "구조요청이 되었습니다."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        if #available(iOS 12.0, *) {
            content.sound = .defaultCritical
        } else {
            content.sound = .default
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

}

extension ViewController: VolumeListenerDelegate {
    func didChangedVolume(volumeListner: VolumeListener) {
        sendRequest()
        print("tapped volume button!!!")
    }
}
