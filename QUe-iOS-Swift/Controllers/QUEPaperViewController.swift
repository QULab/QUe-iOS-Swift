//
//  QUEPaperViewController.swift
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

class QUEPaperViewController: UIViewController {
    
    struct StoryboardConstants {
        static let identifier = "QUEPaperViewController"
        static let segueIdentifier = "showPaper"
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var metaView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var abstractTitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var roomImageView: UIImageView!
    
    var session: Session!
    var paper: Paper!
    var realm: Realm!
    
    override func viewDidLoad() {
        
        self.metaView.backgroundColor = ThemeManager.currentTheme().secondaryColor
        
        self.titleLabel.text = paper.title
        
        realm = try! Realm()
        
        authorLabel.text = paper.authors.reduce("") {
            authorList,author in
            let separator = (author == paper.authors.last) ? "" : ", "
            return "\(authorList!)\(author.fullName)\(separator)"
        }
                
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, HH:mm"
        let start = dateFormatter.stringFromDate(paper.start)
        dateFormatter.dateFormat = "HH:mm"
        let end = dateFormatter.stringFromDate(paper.end)
        timeLabel.text = start + " - " + end
        timeImageView.tintColor = ThemeManager.currentTheme().mainColor
        
        self.roomLabel.text = session.room
        roomImageView.tintColor = ThemeManager.currentTheme().mainColor
        self.abstractTitleLabel.text = NSLocalizedString("Abstract", comment: "")
        self.textView.text = paper.abstract
        
        let favoriteImageName = paper.favorite ? "StarSelected" : "Star";
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: favoriteImageName),
            style: .Plain,
            target: self,
            action: #selector(QUEPaperViewController.toggleFavorite))
        self.navigationItem.rightBarButtonItem?.tintColor = ThemeManager.currentTheme().mainColor
    }
    
    func toggleFavorite() {
        try! Realm().write {
            self.paper.favorite = !self.paper.favorite
        }
        
        if (self.paper.favorite) {
            QUECalendarUtility().addPaperToCalendar(self.paper, session: self.session)
        } else {
            QUECalendarUtility().removePaperFromCalendar(self.paper)
        }
        
        let favoriteImageName = paper.favorite ? "StarSelected" : "Star";
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: favoriteImageName)
    }
}