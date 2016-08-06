//
//  QUEAgendaTableViewController.swift
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

import UIKit
import Foundation
import Alamofire
import RealmSwift

class QUEAgendaTableViewController: UITableViewController {
    
    struct StoryboardConstants {
        static let identifier = "QUEAgendaTableViewController"
    }

    let dateFormatter = NSDateFormatter()
    var notificationToken: NotificationToken?
    
    var currentDay: NSDate!
    lazy var sections: [NSDate] = [NSDate]()
    var sessions: Results<Session>!
    lazy var sessionsBySection: [Results<Session>]  = [Results<Session>]()
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0

        dateFormatter.dateFormat = "HH:mm"
        
        setup()
        
        notificationToken = try! Realm().addNotificationBlock { notification, realm in
            self.tableView.reloadData()
        }
    }
    
    func setup() {
        guard let _ = sessions else {
            return
        }
        
        sections = Array(Set(sessions.valueForKey("start") as! [NSDate])).sort({ $0.compare($1) == NSComparisonResult.OrderedAscending })
        sessionsBySection.removeAll()
        for section in sections {
            let predicate = NSPredicate(format: "start = %@", section)
            sessionsBySection.append(sessions.filter(predicate))
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow
        
        let session =  sessionsBySection[indexPath!.section][indexPath!.row]
        let sessionController = segue.destinationViewController as! QUESessionTableViewController
        sessionController.session = session
    }
    
    func scrollToActiveSessions(date: NSDate) {
        let sortedDates = sections.sort { (d1, d2) -> Bool in
            let t1 = abs(d1.timeIntervalSinceDate(date))
            let t2 = abs(d2.timeIntervalSinceDate(date))
            return t1 <= t2
        }
        
        let indexPath = NSIndexPath(forRow: 0, inSection: sections.indexOf(sortedDates.first!)!)
        tableView.scrollToRowAtIndexPath(indexPath,
            atScrollPosition: .Top,
            animated: true)
        
    }
    
    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionsBySection[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("agendaTableViewCell", forIndexPath: indexPath) as! QUEAgendaTableViewCell
        
        configureCell(indexPath, cell: cell)
        
        return cell
    }
    
    func configureCell(indexPath: NSIndexPath, cell: QUEAgendaTableViewCell) {
        let session = sessionsBySection[indexPath.section][indexPath.row]
        
        cell.titleLabel.text = session.title
        cell.subtitleLabel.text = session.room
        
        if let sessionColor = Theme.sessionType(rawValue: session.type)?.color {
            cell.separatorView.backgroundColor = sessionColor
        } else {
            cell.separatorView.backgroundColor = ThemeManager.currentTheme().mainColor
        }
        
        let numPaperFavorites = session.papers.reduce(0) { $0 + ($1.favorite ? 1 : 0) }
        if session.favorite && numPaperFavorites > 0 {
            cell.content = "\u{2605} \u{2606}"
        } else if session.favorite {
            cell.content = "\u{2605}"
        } else if numPaperFavorites > 0 {
            cell.content = "\u{2606}"
        } else {
            cell.content = ""
        }
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = sections[section]
        
        return dateFormatter.stringFromDate(date)
    }
}