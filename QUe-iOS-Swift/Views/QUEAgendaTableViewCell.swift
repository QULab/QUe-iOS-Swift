//
//  QUEAgendaTableViewCell.swift
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

enum SessionSate {
    case Past
    case Present
    case Future
}

class QUEAgendaTableViewCell: UITableViewCell {
    
    struct StoryboardConstants {
        static let identifier = "agendaTableViewCell"
    }
    
    @IBOutlet weak var timeBeginLabel: UILabel!
    @IBOutlet weak private var timeSeparatorLabel: UILabel!
    @IBOutlet weak var timeEndLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var favoriteLabelHeightConstraint: NSLayoutConstraint!
    var state: SessionSate = .Future {
        didSet {
            let color:UIColor!
            let pastColor:UIColor = UIColor(red: 189.0/255.0, green: 195.0/255.0, blue: 199.0/255.0, alpha: 1.0)
            let presentColor:UIColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            let futureColor:UIColor = UIColor.darkTextColor()
            
            switch(state) {
            case .Past:
                color = pastColor
            case .Present:
                color = presentColor
            default:
                color = futureColor
            }
            
            timeBeginLabel.textColor = color
            timeSeparatorLabel.textColor = color;
            timeEndLabel.textColor = color
        }
    }
    
    var content: String? = nil {
        didSet {
            if content == nil || content!.isEmpty {
                favoriteLabelHeightConstraint.constant = 0
            } else {
                favoriteLabel.text = content
                favoriteLabelHeightConstraint.constant = 13
            }
        }
    }
}
