//
//  QUEModels.swift
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

// Author model
class Author: Object {
    dynamic var _id = ""
    dynamic var first_name = ""
    dynamic var last_name: String? = nil
    dynamic var affiliation: String? = nil
    dynamic var email: String? = nil
    
    let papers = LinkingObjects(fromType: Paper.self, property: "authors")
    
    var fullName: String { return last_name != nil ? "\(first_name) \(last_name!)" : first_name }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["first_name", "last_name", "affiliation"]
    }
}

// Paper model
class Paper: Object {
    dynamic var _id = ""
    dynamic var code = ""
    dynamic var title = ""
    dynamic var abstract = ""
    dynamic var file: String? = nil
    dynamic var start = NSDate()
    dynamic var end = NSDate()
    dynamic var favorite = false
    dynamic var calendarEventId = ""
    let authors = List<Author>()
    
    let session = LinkingObjects(fromType: Session.self, property: "papers")
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["title", "abstract"]
    }
}

// Session model
class Session: Object {
    dynamic var _id = ""
    dynamic var code = ""
    dynamic var title = ""
    dynamic var start = NSDate()
    dynamic var end = NSDate()
    dynamic var type = ""
    dynamic var type_name = ""
    dynamic var room = ""
    dynamic var chair: String? = nil
    dynamic var favorite = false
    dynamic var calendarEventId = ""
    let papers = List<Paper>()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["title"]
    }
}