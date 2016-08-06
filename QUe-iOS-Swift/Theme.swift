//
//  Theme.swift
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

let SelectedThemeKey = "QUESelectedTheme"

enum Theme: Int {
    case Default, Dark, Graphical, Flat
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 67.0/255.0, green: 126.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        case .Graphical:
            return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        case .Flat:
            return UIColor(red:0.18, green:0.51, blue:0.72, alpha:1.00)
            
        }
    }
    var secondaryColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 82.0/255.0, green: 150.0/255.0, blue: 213.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 34.0/255.0, green: 128.0/255.0, blue: 66.0/255.0, alpha: 1.0)
        case .Graphical:
            return UIColor(red: 140.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 1.0)
        case .Flat:
            return UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00)
        }
    }
    
    var actionAddColor: UIColor {
        return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    }
    
    var actionRemoveColor: UIColor {
        return UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1.0)
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .Default, .Graphical, .Flat:
            return .Default
        case .Dark:
            return .Black
        }
    }
    
    enum sessionType: String {
        case O, K, SS, P, SE, ST
        
        var color: UIColor {
            switch self {
            case O:
                return UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            case K:
                return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            case SS:
                return UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
            case P:
                return UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0)
            case SE:
                return UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            case ST:
                return UIColor(red: 127.0/255.0, green: 140.0/255.0, blue: 141.0/255.0, alpha: 1.0)
            }
        }
    }
}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = NSUserDefaults.standardUserDefaults().valueForKey(SelectedThemeKey)?.integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Default
        }
    }
    
    static func applyTheme(theme: Theme) {
        NSUserDefaults.standardUserDefaults().setValue(theme.rawValue, forKey: SelectedThemeKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let sharedApplication = UIApplication.sharedApplication()
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        UIPageControl.appearance().backgroundColor = theme.mainColor
        UIPageControl.appearance().pageIndicatorTintColor = theme.secondaryColor
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.whiteColor()
        
//        UINavigationBar.appearance().barTintColor = theme.mainColor
//        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
//        
//        UISegmentedControl.appearance().backgroundColor = theme.mainColor
//        UISegmentedControl.appearance().tintColor = UIColor.whiteColor()
        
//        UINavigationBar.appearance().titleTextAttributes = [UITextAttributeTextColor: UIColor.blueColor()]
//        UITabBar.appearance().backgroundColor = UIColor.yellowColor();
//        avigationController.navigationBar.barTintColor = UIColor.greenColor()
    }
}