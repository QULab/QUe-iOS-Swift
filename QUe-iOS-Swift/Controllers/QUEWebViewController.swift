//
//  QUEWebViewController.swift
//  QUe
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

class QUEWebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.color = ThemeManager.currentTheme().mainColor
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = NSURL(string: "https://qulab.github.io/Que/")
        let urlRequest:NSURLRequest = NSURLRequest(URL: url!)
        webView.loadRequest(urlRequest)
        
        
    }
}

extension QUEWebViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        activityIndicator.stopAnimating()
        
        let alertController = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: error?.localizedDescription,
            preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (navigationType == .LinkClicked) {
            let alertController = UIAlertController(
                title: NSLocalizedString("External link", comment: ""),
                message: NSLocalizedString("Should this link be opened in Safari?", comment: ""),
                preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .Cancel,
                handler: nil))
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Safari", comment: ""),
                style: .Default,
                handler: { (UIAlertAction) -> Void in
                    UIApplication.sharedApplication().openURL(request.URL!)
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
}