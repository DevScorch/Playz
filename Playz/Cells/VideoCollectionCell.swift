//
//  VideoCollectionCell.swift
//  Playz
//
//  Created by LangsemWork on 03.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVKit

//Segue protocol
protocol VideoCollectionViewCellDelegate: class {
    func playVideo(url: URL)
}

class VideoCollectionCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var postedVideo: UIImageView!
    
    weak var delegate: VideoCollectionViewCellDelegate?
    
    var post: PostModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let thumbnailUrlString = post?.thumbnailUrl {
            let thumbnailUrl = URL(string: thumbnailUrlString)
            postedVideo.sd_setImage(with: thumbnailUrl)
        }
    }
    
    @IBAction func playVideoBtn(_ sender: Any) {
        guard let videoPath = post?.videoUrl, let videoURL = URL(string: videoPath) else {
            return
        }
        delegate?.playVideo(url: videoURL)
    }
}
