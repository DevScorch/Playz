//
//  NewsViewController.swift
//  Playz
//
//  Created by Jaaster on 6/2/18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import FeedKit

class NewsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var news: NewsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = news?.message
        descriptionTextView.text = news?.description
        dateLabel.text = news?.datetime.formateDate()
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
