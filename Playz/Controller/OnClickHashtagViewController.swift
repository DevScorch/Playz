//
//  OnClickHashtagViewController.swift
//  Playz
//
//  Created by LangsemWork on 05.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVKit
class OnClickHashtagViewController: UIViewController {

    //Outlet
    
    @IBOutlet weak var onclickHashtagCollectionView: UICollectionView!
    
    var posts = [PostModel]()
    var tag = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        onclickHashtagCollectionView.dataSource = self
        onclickHashtagCollectionView.delegate = self
        loadPosts()
    }
    
    func fetchHashtagInfo() {
        //get the title and videos for displaying the right video for the right hashtagsearch
        self.onclickHashtagCollectionView.reloadData()
    }
    
    @IBAction func dismissHashTagVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func loadPosts() {
        HashTagObserver().fetchPosts(withTag: tag) { (postId) in
            PostObserver().observePost(withId: postId, completion: { [weak self] (postModel) in
                self?.posts.append(postModel)
                self?.onclickHashtagCollectionView.reloadData()
            })
        }
    }
}

extension OnClickHashtagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Return the amount of videos with that hashtag
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = onclickHashtagCollectionView.dequeueReusableCell(withReuseIdentifier: "OnClickHashtagCollectionViewCell", for: indexPath) as? OnClickHashtagCollectionViewCell {
        //Fill in the video of that hashtag
            cell.post = posts[indexPath.row]
            cell.delegate = self 
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerViewCell = onclickHashtagCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "OnClickHashtagCollectionReusableView", for: indexPath) as? OnClickHashtagCollectionReusableView else {
            return UICollectionReusableView()
        }
        //Feed the cell with the right hashtag for the label from search
        headerViewCell.hashtagLabel.text = "#\(tag)"
        return headerViewCell
    }
}

extension OnClickHashtagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: onclickHashtagCollectionView.frame.size.width / 3 - 1, height: onclickHashtagCollectionView.frame.size.width / 3 - 1)
    }
}
extension OnClickHashtagViewController: OnClickHashtagCollectionViewCellDelegate {
    func presentAVPlayer(playerVC: AVPlayerViewController) {
        present(playerVC, animated: true, completion: {
            playerVC.player?.play()
        })
    }
}
