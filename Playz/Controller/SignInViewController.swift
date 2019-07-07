//
//  SignInViewController.swift
//  Playz
//
//  Created by Johan on 30-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import TwitterKit
import AVFoundation

// Vince: Added UITextFieldDelegate
class SignInViewController: UIViewController, FUIAuthDelegate, UITextFieldDelegate {
    
    // DEVSCORCH: Variables
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var authUI: FUIAuth!
    let facebookFBUILoginProvider = FUIFacebookAuth()
    let twitterLoginProvider = FUITwitterAuth()
    let googleloginProvider = FUIGoogleAuth()
    let videoString: String? = Bundle.main.path(forResource: "BackgroundVideo", ofType: "mp4")
    var email: String = ""
    
    // DEVSCORCH: IBOutlets
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var SignInStackview: UIStackView!
    @IBOutlet weak var ButtonStackview: UIStackView!
    
    // DEVSCORCH: Overriding Functions
    
    // Vince
    var signInCompletionBlock: FIRAuthProviderSignInCompletionBlock?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    // Vince
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let currentUser = Auth.auth().currentUser{
            self.performSegue(withIdentifier: "MainViewControllerSegue", sender: nil)
            return
        }
        PlayVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Vince
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        PlayVideo()
        FirebaseInform()
        TextFieldHandler()
    }
    
    // DEVSCORCH: Functions
    
    func PlayVideo() {
        if let localUrl = videoString {
            let localVideoUrl = URL(fileURLWithPath: localUrl)
            
            player = AVPlayer(url: localVideoUrl as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer.frame = videoView.bounds
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
            videoView.layer.addSublayer(playerLayer)
            videoView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            player.play()
        }
    }
    
    // DEVSCORCH: Keyboard Handler
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func TextFieldHandler() {
        //Color for placeholder text
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    }
    
    func FirebaseInform() {
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.isSignInWithEmailHidden = true
        signInCompletionBlock = { (authcredential, error, authresultcallback) in
            if error != nil {
                self.showAlertMessage("Sign in error!", message: error.debugDescription)
                return
            }
            if authcredential != nil {
                Auth.auth().signInAndRetrieveData(with: authcredential!, completion: { [weak self] (authdataresult, error) in
                    if error != nil {
                        self?.showAlertMessage("Sign in error!", message: error.debugDescription)
                        return
                    }
                    if authdataresult != nil {
                        print("Success login!")
                        self?.processLoggedInUser()
                    } else {
                        self?.showAlertMessage("Sign in error!", message: error.debugDescription)
                        return
                    }
                })
            } else {
                self.showAlertMessage("Sign in error!", message: error.debugDescription)
                return
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        guard let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String? else {
            return false
        }
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if error != nil {
            // ERROR
            return
        }
        processLoggedInUser()
    }
    
    @objc func playerItemReachEnd(notification: NSNotification) {
        player.seek(to: kCMTimeZero)
    }
    
    func processLoggedInUser() {
        if let user = Auth.auth().currentUser {
            let photoURL = user.photoURL?.absoluteString ?? ""
            let email = user.email ?? ""
            let displayName = user.displayName ?? ""
            
            print("Displayname \(displayName)")
            print("Email \(email)")
            print("Imageurl \(photoURL)")
            print("UID : \(user.uid)")
            
            AuthService.addUserToDatabaseTroughSocial(uid: user.uid, profilePictureUrl: photoURL, email: email, displayName: displayName) {
                self.performSegue(withIdentifier: "MainViewControllerSegue", sender: nil)
            }
        }
    }
    
    // DEVSCORCH: IBActions
    
    @IBAction func SignInButtonTapped(_ sender: UIButton) {
        let spinnerVC = UIViewController.displaySpinner(onView: self.view)

        if EmailValidation.validateEmail(emailAddress: emailTextField.text!) {
            AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
                UserObserver().observeCurrentUser { [weak self]  (user) in
                    KeychainService.saveEmail(token: user.email! as NSString)
                    if let newSelf = self {
                        KeychainService.savePassword(token: newSelf.passwordTextField.text! as NSString)
                    }
                }
                UIViewController.removeSpinner(spinner: spinnerVC)
                self.performSegue(withIdentifier: "MainViewControllerSegue", sender: nil)
            }, onError: { error in
                UIViewController.removeSpinner(spinner: spinnerVC)
                self.showAlertMessage("Login was unsuccesfull", message: error!)
            })
        } else {
            UIViewController.removeSpinner(spinner: spinnerVC)
            sender.pulse()
            showAlertMessage("Incorrect Email", message: "Please ensure that your email looks like name@host.domain.")
        }
    }

    @IBAction func googleBtnTapped(_ sender: Any) {
        self.authUI?.providers = [googleloginProvider]
        googleloginProvider.signIn(withDefaultValue: "", presenting: self, completion: signInCompletionBlock)
    }
    
    @IBAction func twitterButtonTapped(_ sender: Any) {
        self.authUI?.providers = [twitterLoginProvider]
        twitterLoginProvider.signIn(withDefaultValue: "", presenting: self, completion: signInCompletionBlock)
    }
    
    @IBAction func facebookButtonTapped(_ sender: AnyObject) {
        self.authUI?.providers = [facebookFBUILoginProvider]
        facebookFBUILoginProvider.signIn(withDefaultValue: "", presenting: self, completion: signInCompletionBlock)
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        // Create a standard UIAlertController
        let alertController = UIAlertController(title: "Forgot your password", message: "You forgot your password? No worries we are here to help. Just add your email and click send.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.textAlignment = .center
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Canelled")
        }
        
        // This action handles your confirmation action
        
        let confirmAction = UIAlertAction(title: "Send", style: .default) { _ in
            
        }
        
        // Add the actions, the order here does not matter
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // DEVSCORCH: ErrorHandling:
    
    func showAlertMessage(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
