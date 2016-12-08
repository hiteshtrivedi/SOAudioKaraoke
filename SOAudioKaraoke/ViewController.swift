//
//  ViewController.swift
//  SOAudioKaraoke
//
//  Created by Hitesh on 12/8/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var audioPlayer:AVAudioPlayer!
    var currentTrack = 0
    
    var arrTracks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.sharedApplication().statusBarHidden=true; 
        btnStop.hidden = true
        self.initilizePlayer()
    }
    
    //MARK: Audio player initilizer
    func initilizePlayer() {
        let strTrack = arrTracks[currentTrack] as String
        let audioFilePath = NSBundle.mainBundle().pathForResource(strTrack, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
            } catch {
                print("????")
            }
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            
        } else {
            print("audio file is not found")
        }
    }
    
    
    //MARK: Start and Pause button action
    @IBAction func actionPlaySound(sender: UIButton) {
        btnStop.hidden = false
        
        
        if audioPlayer.playing == false {
            //Start Playing audio
            audioPlayer.play()
            btnPlay.setTitle("Pause", forState: .Normal)
            
            self.startTimer()
        } else {
            //Pause Playing audio
            audioPlayer.pause()
            btnPlay.setTitle("Play", forState: .Normal)
            self.stopTimer()
        }
    }
    

    //MARK: Update slider
    func updateSlider() {
        print(audioPlayer.currentTime, audioPlayer.duration)
        slider.maximumValue = Float(audioPlayer.duration)
        slider.value = Float(audioPlayer.currentTime)
        //slider.value = normalizedTime
    }
    
    
    //MARK: Action for play next track
    @IBAction func actionNextTrack(sender: UIButton) {
        self.playNextTrack()
    }
    
    
    func playNextTrack() {
        if audioPlayer?.playing == true {
            audioPlayer?.stop()
        }
        
        currentTrack += 1
        if currentTrack >= arrTracks.count {
            currentTrack = 0
        }
        self.initilizePlayer()
        audioPlayer?.play()
    }
    
    //MARK: Action for play previous track
    @IBAction func actionPreviousTrack(sender: UIButton) {
        if audioPlayer?.playing == true {
            audioPlayer?.stop()
        }
        currentTrack -= 1
        if currentTrack < 0 {
            currentTrack = arrTracks.count - 1
        }
        
        self.initilizePlayer()
        audioPlayer.play()
    }
    
    
    
    //MARK: Action for play previous track
    @IBAction func actionStop(sender: UIButton) {
        if audioPlayer?.playing == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            self.stopTimer()
        }
        btnPlay.setTitle("Play", forState: .Normal)
        btnStop.hidden = false
        slider.value = 0.0
    }
    
    
    //Mark: AVAudioPlayer Delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            //can perform next action
            self.playNextTrack()
        }
    }
    
    
    //MARK: Timer stop and start for update slider for time
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer.valid == true {
            timer.invalidate()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

