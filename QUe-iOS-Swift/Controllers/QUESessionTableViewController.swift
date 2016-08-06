//
//  QUESessionTableViewController.swift
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

class QUESessionTableViewController: UITableViewController {
    
    struct StoryboardConstants {
        static let identifier = "QUESessionTableViewController"
        static let segueIdentifier = "showSession"
    }
    
    
    @IBOutlet weak var tableViewHeaderView: QUESessionTableViewHeaderView!
    var session: Session!
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableViewHeaderView.backgroundColor = ThemeManager.currentTheme().secondaryColor
        
        tableViewHeaderView.titleLabel.text = session.title
        
        tableViewHeaderView.typeLabel.text = session.type_name
        if let sessionColor = Theme.sessionType(rawValue: session.type)?.color {
            tableViewHeaderView.typeView.backgroundColor = sessionColor
        } else {
            tableViewHeaderView.typeView.backgroundColor = ThemeManager.currentTheme().mainColor
        }
        
        dateFormatter.dateFormat = "HH:mm"
        tableViewHeaderView.timeLabel.text = dateFormatter.stringFromDate(session.start) + " - " + dateFormatter.stringFromDate(session.end)
        tableViewHeaderView.timeImageView.tintColor = ThemeManager.currentTheme().mainColor
        
        tableViewHeaderView.roomLabel.text = (session.room ?? "-")
        tableViewHeaderView.roomImageView.tintColor = ThemeManager.currentTheme().mainColor
        
        if let chair = session.chair {
            tableViewHeaderView.chairLabel.text = chair
            tableViewHeaderView.chairImageView.tintColor = ThemeManager.currentTheme().mainColor
        } else {
            tableViewHeaderView.chairLabel.removeFromSuperview()
            tableViewHeaderView.chairImageView.removeFromSuperview()
        }
        
        let favoriteImageName = session.favorite ? "StarSelected" : "Star";
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: favoriteImageName),
            style: .Plain,
            target: self,
            action: #selector(QUESessionTableViewController.toggleFavorite))
        self.navigationItem.rightBarButtonItem?.tintColor = ThemeManager.currentTheme().mainColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
    
    func toggleFavorite() {
        try! Realm().write {
            self.session.favorite = !self.session.favorite
        }
        
        if (self.session.favorite) {
            QUECalendarUtility().addSessionToCalendar(self.session)
        } else {
            QUECalendarUtility().removeSessionFromCalendar(self.session)
        }
        
        let favoriteImageName = session.favorite ? "StarSelected" : "Star";
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: favoriteImageName)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let indexPath = self.tableView.indexPathForSelectedRow,
            let paperController = segue.destinationViewController as? QUEPaperViewController else { return }
        
        let paper = session.papers[indexPath.row]
        paperController.session = session
        paperController.paper = paper
    }
    
    func actionItemTapped(item: UIBarButtonItem) {
        let alertController = UIAlertController(title: NSLocalizedString("Actions", comment: ""), message: nil, preferredStyle: .ActionSheet)
        
        let favoriteTitle = session.favorite ? NSLocalizedString("Remove from favorites", comment: "") : NSLocalizedString("Add to favorites", comment: "")
        let favoriteAction = UIAlertAction(title: favoriteTitle, style: .Default) { (alert: UIAlertAction) -> Void in
            try! Realm().write {
                self.session.favorite = !self.session.favorite
            }
            
            if (self.session.favorite) {
                QUECalendarUtility().addSessionToCalendar(self.session)
            } else {
                QUECalendarUtility().removeSessionFromCalendar(self.session)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
    
        alertController.addAction(favoriteAction)
        alertController.addAction(cancelAction)
        
        let popover = alertController.popoverPresentationController;
        if ((popover) != nil) {
            popover?.barButtonItem = item
            popover?.permittedArrowDirections = .Any
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.papers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:QUEAgendaTableViewCell = tableView.dequeueReusableCellWithIdentifier(QUEAgendaTableViewCell.StoryboardConstants.identifier) as! QUEAgendaTableViewCell
        let paper = session.papers[indexPath.row]
        
        if let sessionColor = Theme.sessionType(rawValue: session.type)?.color {
            cell.separatorView.backgroundColor = sessionColor
        } else {
            cell.separatorView.backgroundColor = ThemeManager.currentTheme().mainColor
        }
            
        
        cell.titleLabel.text = paper.title
        cell.subtitleLabel.text = paper.authors.reduce("") {
            authorList,author in
            let separator = (author == paper.authors.last) ? "" : ", "
            return "\(authorList!)\(author.fullName)\(separator)"
        }
        cell.content = paper.favorite ? "\u{2605}" : ""
        
        cell.timeBeginLabel.text = dateFormatter.stringFromDate(paper.start)
        cell.timeEndLabel.text = dateFormatter.stringFromDate(paper.end)
        
        if (NSDate().compare(session.end) == NSComparisonResult.OrderedDescending) {
            cell.state = .Past
        } else if (NSDate().compare(session.start) == NSComparisonResult.OrderedAscending) {
            cell.state = .Future
        } else if (NSDate().compare(session.start) == NSComparisonResult.OrderedDescending &&
            NSDate().compare(session.end) == NSComparisonResult.OrderedAscending) {
                cell.state = .Present
        } else {
            cell.state = .Future
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let paper = self.session.papers[indexPath.row]
        let favoriteClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            try! Realm().write {
                paper.favorite = !paper.favorite
            }
            
            if (paper.favorite) {
                QUECalendarUtility().addPaperToCalendar(paper, session: self.session)
            } else if (!(paper.calendarEventId ?? "").isEmpty) {
                QUECalendarUtility().removePaperFromCalendar(paper)
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