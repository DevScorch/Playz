//
//  AddContentViewController.swift
//  Playz
//
//  Created by Johan on 28-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MediaPlayer
import AVKit
import Vision

class AddContentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, GameCategoriesCollectionCellDelegae {
    
    // DEVSCORCH: Outlets
    @IBOutlet weak var shareBtnOutlet: UIButton!
    @IBOutlet weak var uploadImg: UIImageView!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var playBtnOutlet: UIButton!
    @IBOutlet weak var hashTagBgView: UIView!
    @IBOutlet weak var hashTagTextView: UITextView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    // DEVSCORCH: Variables
    var gameCategories = [String]()
    var categoryTitles = ["Shooter", "Platform", "Fighting", "Beatm up", "Stealth", "survival", "Rhytm", "Survival", "Survival Horror", "Graphic Adventure", "Text Adventure", "Visual Novel", "Realtime Adventure", "MMORPG", "ActionRPG", "Rogue Like", "RPG", "RTS", "Strategy", "Battle Royal", "Sandbox", "Racing", "Football"]
    
    var objMoviePlayerController: AVPlayerViewController = AVPlayerViewController()
    var _playerLayer = AVPlayerLayer()
    
    let activityIndicator = CustomActivityIndicator()
    
    var isPlaying = false
    var player: AVPlayer?
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playBtnOutlet.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.uploadImgSelector))
        uploadImg.addGestureRecognizer(tapGesture)
        uploadImg.isUserInteractionEnabled = true
        
        shareBtnOutlet.isHidden = false
        videoContainer.isHidden = true
        playBtnOutlet.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func playerView() {
        player = AVPlayer(url: videoUrl!)
        let playerLayer = AVPlayerLayer(player: player)
        _playerLayer = playerLayer
        
        _playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        _playerLayer.frame = videoContainer.bounds
        
        videoContainer.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        //player?.play()
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        videoContainer.layoutIfNeeded()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.pause()
        player?.seek(to: kCMTimeZero)
        
        playBtnOutlet.isHidden = false
        isPlaying = false
        
        let image = UIImage(named: "ReplayBtn") as UIImage?
        playBtnOutlet.setImage(image, for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        //Player rdy rendering
        if keyPath == "currentItem.loadedTimeRanges" {
            playBtnOutlet.isHidden = false
        }
    }
    
    @objc func handlePause() {
        
        if isPlaying {
            player?.pause()
            
            let image = UIImage(named: "PlayBtn") as UIImage?
            playBtnOutlet.setImage(image, for: .normal)
        } else {
            player?.play()
            
            let image = UIImage(named: "PauseBtn") as UIImage?
            playBtnOutlet.setImage(image, for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    func handlePost() {
        if videoContainer.isHidden == false {
            self.shareBtnOutlet.isHidden = false
            self.playBtnOutlet.isHidden = false
        } else {
            self.shareBtnOutlet.isHidden = false
            self.playBtnOutlet.isHidden = true
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func uploadImgSelector() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.movie"]
        pickerController.allowsEditing = true
        pickerController.videoMaximumDuration = 30.0
        present(pickerController, animated: true, completion: nil)
        
        //show ActivityIndicator
        activityIndicator.showActivityIndicator(uiView: self.view)
        
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.title = "Choose Video"
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            //hide ActivityIndicator
            self.activityIndicator.hideActivityIndicator(uiView: self.view)
        }
    }
    
    //DEVSCORCH: Vision and CoreML Functions
    
    func detect(image: UIView) throws {
        let model = try VNCoreMLModel(for:converted().model)
        
        let request = VNCoreMLRequest(model: model, completionHandler: {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
            print("\(topResult.identifier) + confidence \(topResult.confidence)")
            }
        })
        
        let handler = VNImageRequestHandler(cgImage: image.cgImage, options: <#T##[VNImageOption : Any]#>)
    }
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        if let selectedMediaURL = info["UIImagePickerControllerMediaURL"] as? URL {
            self.dismiss(animated: true) {
                self.videoUrl = selectedMediaURL
                
                self.videoContainer.isHidden = false
                
                self.handlePost()
                self.playerView()
                
                self.uploadImg.image = self.getThumbnailFrom(path: selectedMediaURL)
                //self.clean()
                
                //hide ActivityIndicator
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
            }
        }
    }
    
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    @IBAction func postWindowBtnPressed(_ sender: Any) {
        if videoUrl == nil {
            let error = "You need to select a video."
            let alert = UIAlertController(title: "Incomplete posting", message: error, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else {
        if let thumbnailImg = self.uploadImg.image, let imageData = UIImageJPEGRepresentation(thumbnailImg, 0.1) {
            let ratio = thumbnailImg.size.width / thumbnailImg.size.height
            
            //show ActivityIndicator
            activityIndicator.showActivityIndicator(uiView: self.view)
            
            HelperService.uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio: ratio, caption: self.hashTagTextView.text, categories: gameCategories, onSuccess: {  [weak self] in
                //hide ActivityIndicator
                if let newSelf = self {
                    self?.activityIndicator.hideActivityIndicator(uiView: newSelf.view)
                }
                
                self?.clean()
                self?.storyboard?.instantiateViewController(withIdentifier: "FeedViewController")
            })
        }
        }
    }
    
    @IBAction func cancel_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        for view in videoContainer.subviews {
            view.removeFromSuperview()
        }
        
        self.player!.pause()
        self._playerLayer.removeFromSuperlayer()
        
        uploadImg.image = nil
        //
        self.videoContainer.isHidden = true
        self.shareBtnOutlet.isHidden = true
        self.playBtnOutlet.isHidden = true
        
        self.isPlaying = false
        let image = UIImage(named: "PlayBtn") as UIImage?
        playBtnOutlet.setImage(image, for: .normal)
        
        let uploadBtnImage = UIImage(named: "camera-roll") as UIImage?
        self.uploadImg.image = uploadBtnImage
        
        hashTagTextView.text = ""
        
        categoryCollectionView.reloadData()
        
        gameCategories.removeAll()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? GameCategoriesCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        let category = categoryTitles[indexPath.item]
        
        cell.category = category
        
        cell.categoryBtn.isSelected = false
        if gameCategories.index(of: category) != nil {
            print ("\(category)")
            cell.categoryBtn.isSelected = true
        }
        
        return cell
    }
    
    //delegate
    func selectedGameCategory(category: String, shouldAdd: Bool) {
        if shouldAdd {
            self.gameCategories.append(category)
        } else {
            let categoryToRemove = category
            for object in self.gameCategories where object == categoryToRemove {
                self.gameCategories.remove(at: self.gameCategories.index(of: categoryToRemove)!)
            }
        }
    }
}
