//
//  ViewControllerExtention.swift
//  Playz
//
//  Created by Vincent Pacquet on 10/2/18.
//  Copyright © 2018 Devmans. All rights reserved.
//
// Extension to UIView Controller to display spinner while waiting Async call to be over
// You initiate the spinner by calling displaySpinner
// eg: let spinnerVC = UIViewController.displaySpinner(onView: self.view)
// and remove it from the view by calling removeSpinner
// eg: UIViewController.removeSpinner(spinner: spinnerVC)

import UIKit

extension UIViewController {
    class func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.0)
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        //
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    class func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
