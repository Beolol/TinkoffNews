//
//  DataManager.swift
//  TinkoffNews
//
//  Created by user on 23.07.17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {

    public static let manager = DataManager()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    private let newsUrlString = "https://api.tinkoff.ru/v1/news"
    private let descriptionNewsUrlString = "https://api.tinkoff.ru/v1/news_content?id="
    
    private var newsUpdated: (() -> Void)?
    
    // MARK:  - News download
    public func getNews(completionHandler: @escaping () -> Void) {
        
        let url = URL(string: newsUrlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    if let payloads = json["payload"] as? [[String:Any]] {
                        let newsArray = self.parsePayload(payloads)
                        
                        self.newsUpdated = completionHandler
                        self.updateDataBaseWithNews(newsArray)
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    fileprivate func parsePayload(_ payloads: [[String:Any]]) -> [NewsData] {
        var newsArray = [NewsData]()
        
        for payload in payloads {
            var id: String?
            var name: String?
            var text: String?
            var pubDate: Date?
            
            if let theId = payload["id"] as? String {
                id = theId
            }
            if let theName = payload["name"] as? String {
                name = theName
            }
            if let theText = (payload["text"] as? String)?.html2String {
                text = theText
            }
            if let publicationDate = payload["publicationDate"] as? [String:Any] {
                if let thePubDate = publicationDate["milliseconds"] as? UIntMax {
                    pubDate = Date(milliseconds: thePubDate)
                }
            }
            
            if (id != nil) && (name != nil) && (text != nil) && (pubDate != nil) {
                newsArray.append(NewsData(id: id!, name: name!, text: text!, pubDate: pubDate!))
            }
        }
        
        return newsArray
    }
    
    
    fileprivate func updateDataBaseWithNews(_ newsData: [NewsData]) {
        
        container?.performBackgroundTask{ context in
            for newsInfo in newsData {
                _ = try? News.findOrCreateNews(newsInfo, in: context)
                
            }
            try? context.save()
            
            if let complited = self.newsUpdated {
                context.perform {
                    complited()
                }
            }
        }
    }
    
    // MARK: - Description news download
    
    public func getDescriptionNewsWithId(_ id: String, completionHandler: @escaping (String) -> Void) {
        
        let url = URL(string: descriptionNewsUrlString + id)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "error")
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    if let payload = json["payload"] as? [String:Any] {
                        if let content = (payload["content"] as? String)?.html2String {
                            
                            DispatchQueue.main.sync {
                                completionHandler(content)
                            }
                        }
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
}
