//
//  HashTagViewController.swift
//  Playz
//
//  Created by LangsemWork on 05.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import AVKit
import CoreVideo

class HashTagViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [PostModel] = []
    var tag = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(tag)"
        collectionView.dataSource = self
        collectionView.delegate = self
        loadPosts()
    }
    
    func loadPosts() {
        HashTagObserver().fetchPosts(withTag: tag) { (postId) in
            PostObserver().observePost(withId: postId, completion: { [weak self] (post) in
                self?.posts.append(post)
                self?.collectionView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "HashTag_DetailSegue" {
            guard let detailVC = segue.destination as? DetailViewController, let postId = sender as? String else {
                return
            }
            detailVC.postId = postId
        }
    }
}

extension HashTagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionCell", for: indexPath) as? VideoCollectionCell else {
            return UICollectionViewCell()
        }
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
}

extension HashTagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}

extension HashTagViewController: VideoCollectionViewCellDelegate {
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.player?.play()
        present(playerVC, animated: true, completion: nil)
    }
    
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "HashTag_DetailSegue", sender: postId)
    }
}
