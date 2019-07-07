//
//  WebViewController.swift
//  Playz
//
//  Created by Joriah Lasater on 7/14/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
    var urlRequest: URLRequest?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Activity.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!) {
        Activity.stopAnimating()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // add activity
        self.webView.addSubview(self.Activity)
        self.Activity.startAnimating()
        self.webView.navigationDelegate = self
        self.Activity.hidesWhenStopped = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let urlRequest = urlRequest {
            print(urlRequest.url!)
            webView.load(urlRequest)

        }
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
