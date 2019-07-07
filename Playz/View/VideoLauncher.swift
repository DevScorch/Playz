//
//  VideoLauncher.swift
//  Playz
//
//  Created by LangsemWork on 12.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
//
////Class that handles a animated player like youtube does
//class VideoLauncher: NSObject {
//    
//    func showVideoPlayer() {
//        
//        if let keyWindow = UIApplication.shared.keyWindow {
//          let view = UIView(frame: keyWindow.frame)
//            view.backgroundColor = UIColor.black
//            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
//            
//            //Aspect Ratio of Hd
//            let height = keyWindow.frame.width * 9 / 16
//            let videPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
//            let videoPlayerView = VideoPlayerView(frame: videPlayerFrame)
//            view.addSubview(videoPlayerView)
//            keyWindow.addSubview(view)
//            
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                view.frame = keyWindow.frame
//            }) { (_) in
//                //hide status bar
//                UIApplication.shared.setStatusBarHidden(true, with: .fade)
//            }
//        }
//        
//    }
//}
