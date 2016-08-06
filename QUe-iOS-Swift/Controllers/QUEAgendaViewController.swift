//
//  QUEAgendaViewController.swift
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

class QUEAgendaViewController: UIViewController {
    var pageController: UIPageViewController!
    var datasource: QUEDatasource!
    var conferenceDates = [NSDate]()
    var pageContent = [Results<Session>]()
    var searchController: UISearchController!
    var notificationToken: NotificationToken?
    
    @IBOutlet weak var navigatorView: QUEAgendaNavigatorView!
    @IBOutlet weak var navigatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource =  QUEDatasource()
        
        navigatorView.navigationLeftButton.tintColor = ThemeManager.currentTheme().mainColor
        navigatorView.navigationRightButton.tintColor = ThemeManager.currentTheme().mainColor
        
        pageController = storyboard!.instantiateViewControllerWithIdentifier("QUEAgendaPageViewController") as? UIPageViewController
        conferenceDates = datasource.conferenceDates()
        do {
            notificationToken = try Realm().addNotificationBlock { [unowned self] note, realm in
                self.databaseUpdated()
            }
        } catch _ {
            print("An eror occured!")
        }
        
        pageController.delegate = self
        pageController.dataSource = self
        
        
        if conferenceDates.count > 0 {
            createContentPages()
            let startingViewController: QUEAgendaTableViewController = viewControllerAtIndex(0)!
            
            let viewControllers: [UIViewController] = [startingViewController]
            pageController.setViewControllers(viewControllers,
                direction: .Forward,
                animated: false,
                completion: nil)
        }
        
        
        currentViewController = pageController
        currentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(self.currentViewController)
        addSubview(currentViewController.view, toView: containerView)
        
        updateNavigation()
    }
    
    func databaseUpdated() {
        self.conferenceDates = self.datasource.conferenceDates()
        self.createContentPages()
        
        // save locally
        // try! Realm().writeCopyToURL(__missing__, encryptionKey: nil)
        
        if self.pageController.viewControllers?.count == 0 {
            let startingViewController: QUEAgendaTableViewController = self.viewControllerAtIndex(0)!
            
            let viewControllers: [UIViewController] = [startingViewController]
            self.pageController.setViewControllers(viewControllers,
                direction: .Forward,
                animated: false,
                completion: nil)
        }
        self.updateNavigation()
    }
    
    func createContentPages() {
        
        pageContent = conferenceDates.map({ (date: NSDate) -> Results<Session> in
            let predicate = NSPredicate(format: "(start >= %@) AND (start <= %@)", date.startOfDay, date.endOfDay)
            return try! Realm().objects(Session).filter(predicate).sorted("start")
        })
    }
    
    
    func viewControllerAtIndex(index: Int) -> QUEAgendaTableViewController? {
        
        guard let day = conferenceDates[index] as NSDate?,
            let sessions = pageContent[index] as Results<Session>? else { return nil }
        
        let storyBoard = UIStoryboard(name: "Main",
            bundle: NSBundle.mainBundle())
        let tableViewController = storyBoard.instantiateViewControllerWithIdentifier(QUEAgendaTableViewController.StoryboardConstants.identifier) as! QUEAgendaTableViewController
        
        tableViewController.currentDay = day
        tableViewController.sessions = sessions
        return tableViewController
    }
    
    func indexOfViewController(viewController: QUEAgendaTableViewController) -> Int {
        guard let index = conferenceDates.indexOf(viewController.currentDay) else {
            return NSNotFound
        }
        
        return index
    }
    
    @IBAction func showPreviousDay(button: UIButton) {
        guard let current = pageController.viewControllers?.last,
            let previousViewController = pageViewController(pageController, viewControllerBeforeViewController: current) else {
                button.enabled = false
                return
        }
        
        pageController.setViewControllers([previousViewController], direction: .Reverse, animated: true, completion: { (completed) -> Void in
            self.updateNavigation()
        })
        
    }
    
    @IBAction func showNextDay(button: UIButton) {
        guard let current = pageController?.viewControllers?.last,
            let nextViewController = pageViewController(pageController, viewControllerAfterViewController: current) else {
                button.enabled = false
                return
        }
        
        pageController.setViewControllers([nextViewController], direction: .Forward, animated: true, completion: { (completed) -> Void in
            self.updateNavigation()
        })
    }
    
    func updateNavigation() {
        
        guard let currentViewController = pageController.viewControllers?.last as? QUEAgendaTableViewController else {
            navigatorView.navigationLeftButton.enabled = false
            navigatorView.navigationRightButton.enabled = false
            
            navigatorView.dateLabel.text = "---"
            
            return
        }
        
        
        navigatorView.navigationLeftButton.enabled = pageViewController(pageController, viewControllerBeforeViewController: currentViewController) != nil
        navigatorView.navigationRightButton.enabled = pageViewController(pageController, viewControllerAfterViewController: currentViewController) != nil
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd"
        navigatorView.dateLabel.text = dateFormatter.stringFromDate(currentViewController.currentDay)
    }
    
    @IBAction func searchButtonTapped(button: UIBarButtonItem) {
        let searchResultsController = storyboard!.instantiateViewControllerWithIdentifier(QUEAgendaSearchResultsViewController.StoryboardConstants.identifier) as! QUEAgendaSearchResultsViewController

        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = searchResultsController
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("Sessions", comment: ""), NSLocalizedString("Papers", comment: "")]
        searchResultsController.tableView.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    @IBAction func nowButtonTapped(sender: UIBarButtonItem) {
        let date = NSDate()
        
        if let index = conferenceDates.indexOf(date.startOfDay) {
            guard let current = pageController?.viewControllers?.last as? QUEAgendaTableViewController else {
                return
            }
            if (current.currentDay == date.startOfDay) {
                current.scrollToActiveSessions(date)
            } else {
                let currentIndex = indexOfViewController(current)
                let direction: UIPageViewControllerNavigationDirection = (index < currentIndex) ? .Reverse : .Forward
                
                let viewController = viewControllerAtIndex(index)
                
                pageController.setViewControllers([viewController!], direction: direction,
                    animated: true,
                    completion: { (completed) -> Void in
                        self.updateNavigation()
                        viewController?.scrollToActiveSessions(date)
                })
            }
        }
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            cycleFromViewController(currentViewController, toViewController: pageController)
            currentViewController = pageController
        case 1:
            let newViewController = storyboard?.instantiateViewControllerWithIdentifier(QUEFavoritesTableViewController.StoryboardConstants.identifier)
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            cycleFromViewController(currentViewController, toViewController: newViewController!)
            currentViewController = newViewController
            
        default:
            break
        }

    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMoveToParentViewController(nil)
        addChildViewController(newViewController)
        addSubview(newViewController.view, toView:containerView!)
        newViewController.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.5, animations: {
            newViewController.view.layoutIfNeeded()
            self.navigatorViewHeightConstraint.constant = oldViewController == self.pageController ? 0 : 44
            self.navigatorView.hidden = oldViewController == self.pageController ? true : false
            },
            completion: { finished in
                
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParentViewController()
                newViewController.didMoveToParentViewController(self)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let searchResultsController = sender as? QUEAgendaSearchResultsViewController,
            let indexPath = searchResultsController.tableView.indexPathForSelectedRow else {
                return
        }
        
        if (segue.identifier == QUESessionTableViewController.StoryboardConstants.segueIdentifier) {
            let session =  searchResultsController.sessionsBySection[indexPath.section][indexPath.row]
            let sessionController = segue.destinationViewController as! QUESessionTableViewController
            sessionController.session = session
        } else if (segue.identifier == QUEPaperViewController.StoryboardConstants.segueIdentifier) {
            let paper =  searchResultsController.papersBySection[indexPath.section][indexPath.row]
            let paperController = segue.destinationViewController as! QUEPaperViewController
            paperController.session = paper.session.first
            paperController.paper = paper
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension QUEAgendaViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let searchResultsController = searchController.searchResultsController as? QUEAgendaSearchResultsViewController else {
                return
        }
        
        switch searchResultsController.filterScope {
        case .Session:
           performSegueWithIdentifier(QUESessionTableViewController.StoryboardConstants.segueIdentifier, sender: searchResultsController)
        case .Paper:
            performSegueWithIdentifier(QUEPaperViewController.StoryboardConstants.segueIdentifier, sender: searchResultsController)
        }
    }
}

extension QUEAgendaViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController
            as! QUEAgendaTableViewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController
            as! QUEAgendaTableViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == pageContent.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updateNavigation()
    }
}