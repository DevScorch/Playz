//
//  NewsTableViewCell.swift
//  Playz
//
//  Created by Johan on 29-06-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import FeedKit

protocol NewsTableViewCellDelegate: class {
    func presentNews(news: RSSFeedItem)
    func presentNews(news: NewsModel)
}

class NewsTableViewCell: UITableViewCell {

    // DEVSCORCH: IBOutlets
    
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var newstextView: UITextView!
    weak var delegate: NewsTableViewCellDelegate?
    
    var rssNews: RSSFeedItem? {
        willSet {
            guard let newValue = newValue else {
                return
            }
            
            firebaseNews = nil
            newsTitleLabel.text = newValue.title
            timeLabel.text = newValue.pubDate?.formateDate()
            newstextView.text = newValue.description
        }
    }
    
    var firebaseNews: NewsModel? {
        willSet {
            guard let newValue = newValue else {
                return
            }
            
            rssNews = nil
            newsTitleLabel.text = newValue.message
            timeLabel.text = newValue.datetime.formateDate()
            newstextView.text = newValue.description
        }
    }
    
    func formateDate(date: Date?) -> String {
        guard let date = date else {
            return "N/A"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newstextView.text = ""
        setupGestureRecognizer()
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedInsideCell))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc func tappedInsideCell() {
        
        if let rssNews = rssNews {
            delegate?.presentNews(news: rssNews)
        } else if let firebaseNews = firebaseNews {
            delegate?.presentNews(news: firebaseNews)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
