//
//  ViewController.swift
//  SOAudioKaraoke
//
//  Created by Hitesh on 12/8/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnRecord: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    
    //Setting for recorder
    let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
                          AVEncoderBitRateKey: 16,
                          AVNumberOfChannelsKey : 2,
                          AVSampleRateKey: 44100.0]
    
    
    var audioPlayer:AVAudioPlayer!
    var currentTrack = 0
    
    var arrTracks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.sharedApplication().statusBarHidden=true; 
        btnStop.enabled = false
        
        self.prepareRecorder()
        self.initilizePlayer()
    }
    
    func prepareRecorder() {
        // getting URL path for audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = dirPath[0]
        let soundFilePath = (docDir as NSString).stringByAppendingPathComponent("sound.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        print(soundFilePath)
        

        var error : NSError?
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            error = error1
        }
        if let err = error{
            print("audioSession error: \(err.localizedDescription)")
        }
        do {
            audioRecorder = try AVAudioRecorder(URL: soundFileURL, settings: recordSettings as! [String : AnyObject])
        } catch let error1 as NSError {
            error = error1
            audioRecorder = nil
        }
        
        if let err = error{
            print("audioSession error: \(err.localizedDescription)")
        }else{
            audioRecorder?.prepareToRecord()
        }
    }
    
    //MARK: Audio player initilizer with some bundled audio files
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
    

    //MARK: Start Recording
    @IBAction func actionStartRecord(sender: AnyObject) {
        if !audioRecorder.recording {
            btnPlay.enabled = false
            audioPlayer.play()
            audioRecorder?.record()
            btnRecord.setTitle("Stop", forState: .Normal)
        } else {
            //Stop audio
            btnPlay.enabled = true
            self.initilizePlayer()
            audioRecorder?.stop()
            btnRecord.setTitle("Record", forState: .Normal)
        }
    }
    

    
    
    //MARK: Start and Pause button action
    @IBAction func actionPlaySound(sender: UIButton) {
        
        if audioRecorder?.recording == false {
            if audioPlayer.playing == false {
                
                var error : NSError?
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOfURL: (audioRecorder?.url)!)
                } catch let error1 as NSError {
                    error = error1
                    audioPlayer = nil
                }
                
                audioPlayer?.delegate = self
                
                if let err = error{
                    print("audioPlayer error: \(err.localizedDescription)")
                }else{
                    audioPlayer?.play()
                }
                
                btnPlay.setTitle("Pause", forState: .Normal)
                btnRecord.enabled = false
                self.startTimer()
            } else {
                audioPlayer.pause()
                btnPlay.setTitle("Play", forState: .Normal)
                btnRecord.enabled = true
                self.stopTimer()
            }
        }
        
        btnStop.enabled = true
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
        btnRecord.enabled = true
        btnPlay.setTitle("Play", forState: .Normal)
        btnStop.enabled = false
        slider.value = 0.0
    }
    
    
    //Mark: AVAudioPlayer Delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            //can perform next action
            //self.playNextTrack()
            self.initilizePlayer()
            btnPlay.setTitle("Play", forState: .Normal)
            btnRecord.enabled = true
            btnStop.enabled = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        btnPlay.enabled = true
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        btnPlay.enabled = true
        print("audio Recorder Did Finish Recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Audio Record Encode Error")
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

