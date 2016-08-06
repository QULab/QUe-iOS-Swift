//
//  QUEAuthorTableViewController.swift
//  QUe-iOS-Swift
//
/*
 Copyright 2016 Quality and Usability Lab, TU Berlin.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit
import RealmSwift

class QUEAuthorTableViewController: UITableViewController {
    
    struct StoryboardConstants {
        static let identifier = "QUEAuthorTableViewController"
        static let segueIdentifier = "showAuthor"
    }
    
    
    @IBOutlet weak var tableViewHeaderView: QUEAuthorTableViewHeaderView!
    var author: Author!
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableViewHeaderView.nameLabel.text = author.fullName
        tableViewHeaderView.affiliationLabel.text = author.affiliation
        
    }
        
    override func updateViewConstraints() {
        super.updateViewConstraints()
        sizeHeaderToFit()
    }
    
    
    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let indexPath = self.tableView.indexPathForSelectedRow,
            let paperController = segue.destinationViewController as? QUEPaperViewController else { return }
        
        let paper = author.papers[indexPath.row]
        paperController.session = paper.session.first
        paperController.paper = paper
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return author.papers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:QUEPaperTableViewCell = tableView.dequeueReusableCellWithIdentifier(QUEPaperTableViewCell.StoryboardConstants.identifier) as! QUEPaperTableViewCell
        let paper = author.papers[indexPath.row]
        
        
        cell.titleLabel.text = paper.title
        cell.subtitleLabel.text = paper.authors.reduce("") {
            authorList,author in
            let separator = (author == paper.authors.last) ? "" : ", "
            return "\(authorList!)\(author.fullName)\(separator)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let paper = self.author.papers[indexPath.row]
        let favoriteClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            try! Realm().write {
                paper.favorite = !paper.favorite
            }
            tableView.editing = false
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
        
        let favorite = "\u{2605}\n\(NSLocalizedString("Add Favorite", comment: ""))"
        let unfavorite = "\u{2606}\n\(NSLocalizedString("Remove Favorite", comment: ""))"
        
        let title = paper.favorite ? unfavorite : favorite
        let color = paper.favorite ? ThemeManager.currentTheme().actionRemoveColor : ThemeManager.currentTheme().actionAddColor
        
        let favoriteAction = UITableViewRowAction(style: .Default, title: title, handler: favoriteClosure)
        favoriteAction.backgroundColor = color
        
        return [favoriteAction]
    }
}

