//
//  ViewController.swift
//  TinkoffNews
//
//  Created by user on 23.07.17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import CoreData

class NewsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var isLoading = false
    
    var container:NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet{
            updateUI()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<News>?
    
    fileprivate var newsArray = [NewsData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action:#selector(NewsViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchedResultsController?.delegate = self
        isLoading = true
        DataManager.manager.getNews(completionHandler: { [weak self] in
    
            self?.isLoading = false
        })
        
    }
    
    func refresh(sender:AnyObject) {
        if isLoading {
            return
        }
        isLoading = true
        refreshControl.beginRefreshing()
        DataManager.manager.getNews(completionHandler: { [weak self] in
            
            self?.isLoading = false
            self?.refreshControl.endRefreshing()
        })
    }
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<News> = News.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchedResultsController = NSFetchedResultsController<News> (
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
        try? fetchedResultsController?.performFetch()
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNews" {
            if let descriptionVC = segue.destination as? NewsDescriptionViewController {
                let indexPath = self.tableView.indexPath(for: (sender as? UITableViewCell)!)
                descriptionVC.selectedNewsId = fetchedResultsController?.object(at: indexPath!).id
            }
        }
    }
}

extension NewsViewController : NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension NewsViewController : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!NewsTableViewCell
        
        if let news = fetchedResultsController?.object(at: indexPath) {
            cell.titleLabel.text = news.text
        }
        
        return cell
    }
}
