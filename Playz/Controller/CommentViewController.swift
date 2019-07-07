//
//  CommentViewController.swift
//  Playz
//
//  Created by LangsemWork on 01.05.2018.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import Foundation

class CommentViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var postId: String!
    
    var comments = [CommentModel]()
    var currentComment: CommentModel?
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableViewAutomaticDimension
        empty()
        handleTextField()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        
        view.addGestureRecognizer(edgePan)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        goBack()
    }
    
    @objc func goBack () {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print(notification)
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.constraintToBottom.constant = keyboardFrame!.height
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.constraintToBottom.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
    
    private func alreadyExists(comment: CommentModel) -> Bool {
        for existingComment in comments where existingComment.commentUID == comment.commentUID {
            return true
        }
        return false
    }
    
    func loadComments() {
        PostCommentObserver().REF_POST_COMMENTS.child(postId).observe(.childAdded, with: {
            snapshot in
            CommentObserver().observeComments(withPostId: snapshot.key, completion: { [weak self]
                comment in
                if let newSelf = self {
                    
                    if !newSelf.alreadyExists(comment: comment) {
                        if comment.commentText != nil {
                            self?.fetchUser(uid: comment.uid!, completed: {
                                self?.comments.append(comment)
                                self?.tableView.reloadData()
                            })
                        }
                    }
                }
            })
        })
    }
    
    func fetchUser(uid: String, completed:  @escaping () -> Void ) {
        
        UserObserver().observeUser(withId: uid, completion: { [weak self] user in
            self?.users.append(user)
            completed()
        })
    }
    
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        
        let commentsReference = CommentObserver().REF_COMMENTS
        let newCommentId = commentsReference.childByAutoId().key
        let newCommentReference = commentsReference.child(newCommentId)
        guard let currentUser = UserObserver().CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        newCommentReference.setValue(["uid": currentUserId, "comment_text": commentTextField.text!], withCompletionBlock: { [weak self] (error, _) in
            if error != nil {
                print(error as Any)
                return
            }
            
            if let words = self?.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines) {
                for var word in words {
                    if word.hasPrefix("#") {
                        word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                        let newHashTagRef = HashTagObserver().REF_HASHTAG.child(word.lowercased())
                        newHashTagRef.updateChildValues([self!.postId: true])
                    }
                }
            }
            
            guard let newSelf = self else {
                return
            }
                let postCommentRef = PostCommentObserver().REF_POST_COMMENTS.child(newSelf.postId).child(newCommentId)
                postCommentRef.setValue(true, withCompletionBlock: { (error, _) in
                    if error != nil {
                        return
                    }
                    PostObserver().observePost(withId: newSelf.postId, completion: { (post) in
                        if post.uid != UserObserver().CURRENT_USER!.uid {
                            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                            let newNotificationId = NotificationObserver().REF_NOTIFICATION.child(post.uid!).childByAutoId().key
                            let newNotificationReference = NotificationObserver().REF_NOTIFICATION.child(post.uid!).child(newNotificationId)
                            newNotificationReference.setValue(["from": UserObserver().CURRENT_USER!.uid, "object_id": newSelf.postId, "type": "comment", "time_stamp": timestamp])
                            newNotificationReference.setValue(["from": UserObserver().CURRENT_USER!.uid, "object_id": newSelf.postId!, "type": "comment", "time_stamp": timestamp])
                            self?.loadComments()
                        }
                        
                    })
                })
            
            // update comment_count in posts.id
            let postCountRef = DatabaseReferences().REF_POSTS.child(newSelf.postId).child("comment_count")
            postCountRef.setValue(newSelf.comments.count+1)
            
            self?.empty()
            self?.view.endEditing(true)
        })
    }
    
    func empty() {
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Comment_VisitUserProfileSegue" {
            guard let profileVC = segue.destination as? ProfileViewController, let user = sender as? UserModel else {
                return
            }
            profileVC.user = user
        }
        
        if segue.identifier == "commentToHastagSegue" {
            guard let hashTagVC = segue.destination as? HashTagViewController, let tag = sender as? String else {
                return
            }
            hashTagVC.tag = tag
        }
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentCellDelegate {
    func goToProfileUserVC(userId: String) {
        // Present ProfileViewController
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "commentToHastagSegue", sender: tag)
    }
}
