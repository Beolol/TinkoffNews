//
//  NewsDescriptionViewController.swift
//  TinkoffNews
//
//  Created by user on 24.07.17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit


class NewsDescriptionViewController: UIViewController {
    
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newsTextView: UITextView!
    
    var selectedNewsId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTextView.text = ""
        if let id = self.selectedNewsId {
            DataManager.manager.getDescriptionNewsWithId(id, completionHandler: { [weak self] in
                self?.newsTextView.text = $0.html2String
                self?.downloadIndicator.stopAnimating()
            })
                
        }
    }

}
