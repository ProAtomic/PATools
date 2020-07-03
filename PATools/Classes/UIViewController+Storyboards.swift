//
//  UIViewController+Storyboards.swift
//  Pods
//
//  Created by Guillermo Andrés Sáenz Urday on 5/8/20.
//

import UIKit

public extension UIViewController {
    class func instantiate(from storyboard: String, framework: String) -> Self {
        let bundle = Bundle.main

        let resourcesBundleURL = bundle.url(forResource: framework, withExtension: "bundle")!
        
        let resourcesBundle = Bundle(url: resourcesBundleURL)
        let storyboard = UIStoryboard(name: storyboard, bundle: resourcesBundle)
        
        return storyboard.instantiateInitialViewController() as! Self
    }
}
