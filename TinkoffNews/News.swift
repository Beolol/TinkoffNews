//
//  News.swift
//  TinkoffNews
//
//  Created by user on 24.07.17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import CoreData

extension News {
    
    class func findOrCreateNews(_ newsInfo: NewsData, in context: NSManagedObjectContext) throws -> News {
        let request: NSFetchRequest<News> = News.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", newsInfo.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "News.findOrCreateNews Ouups")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let news = News(context: context)
        news.id = newsInfo.id
        news.name = newsInfo.name
        news.text = newsInfo.text
        news.date = newsInfo.pubDate as NSDate
        
        return news
    }
}
