//
//  OnClickHashtagCollectionViewCell.swift
//  Playz
//
//  Created by LangsemWork on 05.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVKit

protocol OnClickHashtagCollectionViewCellDelegate: class {
    func presentAVPlayer(playerVC: AVPlayerViewController)
}

class OnClickHashtagCollectionViewCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var hashtagVideoImage: UIImageView!
    weak var delegate: OnClickHashtagCollectionViewCellDelegate?
    var post: PostModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let urlString = post?.thumbnailUrl {
            let thumbnailURL = URL(string: urlString)
            hashtagVideoImage.sd_setImage(with: thumbnailURL)
        }
        let tapGestureForVideo = UITapGestureRecognizer(target: self, action: #selector(self.video_TouchUpInside))
        hashtagVideoImage.addGestureRecognizer(tapGestureForVideo)
        hashtagVideoImage.isUserInteractionEnabled = true
    }
    
    @objc func video_TouchUpInside() {
        //Do fullscreen avplayer here
        let playerVC = AVPlayerViewController()
        guard let urlString = post?.videoUrl, let videoURL = URL(string: urlString) else {
            return
        }
        playerVC.player = AVPlayer(url: videoURL)
        delegate?.presentAVPlayer(playerVC: playerVC)
        
    }
}
