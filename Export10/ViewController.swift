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
        
        //AVAudioTime.secondsToAudioTime(hostTime: 0, time: 0)
        //player.audioTime(at: 0)
        
        AudioKit.output = offlineRenderer
        
        offlineRenderer.internalRenderEnabled = false
        try! AudioKit.start()
        
        let time = AVAudioTime(sampleTime: 0, atRate: offlineRenderer.avAudioNode.inputFormat(forBus: 0).sampleRate)
        player.play(at: time)
        let buffer = try! offlineRenderer.renderToBuffer(for: player.duration)
        
        player.stop()
        player.disconnectOutput()
        offlineRenderer.internalRenderEnabled = true
        
        let file = try! AVAudioFile(forWriting: url, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC])
        
        try! file.write(from: buffer)
        print("Done")
    }

}

