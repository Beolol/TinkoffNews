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
    @IBOutlet weak var newsTextViewHeight: NSLayoutConstraint!
    
    var selectedNewsId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTextView.text = ""
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            if let id = self.selectedNewsId {
                DataManager.manager.getDescriptionNewsWithId(id, completionHandler: { [weak self] content in
                    DispatchQueue.main.async {
                        self?.newsTextView.text = content.html2String
                        self?.downloadIndicator.stopAnimating()
                        self?.resizeView()
                    }
                })
                
            }
        }
    }

    private func resizeView() {
        
        
        let newWidth = self.view.frame.size.width - CGFloat(18)
        self.newsTextViewHeight.constant =
            CGFloat(ceilf(
                Float(self.newsTextView.sizeThatFits( CGSize(width: newWidth, height: CGFloat(10000.0) ) ).height)))
        self.view.layoutIfNeeded()
        
    }

}
