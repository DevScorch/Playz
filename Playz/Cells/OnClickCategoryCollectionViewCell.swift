//
//  OnclickCategoryCollectionViewCell.swift
//  Playz
//
//  Created by LangsemWork on 05.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVKit
protocol OnClickCategoryCollectionViewCellDelegate: class {
    func present(playerVC: AVPlayerViewController)
}

class OnClickCategoryCollectionViewCell: UICollectionViewCell {
    
    //Outlet
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    
    weak var delegate: OnClickCategoryCollectionViewCellDelegate?
    
    var post: PostModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let videoUrlString = post?.thumbnailUrl {
            let videoUrl = URL(string: videoUrlString)
            videoThumbnail.sd_setImage(with: videoUrl)
        }
        
        let tapGestureForVideo = UITapGestureRecognizer(target: self, action: #selector(self.video_TouchUpInside))
        videoThumbnail.addGestureRecognizer(tapGestureForVideo)
        videoThumbnail.isUserInteractionEnabled = true
        
    }
    
    @objc func video_TouchUpInside() {
      //perform a fullscreen avplayer when the video its tapped
        let playerVC = AVPlayerViewController()
        guard let urlString = post?.videoUrl, let videoURL = URL(string: urlString) else {
            return
        }
        playerVC.player = AVPlayer(url: videoURL)
        delegate?.present(playerVC: playerVC)
    }
    
}
