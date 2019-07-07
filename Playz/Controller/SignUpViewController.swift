//
//  SignUpViewController.swift
//  Playz
//
//  Created by Johan on 30-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

//Vince: Added UITextFieldDelegate
class SignUpViewController: UIViewController, UITextFieldDelegate {

    // DEVSCORCH: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageOutlet: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var registerBtnOutlet: UIButton!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    // Vince Add Outlet Scroll View (Already in the SB)
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    var categories = [CategoryModel]()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryView.isHidden = true
 
        // Vince
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let min = CGFloat(-20.0)
        let max = CGFloat(20.0)
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
        
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = min
        xMotion.maximumRelativeValue = max
        
        let motionEffect = UIMotionEffectGroup()
        motionEffect.motionEffects = [xMotion, yMotion]
        
        backgroundImage.addMotionEffect(motionEffect)
        
        handleTextField()
        
        //Gesture for the profileImage
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.gestureForProfileImage))
        profileImageOutlet.addGestureRecognizer(tapGesture)
        profileImageOutlet.isUserInteractionEnabled = true
        
        //Color for placeholder text
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "username",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        // Vince, monitor the keyboard showing up to scroll the view behind
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+200)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        scrollView.keyboardDismissMode = .onDrag
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCategories()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        // Vince
        super.touchesBegan(touches, with: event)
    }
    
    // Vince
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func registerBtnPressed(_ sender: Any) {
        
        //Register new user with firebase
        //makes reference to storage of profileimage
        view.endEditing(true)
        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        if let profilepicture = self.selectedImage, let imageData = UIImageJPEGRepresentation(profilepicture, 0.1) {
            
            // If the email address is wrong don't even round-trip to Firebase; display alert.
            if EmailValidation.validateEmail(emailAddress: emailTextField.text!) {
                
                AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData, onSuccess: { [weak self] in
                    print("Firebase registration successful")
                    if let newSelf = self {
                        /// Vince: Section to unhide if bypass the Firebase User Registration
///                KeychainService.saveEmail(token: emailTextField.text! as NSString)
///                KeychainService.savePassword(token: passwordTextField.text! as NSString)
///                categoryView.isHidden = false
///                for textView in [passwordTextField, usernameTextField, emailTextField] {
///                    textView?.isHidden = true
///                }
///                registerBtnOutlet.isHidden = true
                        KeychainService.saveEmail(token: newSelf.emailTextField.text! as NSString)
                        KeychainService.savePassword(token: newSelf.passwordTextField.text! as NSString)
                        newSelf.categoryView.isHidden = false
                        
                        for textView in [newSelf.passwordTextField, newSelf.usernameTextField, newSelf.emailTextField] {
                            textView?.isHidden = true
                        }
                        newSelf.registerBtnOutlet.isHidden = true
                        UIViewController.removeSpinner(spinner: spinnerVC)
                    }
                    
                }, onError: { (errorString) in
                    print(errorString as Any)
                    UIViewController.removeSpinner(spinner: spinnerVC)

                    let alert = UIAlertController(title: "Unsuccessful Registration", message: errorString, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)

                    alert.addAction(action)

                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                UIViewController.removeSpinner(spinner: spinnerVC)

                let error = "Please ensure that your email follows the format name@host.domain."
                let alert = UIAlertController(title: "Incorrect Email Format", message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            UIViewController.removeSpinner(spinner: spinnerVC)

            let error = "Please select an user image by tapping on the circle above the username field."
            let alert = UIAlertController(title: "Missing User Image", message: error, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Functions
    func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String) {
        let spinnerVC = UIViewController.displaySpinner(onView: self.view)
        //make a reference to the database with uniq id
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData, onSuccess: { [weak self] in
                //Show success to user for signup
                self?.performSegue(withIdentifier: "registerToMainMenu", sender: nil)
            }, onError: { (_) in
                //Show error
                UIViewController.removeSpinner(spinner: spinnerVC)
            })
        } else {
            //SHow error to the user
            UIViewController.removeSpinner(spinner: spinnerVC)
        }

    }
    
    //The code that handles the gesture and shows a picker
    @objc func gestureForProfileImage () {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc func handleSelectProfileImage () {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.inputFieldsDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.inputFieldsDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.inputFieldsDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func inputFieldsDidChange() {
        
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty, profileImageOutlet.image != nil else {
            
            registerBtnOutlet.setTitleColor(UIColor.gray, for: .normal)
            registerBtnOutlet.isEnabled = false
            
            return
        }
        
        registerBtnOutlet.setTitleColor(UIColor.white, for: .normal)
        registerBtnOutlet.isEnabled = true
    }
    
    //Vince: scroll view when keyboard is displayed
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        guard let nsValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue  else {
            return
        }
        let keyboardScreenEndFrame = nsValue.cgRectValue
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height+40, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @IBAction func doneChoosingCategories(_ sender: Any) {
        self.performSegue(withIdentifier: "registerToMainMenu", sender: nil)
    }
}

extension SignUpViewController: UICollectionViewDelegate, UICollectionViewDataSource, GameCategoriesCollectionCellDelegae {
    func selectedGameCategory(category: String, shouldAdd: Bool) {
        add(categoryTitle: category)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GameCategoriesCollectionCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        
        let category = categories[indexPath.item].title
        cell.category = category
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
}

// JAASTER: Choose Categories Extension

extension SignUpViewController {

    // JAASTER: Make button visible if a category exists for it
    
    func loadCategories() {
        categories.removeAll()
        CategoryObserver().fetchCategories { [weak self] (categoryModel) in
            self?.categories.append(categoryModel)
            self?.categoryCollectionView.reloadData()
        }
    }

    func add(categoryTitle: String) {
        FollowObserver().followAction(withCategory: categoryTitle)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImageOutlet.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
