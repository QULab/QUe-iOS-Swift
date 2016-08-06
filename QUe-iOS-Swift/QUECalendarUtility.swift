//
//  QUECalendarUtility.swift
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
import EventKit
import RealmSwift

class QUECalendarUtility: NSObject {
    
    func addPaperToCalendar(paper: Paper, session: Session) {
        let eventStore = EKEventStore()
        
        var notes = paper.authors.reduce("") {
            authorList,author in
            let separator = (author == paper.authors.last) ? "" : ", "
            return "\(authorList)\(author.fullName)\(separator)"
        }
        notes += "\n\n" + paper.abstract

        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                
                if (granted) {
                    dispatch_async(dispatch_get_main_queue()) {
                        let calendarEventId = self.createEvent(eventStore,
                            title: paper.title,
                            startDate: paper.start,
                            endDate: paper.end,
                            location: session.room,
                            notes: notes)
                        try! Realm().write {
                            paper.calendarEventId = calendarEventId!
                        }
                    }
                }
            })
        } else {
            let calendarEventId = self.createEvent(eventStore,
                title: paper.title,
                startDate: paper.start,
                endDate: paper.end,
                location: session.room,
                notes: notes)
            try! Realm().write {
                paper.calendarEventId = calendarEventId!
            }
        }
    }
    
    func removePaperFromCalendar(paper: Paper) {
        if (paper.calendarEventId ?? "").isEmpty {
            return
        }
        
        let eventStore = EKEventStore()
        deleteEvent(eventStore, eventIdentifier: paper.calendarEventId)
        
        try! Realm().write {
            paper.calendarEventId = ""
        }
    }
    
    func addSessionToCalendar(session: Session) {
        let eventStore = EKEventStore()
        
        var notes = ""
        if (session.papers.count > 0) {
            notes = NSLocalizedString("Papers", comment: "") + ":\n"
            
            for paper in session.papers {
                notes += "\t* " + paper.title + "\n"
            }
        }        
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                
                if (granted) {
                    dispatch_async(dispatch_get_main_queue()) {
                        let calendarEventId = self.createEvent(eventStore,
                            title: session.title,
                            startDate: session.start,
                            endDate: session.end,
                            location: session.room,
                            notes: notes)
                        try! Realm().write {
                            session.calendarEventId = calendarEventId!
                        }
                    }
                }
            })
        } else {
            let calendarEventId = self.createEvent(eventStore,
                title: session.title,
                startDate: session.start,
                endDate: session.end,
                location: session.room,
                notes: notes)
            try! Realm().write {
                session.calendarEventId = calendarEventId!
            }
        }
    }
    
    func removeSessionFromCalendar(session: Session) {
        if (session.calendarEventId ?? "").isEmpty {
            return
        }
        
        let eventStore = EKEventStore()
        deleteEvent(eventStore, eventIdentifier: session.calendarEventId)
        
        try! Realm().write {
            session.calendarEventId = ""
        }
    }
    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate, location: String, notes: String) -> String? {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(relativeOffset: -15*60))
        
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            return event.eventIdentifier
        } catch {
            print("Bad things happened")
            return nil
        }
    }
    
    // Removes an event from the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.eventWithIdentifier(eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
            } catch {
                print("Bad things happened")
            }
        }
    }
}