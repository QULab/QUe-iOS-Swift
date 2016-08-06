//
//  QUEAuthorsTableViewController.swift
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

class QUEAuthorsTableViewController: UITableViewController {
    struct StoryboardConstants {
        static let identifier = "QUEAuthorsTableViewController"
    }
    
    var searchController: UISearchController!
    
    var authors: Results<Author>!
    var results: [String : [Author]] = [String: [Author]]()
    var resultsTitles: [String] = [String]()
    var searchResults: Results<Author>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authors = try! Realm().objects(Author).sorted("last_name")
        
        
        for author in authors {
            guard let lastName = author.last_name else {
                let letter: String = "-"
                if !results.keys.contains(letter) {
                    results[letter] = []
                }
                
                results[letter]?.append(author)
                continue
            }
            
            let letter: String = String(lastName.characters.first!).uppercaseString.stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale: NSLocale.currentLocale())
            if !results.keys.contains(letter) {
                results[letter] = []
            }
            
            
            results[letter]?.append(author)
        }
        resultsTitles = results.keys.sort { String($0).localizedCaseInsensitiveCompare(String($1)) == NSComparisonResult.OrderedAscending }
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchController.searchBar.tintColor = ThemeManager.currentTheme().mainColor
        let searchBarTextField = searchController.searchBar.valueForKey("searchField") as? UITextField
        searchBarTextField?.textColor = ThemeManager.currentTheme().secondaryColor
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView = UIView() // get rid of white background above table header
        
        definesPresentationContext = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let indexPath = self.tableView.indexPathForSelectedRow,
            let authorController = segue.destinationViewController as? QUEAuthorTableViewController else { return }
        
        let author: Author
        if (searchController.active) {
            author = searchResults[indexPath.row]
        } else {
            author = results[resultsTitles[indexPath.section]]![indexPath.row]
        }
        
        authorController.author = author
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            return 1
        } else {
            return resultsTitles.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return results[resultsTitles[section]]!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("authorTableViewCell")
        
        let author: Author
        if (searchController.active) {
            author = searchResults[indexPath.row]
        } else {
            author = results[resultsTitles[indexPath.section]]![indexPath.row]
        }
        
        let attributedString = NSMutableAttributedString(string:author.fullName)
        if author.last_name != nil {
            let range = (author.fullName as NSString).rangeOfString(author.last_name!)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: range)
            cell?.textLabel?.attributedText = attributedString
        } else {
            cell?.textLabel?.attributedText = attributedString
        }
        cell?.detailTextLabel?.text = author.affiliation
        
        return cell!
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if (searchController.active) {
            return nil
        }
        
        return resultsTitles
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (searchController.active) {
            return nil
        }
        
        return resultsTitles[section]
    }
}

extension QUEAuthorsTableViewController: UISearchControllerDelegate {
    func presentSearchController(searchController: UISearchController) {
    }
    
    func willPresentSearchController(searchController: UISearchController) {
    }
    
    func didPresentSearchController(searchController: UISearchController) {
    }
    
    func willDismissSearchController(searchController: UISearchController) {
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        tableView.reloadData()
    }
}

extension QUEAuthorsTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension QUEAuthorsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if !searchController.active {
            return
        }
        
        let filterString = searchController.searchBar.text
        
        let words = filterString!.componentsSeparatedByString(" ");
        let predicateList = words.map({ (word: String) -> NSPredicate in
            return NSPredicate(format: "(first_name CONTAINS[c] %@) OR (last_name CONTAINS[c] %@) OR (affiliation CONTAINS[c] %@)", word, word, word)
        })
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:predicateList)
        
        searchResults = try! Realm().objects(Author).filter(filterPredicate).sorted("last_name")
        
        tableView.reloadData()
    }
}