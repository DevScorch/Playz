//
//  ViewController.swift
//  Playz
//
//  Created by Johan on 27-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // DEVSCORCH: Variables
    
    var selectedIndex: Int = 1
    let viewControllerIdentifiers = ["FeedViewController", "SearchViewController", "JournalViewController", "AddContentViewController", "ProfileViewController"]
    
    // DEVSCORCH: IBOutlets
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet var buttons: [UIButton]!
    let buttonImageNames = ["home", "search", "news", "newpost", "avatar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Jaaster: Sorting buttons in array to be consistent with the Interface Builder.
        buttons.sort {$0.tag < $1.tag }
        // DEVSCORCH: Storyboard Setup
        didButtonPress(buttons[0])
        setupDefaultChildViewController()
    }
    
    func setupDefaultChildViewController() {
        if let vc = viewController(from: 0) {
            presentChildViewController(vc: vc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func didButtonPress(_ sender: UIButton) {
        let newIndex = sender.tag
        
        if newIndex == selectedIndex {
            return
        }
        
        handleButtonUI(index: newIndex)
        
        guard let vc = viewController(from: newIndex) else {
            return
        }
        
        childViewControllers.forEach {
            $0.willMove(toParentViewController: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParentViewController()
            $0.dismiss(animated: false, completion: nil)
        }
        presentChildViewController(vc: vc)
    }
    
    func presentChildViewController(vc: UIViewController) {
        addChildViewController(vc)
        vc.view.frame = mainView.bounds
        mainView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    func handleButtonUI(index: Int) {
        switchButton(index: index)
        self.selectedIndex = index
    }
    
    func switchButton(index: Int) {
        buttons[index].setImage(UIImage(named: buttonImageNames[index] + "-gold"), for: .normal)
        buttons[selectedIndex].setImage(UIImage(named: buttonImageNames[selectedIndex] + "-white"), for: .normal)
    }
    
    func viewController(from index: Int) -> UIViewController? {
        let id = viewControllerIdentifiers[index]
        return storyboard?.instantiateViewController(withIdentifier: id)
    }
    
}
