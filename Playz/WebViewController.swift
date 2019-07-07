//
//  WebViewController.swift
//  Playz
//
//  Created by Joriah Lasater on 7/14/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var urlRequest: URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let urlRequest = urlRequest {
            webView.load(urlRequest)
        }
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
