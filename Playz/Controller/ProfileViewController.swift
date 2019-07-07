//
//  AddProfileViewController.swift
//  Playz
//
//  Created by Johan on 28-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVKit
import Foundation

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: UserModel!
    var posts: [PostModel] = []
    
    var profileCell: UserProfileHeaderCell = UserProfileHeaderCell()
    
    let activityLoader: CustomActivityIndicator = CustomActivityIndicator()
    
    var imagePickerCaller: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset.top = -UIApplication.shared.statusBarFrame.height
        collectionView.dataSource = self
        collectionView.delegate = self
        if user == nil {
            fetchCurrentUser()
        } else {
            fetchMyPosts()
        }
    }
    
    func fetchCurrentUser() {
        UserObserver().observeCurrentUser { [weak self] (user) in
            self?.user = user
            self?.navigationItem.title = user.username
            self?.collectionView.reloadData()
            self?.fetchMyPosts()
        }
    }
    
    func fetchMyPosts() {
        guard let userId = user.id else {
            return
        }
        MyPostFetcher().REF_MYPOSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            PostObserver().observePost(withId: snapshot.key, completion: { [weak self]
                post in
                self?.posts.append(post)
                self?.collectionView.reloadData()
            })
        })
    }
    
    func showImagePicker () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
        //show actuvity indicator
        activityLoader.showActivityIndicator(uiView: self.view)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //hide actuvity indicator
        activityLoader.hideActivityIndicator(uiView: self.view)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let orignalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            if self.imagePickerCaller == "backgroundImg"{
                self.profileCell.updateBackgroundImage(image: orignalImage)
            } else if self.imagePickerCaller == "profileImg" {
                self.profileCell.updateProfileImage(image: orignalImage)
            }
            
            //hide actuvity indicator
            activityLoader.hideActivityIndicator(uiView: self.view)
            //
            dismiss(animated: true, completion: nil)
        }
    }
    
    //Segeus for profilepage
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "userSettingSegue" {
            guard let settingVC = segue.destination as? SettingTableViewController else {
                return
            }
            settingVC.delegate = self
        }
        
        if segue.identifier == "Profile_DetailSegue" {
            guard let detailVC = segue.destination as? DetailViewController, let postId = sender as? String else {
                return
            }
            detailVC.postId = postId
        }
    }
    
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    //Displays post in the profilepage
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionCell", for: indexPath) as? VideoCollectionCell else {
            return UICollectionViewCell()
        }
        let post = posts[indexPath.row]
        cell.delegate = self
        cell.post = post
        return cell
    }
    
    //For the header so it changes of a user look at your profile or you look at your own profile
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserProfileHeaderCell", for: indexPath) as? UserProfileHeaderCell else {
            return UICollectionReusableView()
        }
        headerViewCell.delegate3 = self
        headerViewCell.delegate4 = self 
        self.profileCell = headerViewCell
        
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegate2 = self
        }
        return headerViewCell
    }
    
}

extension ProfileViewController: UserProfileHeaderEditProfileDelegate {
    func goToSettingVC() {
        performSegue(withIdentifier: "userSettingSegue", sender: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
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

extension ProfileViewController: SettingVCDelegate {
    func updateUserInfor() {
//        self.fetchUserModel()
        
//        profileCell.updateView()
    }
}

extension ProfileViewController: VideoCollectionViewCellDelegate {
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.player?.play()
        present(playerVC, animated: true, completion: nil)
    }
}

extension ProfileViewController: UserProfileHeaderImagePickerDelegae {
    
    func loadImagePicker(caller: String) {
        self.imagePickerCaller = caller
        self.showImagePicker()
    }
}

extension ProfileViewController: UserProfileHeaderDismissDelegate {
    func dismissProfileViewController() {
        dismiss(animated: true, completion: nil)
    }
}
