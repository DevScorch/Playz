//
    //  SettingTableViewController.swift
    //  Playz
    //
    //  Created by LangsemWork on 05.05.2018.
    //  Copyright © 2018 Devmans. All rights reserved.
    //
    
    import UIKit
    import Foundation
    import Firebase
    
    protocol SettingVCDelegate: class {
        func updateUserInfor()
    }
    
    class SettingTableViewController: UITableViewController {
        
        @IBOutlet weak var usernnameTextField: UITextField!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var profileImageView: UIImageView!
        
        weak var delegate: SettingVCDelegate?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.title = "Edit Profile"
            usernnameTextField.delegate = self
            emailTextField.delegate = self
            fetchCurrentUser()
        }
        
        func fetchCurrentUser() {
            UserObserver().observeCurrentUser { [weak self] (user) in
                self?.usernnameTextField.text = user.username
                self?.emailTextField.text = user.email
            }
        }
        @IBAction func saveBtn_TouchUpInside(_ sender: Any) {
            
             AuthService.updateUserSettings(username: usernnameTextField.text!, email: emailTextField.text!, onSuccess: { [weak self] in
                
                self?.delegate?.updateUserInfor()
                self?.dismiss(animated: true, completion: nil)
                
            }) { (errorMessage) in
                print (errorMessage as Any)
            }
        }
        
        @IBAction func logOut(_ sender: Any) {
            try? Auth.auth().signOut()
            let signInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInViewController, animated: false, completion: nil)
        }
        @IBAction func changeProfileBtn_TouchUpInside(_ sender: Any) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            present(pickerController, animated: true, completion: nil)
        }
        
        @IBAction func cancelBtn_touchUpInside(_ sender: Any) {
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
            print("did Finish Picking Media")
            if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                profileImageView.image = image
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    extension SettingTableViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            print("return")
            textField.resignFirstResponder()
            return true
        }
    }
    
