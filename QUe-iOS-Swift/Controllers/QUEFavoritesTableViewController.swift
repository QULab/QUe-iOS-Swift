//
//  QUEFavoritesTableViewController.swift
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

class QUEFavoritesTableViewController: UITableViewController {
    
    struct StoryboardConstants {
        static let identifier = "QUEFavoritesTableViewController"
    }
    
    var favorites = [AnyObject]()
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        
        dateFormatter.dateFormat = "HH:mm"
        
        favorites = setupFavorites()
    }
    
    func setupFavorites() -> [AnyObject] {
        let predicate = NSPredicate(format: "favorite == %@", true)
        
        let paperFavorites = try! Realm().objects(Paper).filter(predicate).sorted("start")
        let sessionFavorites = try! Realm().objects(Session).filter(predicate).sorted("start")
        
        var combinedFavorites = [AnyObject]()
        combinedFavorites.appendContentsOf(paperFavorites.map({$0}))
        combinedFavorites.appendContentsOf(sessionFavorites.map({$0}))
        
        combinedFavorites.sortInPlace { (first, second) -> Bool in
            var firstDate:NSDate = NSDate()
            var secondDate:NSDate = NSDate()
            
            if let paper = first as? Paper {
                firstDate = paper.start
            } else if let session = first as? Session{
                firstDate = session.start
            }
            
            if let paper = second as? Paper {
                secondDate = paper.start
            } else if let session = second as? Session{
                secondDate = session.start
            }
            
            return firstDate.compare(secondDate) == .OrderedAscending
        }
        

        return combinedFavorites
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:QUEAgendaTableViewCell = tableView.dequeueReusableCellWithIdentifier(QUEAgendaTableViewCell.StoryboardConstants.identifier) as! QUEAgendaTableViewCell
        
        let dayDateFormatter = NSDateFormatter()
        dayDateFormatter.dateFormat = "EEE"
        
        if let favoritePaper = favorites[indexPath.row] as? Paper {
            cell.titleLabel.text = favoritePaper.title
            cell.subtitleLabel.text = favoritePaper.authors.reduce("") {
                authorList,author in
                let separator = (author == favoritePaper.authors.last) ? "" : ", "
                return "\(authorList!)\(author.fullName)\(separator)"
            }
            
            cell.timeBeginLabel.text = dateFormatter.stringFromDate(favoritePaper.start)
            cell.timeEndLabel.text = dateFormatter.stringFromDate(favoritePaper.end)
            cell.content = NSLocalizedString("Paper", comment: "")
            cell.favoriteLabel.text = dayDateFormatter.stringFromDate(favoritePaper.start)
            
            if let sessionColor = Theme.sessionType(rawValue: favoritePaper.session.first!.type)?.color {
                cell.separatorView.backgroundColor = sessionColor
            } else {
                cell.separatorView.backgroundColor = ThemeManager.currentTheme().mainColor
            }
        } else if let favoriteSession = favorites[indexPath.row] as? Session {
            cell.titleLabel.text = favoriteSession.title
            cell.subtitleLabel.text = favoriteSession.room
            
            cell.timeBeginLabel.text = dateFormatter.stringFromDate(favoriteSession.start)
            cell.timeEndLabel.text = dateFormatter.stringFromDate(favoriteSession.end)
            cell.content = NSLocalizedString("Session", comment: "")
            cell.favoriteLabel.text = dayDateFormatter.stringFromDate(favoriteSession.start)
            
            if let sessionColor = Theme.sessionType(rawValue: favoriteSession.type)?.color {
                cell.separatorView.backgroundColor = sessionColor
            } else {
                cell.separatorView.backgroundColor = ThemeManager.currentTheme().mainColor
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let favoriteClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            try! Realm().write {
                if let paper = self.favorites[indexPath.row] as? Paper {
                    paper.favorite = false
                    QUECalendarUtility().removePaperFromCalendar(paper)
                } else if let session = self.favorites[indexPath.row] as? Session {
                    session.favorite = false
                    QUECalendarUtility().removeSessionFromCalendar(session)
                }
            }
            
            self.favorites = self.setupFavorites()
            
            tableView.editing = false
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        let color = ThemeManager.currentTheme().actionRemoveColor
        let title = "\u{2606}\n\(NSLocalizedString("Remove Favorite", comment: ""))"
        
        let favoriteAction = UITableViewRowAction(style: .Default, title: title, handler: favoriteClosure)
        favoriteAction.backgroundColor = color
        
        return [favoriteAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let paper = favorites[indexPath.row] as? Paper {
            performSegueWithIdentifier(QUEPaperViewController.StoryboardConstants.segueIdentifier, sender: paper)
        } else if let session = favorites[indexPath.row] as? Session {
            performSegueWithIdentifier(QUESessionTableViewController.StoryboardConstants.segueIdentifier, sender: session)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == QUEPaperViewController.StoryboardConstants.segueIdentifier {
            let viewController = segue.destinationViewController as? QUEPaperViewController
            let paper = sender as! Paper
            viewController?.paper = paper
            viewController?.session = paper.session.first!
        } else if segue.identifier == QUESessionTableViewController.StoryboardConstants.segueIdentifier {
            let viewController = segue.destinationViewController as? QUESessionTableViewController
            viewController?.session = sender as! Session
        }
    }
}
