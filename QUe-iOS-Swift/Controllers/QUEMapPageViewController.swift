//
//  QUEMapPageViewController.swift
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

class QUEMapPageViewController: UIPageViewController {
    
    let maps = ["Map1": "First Map",
                "Map2": "Second Map"]
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        for (filename,title) in self.maps {
            viewControllers.append(self.newMapViewController(filename, mapTitle: title))
        }
        return viewControllers
    }()
    
    private func newMapViewController(mapName: String, mapTitle: String) -> UIViewController {
        let mapViewController: QUEMapViewController = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("QUEMapViewController") as! QUEMapViewController
        let image = UIImage(named: mapName)!
        mapViewController.image = image
        mapViewController.mapTitle = mapTitle
        
        return mapViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first as? QUEMapViewController {
            self.navigationItem.title = firstViewController.mapTitle
            setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
        }
    }
    
}

extension QUEMapPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

extension QUEMapPageViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard case let mapController as QUEMapViewController = self.viewControllers?.first else {
            return
        }
        
        self.navigationItem.title = mapController.mapTitle
    }
}