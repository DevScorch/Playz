//
//  VideoPlayerView.swift
//  Playz
//
//  Created by LangsemWork on 12.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    let activtyindicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    let pausePlayButton: UIButton = {
       let button = UIButton(type: .system)
       // let image = UIImage(named: "pause")
       // button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
         setUpPlayer()
        controlsContainerView.frame = frame
        addSubview(controlsContainerView)
        controlsContainerView.addSubview(activtyindicator)
        activtyindicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activtyindicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        pausePlayButton.addSubview(controlsContainerView)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backgroundColor = .black
       
    }
    
    @objc func handlePause() {
        
        if isPlaying {
            player?.pause()
                 // pauseButton.setImage("play", for: normal)
        } else {
            player?.play()
            // pauseButton.setImage("pause", for: normal)
        }
        isPlaying = !isPlaying
    }
    
    var isPlaying = false
    var player: AVPlayer?
    
   private func setUpPlayer() {
        let urlString = "UrlString"
        
        if let url = NSURL(string: urlString) {
            player = AVPlayer(url: url as URL)
            
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            player?.play()
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        //Player rdy rendering
        if keyPath == "currentItem.loadedTimeRanges" {
            activtyindicator.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            pausePlayButton.isHidden = false
            isPlaying = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
