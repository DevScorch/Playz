//
//  OnClickCatergoryViewController.swift
//  Playz
//
//  Created by LangsemWork on 05.06.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVKit
class OnClickCategoryViewController: UIViewController {
    
    //Outlets
    
    @IBOutlet weak var onclickCategoryCollectionView: UICollectionView!
    var posts = [PostModel]()
    var category: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        onclickCategoryCollectionView.dataSource = self
        onclickCategoryCollectionView.delegate = self
        loadPosts()
    }

    func loadPosts() {
        //get the title and videos for displaying the right video for the right category
        CategoryObserver().fetchPosts(withTag: category) { (postId) in
            PostObserver().observePost(withId: postId, completion: { [weak self]  (postModel) in
                self?.posts.append(postModel)
                self?.onclickCategoryCollectionView.reloadData()
            })
        }
    }
    
    @IBAction func dismissVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension OnClickCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Return the amount of videos with that category
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = onclickCategoryCollectionView.dequeueReusableCell(withReuseIdentifier: "OnClickCategoryCollectionViewCell", for: indexPath) as? OnClickCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        //Fill in the video of that category
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerViewCell = onclickCategoryCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "OnClickCategoryHeaderCollectionReusableView", for: indexPath) as? OnClickCategoryHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        //Feed the cell with the right category for the label from search
        headerViewCell.categorie = category
        return headerViewCell
    }
}

extension OnClickCategoryViewController: OnClickCategoryCollectionViewCellDelegate {
    func present(playerVC: AVPlayerViewController) {
        present(playerVC, animated: true, completion: {
            playerVC.player?.play()
        })
    }
}

extension OnClickCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: onclickCategoryCollectionView.frame.size.width / 3 - 1, height: onclickCategoryCollectionView.frame.size.width / 3 - 1)
    }
}
