//
//  ViewController.swift
//  Export10
//
//  Created by User on 2019-08-23.
//  Copyright © 2019 Organization. All rights reserved.
//

import AudioKit
import UIKit

class ViewController: UIViewController {

    lazy var player = AKPlayer(url: Bundle.main.url(forResource: "Test", withExtension: "m4a")!)!
    lazy var shifter = AKPitchShifter(self.player, shift: 8)
    lazy var offlineRenderer = AKOfflineRenderNode(self.shifter)
    
    @IBAction func export() {
        let url = URL(fileURLWithPath: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0] as NSString).appendingPathComponent("result.aac"))
        print(url)
        
        AudioKit.output = offlineRenderer
        
        offlineRenderer.internalRenderEnabled = false
        try! AudioKit.start()
        
        // I also tried using AKAudioPlayer instead of AKPlayer
        // Also tried getting time in these ways:
        // AVAudioTime.secondsToAudioTime(hostTime: 0, time: 0)
        // player.audioTime(at: 0)
        // And for hostTime I've tried 0 as well as mach_absolute_time()
        // None worked
        
        let time = AVAudioTime(sampleTime: 0, atRate: offlineRenderer.avAudioNode.inputFormat(forBus: 0).sampleRate)
        player.play(at: time)
        try! offlineRenderer.renderToURL(url, duration: player.duration, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC])
        
        player.stop()
        player.disconnectOutput()
        offlineRenderer.internalRenderEnabled = true
        
        try? AudioKit.stop()
    }

}

