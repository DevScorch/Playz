//
//  DiscoverViewController.swift
//  Playz
//
//  Created by LangsemWork on 05.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:
            .plain, target: nil, action: nil)
        loadTopPosts()
    }
    
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
    func loadTopPosts() {
        self.posts.removeAll()
        self.collectionView.reloadData()
        PostObserver().observeTopPosts { (post) in
            self.posts.append(post)
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_DetailSegue" {
            guard let detailVC = segue.destination as? DetailViewController, let postId = sender as? String else {
                return
            }
            detailVC.postId = postId
        }
    }
}

extension DiscoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as? VideoCollectionCell else {
            return UICollectionViewCell()
        }
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
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

extension DiscoverViewController: VideoCollectionCell {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
    
}
