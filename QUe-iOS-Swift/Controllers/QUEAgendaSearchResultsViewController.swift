//
//  QUEAgendaSearchResultsViewController.swift
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

enum FilterScope {
    case Session
    case Paper
}

class QUEAgendaSearchResultsViewController: UITableViewController {
    struct StoryboardConstants {
        static let identifier = "QUEAgendaSearchResultsViewController"
    }
    
    lazy var sections: [NSDate] = [NSDate]()
    let dateFormatter = NSDateFormatter()
    
    var visibleSessionResults: Results<Session>?
    lazy var sessionsBySection: [Results<Session>]  = [Results<Session>]()
    
    var visiblePaperResults: Results<Paper>?
    lazy var papersBySection: [Results<Paper>]  = [Results<Paper>]()
    
    var filterScope: FilterScope = .Session
    var filterString: String? = nil {
        didSet {
            switch filterScope {
            case .Session:
                if filterString == nil || filterString!.isEmpty {
                    visibleSessionResults = try! Realm().objects(Session).sorted("title")
                }
                else {
                    let filterPredicate = NSPredicate(format: "title CONTAINS[c] %@", filterString!)
                    visibleSessionResults = try! Realm().objects(Session).filter(filterPredicate).sorted("title")
                }
            case .Paper:
                if filterString == nil || filterString!.isEmpty {
                    visiblePaperResults = try! Realm().objects(Paper).sorted("title")
                } else {
                    let words = filterString!.componentsSeparatedByString(" ");
                    let predicateList = words.map({ (word: String) -> NSPredicate in
                        return NSPredicate(format: "(title CONTAINS[c] %@) OR (abstract CONTAINS[c] %@)", word,word)
                    })
                    let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:predicateList)
                    
                    visiblePaperResults = try! Realm().objects(Paper).filter(filterPredicate).sorted("title")
                }   
            }
            
            sessionsBySection.removeAll()
            papersBySection.removeAll()
            switch filterScope {
            case .Session:
                sections = Array(Set(visibleSessionResults!.valueForKey("start") as! [NSDate])).sort({ $0.compare($1) == NSComparisonResult.OrderedAscending })
                for section in sections {
                    let predicate = NSPredicate(format: "start = %@", section)
                    sessionsBySection.append(visibleSessionResults!.filter(predicate))
                }
            case .Paper:
                sections = Array(Set(visiblePaperResults!.valueForKey("start") as! [NSDate])).sort({ $0.compare($1) == NSComparisonResult.OrderedAscending })
                for section in sections {
                    let predicate = NSPredicate(format: "start = %@", section)
                    papersBySection.append(visiblePaperResults!.filter(predicate))
                }
            }
    
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch filterScope {
        case .Session:
            return sessionsBySection[section].count
        case .Paper:
            return papersBySection[section].count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(QUEAgendaTableViewCell.StoryboardConstants.identifier, forIndexPath: indexPath) as! QUEAgendaTableViewCell
        
        switch filterScope {
        case .Session:
            configureSessionCell(indexPath, cell: cell)
        case .Paper:
            configurePaperCell(indexPath, cell: cell)
        }
        
        return cell
    }
    
    func configureSessionCell(indexPath: NSIndexPath, cell: QUEAgendaTableViewCell) {
        let session = sessionsBySection[indexPath.section][indexPath.row]
        
        if let sessionColor = Theme.sessionType(rawValue: session.type)?.color {
            cell.separatorView.backgroundColor = sessionColor
        } else {
            cell.separatorView.backgroundColor = ThemeManager.currentTheme().mainColor
        }
        
        cell.titleLabel.text = session.title
        cell.subtitleLabel.text = session.room
        
        dateFormatter.dateFormat = "HH:mm"
        cell.timeBeginLabel.text = dateFormatter.stringFromDate(session.start)
        cell.timeEndLabel.text = dateFormatter.stringFromDate(session.end)
        
        let date = NSDate()
        if (date.compare(session.end) == NSComparisonResult.OrderedDescending) {
            cell.state = .Past
        } else if (date.compare(session.start) == NSComparisonResult.OrderedAscending) {
            cell.state = .Future
        } else if (date.compare(session.start) == NSComparisonResult.OrderedDescending &&
            date.compare(session.end) == NSComparisonResult.OrderedAscending) {
                cell.state = .Present
        } else {
            cell.state = .Future
        }
    }
    
    func configurePaperCell(indexPath: NSIndexPath, cell: QUEAgendaTableViewCell) {
        let paper = papersBySection[indexPath.section][indexPath.row]
        let session = paper.session.first!
        
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
        
        dateFormatter.dateFormat = "HH:mm"
        cell.timeBeginLabel.text = dateFormatter.stringFromDate(paper.start)
        cell.timeEndLabel.text = dateFormatter.stringFromDate(paper.end)
        
        let date = NSDate()
        if (date.compare(paper.end) == NSComparisonResult.OrderedDescending) {
            cell.state = .Past
        } else if (date.compare(paper.start) == NSComparisonResult.OrderedAscending) {
            cell.state = .Future
        } else if (date.compare(paper.start) == NSComparisonResult.OrderedDescending &&
            date.compare(paper.end) == NSComparisonResult.OrderedAscending) {
                cell.state = .Present
        } else {
            cell.state = .Future
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = sections[section]
        dateFormatter.dateFormat = "EEEE, HH:mm"
        
        return dateFormatter.stringFromDate(date)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow
        if (segue.identifier == QUESessionTableViewController.StoryboardConstants.segueIdentifier) {
            let session =  sessionsBySection[indexPath!.section][indexPath!.row]
            let sessionController = segue.destinationViewController as! QUESessionTableViewController
            sessionController.session = session
        } else if (segue.identifier == QUEPaperViewController.StoryboardConstants.segueIdentifier) {
            let paper =  papersBySection[indexPath!.section][indexPath!.row]
            let paperController = segue.destinationViewController as! QUEPaperViewController
            paperController.session = paper.session.first
            paperController.paper = paper
        }
    }
}

extension QUEAgendaSearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterString = searchController.searchBar.text
    }
}

extension QUEAgendaSearchResultsViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            filterScope = .Session
        case 1:
            filterScope = .Paper
        default:
            filterScope = .Session
        }
        
        filterString = filterString!
    }

}