//
//  QUEDatasource.swift
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
import RealmSwift
import Alamofire

public extension NSDate {
    var startOfDay: NSDate {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let timeZone = NSTimeZone.systemTimeZone()
        calendar.timeZone = timeZone
        
        return calendar.startOfDayForDate(self)
    }
    
    var endOfDay: NSDate {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let timeZone = NSTimeZone.systemTimeZone()
        calendar.timeZone = timeZone
        
        return calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: self, options: NSCalendarOptions())!
    }
}

class QUEDatasource: NSObject {
    let realm = try! Realm()
    
    override init() {
        super.init()
        self.updateSessions()
    }
    
    func updateSessions() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        Alamofire.request(.GET, "https://is15.qu.tu-berlin.de/1/sessions/batch")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let sessions = (response.result.value as! NSDictionary)["sessions"] as! [NSDictionary]
                    
                    try! self.realm.write {
                        for session in sessions {
                            let sessionCopy: NSMutableDictionary = session.mutableCopy() as! NSMutableDictionary
                            let papers: NSArray = session["papers"] as! NSArray
                            sessionCopy["start"] = dateFormatter.dateFromString(session["start"] as! String)
                            sessionCopy["end"] = dateFormatter.dateFromString(session["end"] as! String)
                            let paperArray = NSMutableArray()
                            for paper in papers {
                                let paperCopy: NSMutableDictionary = paper.mutableCopy() as! NSMutableDictionary
                                paperCopy["start"] = dateFormatter.dateFromString(paper["start"] as! String)
                                paperCopy["end"] = dateFormatter.dateFromString(paper["end"] as! String)
                                paperArray.addObject(paperCopy)
                            }
                            sessionCopy["papers"] = paperArray
                            
                            self.realm.create(Session.self, value: sessionCopy, update: true)
                        }
                        
                    }
                case .Failure(let error):
                    print(error)
                }
            }
    }
    
    func conferenceDates() -> [NSDate] {
        let distinctDates = try! Realm().objects(Session).sorted("start").reduce([]) { $0 + (!$0.contains($1.start.startOfDay) ? [$1.start.startOfDay] : [] ) }
        return distinctDates
    }
}