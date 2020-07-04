//
//  UIViewController+Storyboards.swift
//  Pods
//
//  Created by Guillermo Andrés Sáenz Urday on 5/8/20.
//

import UIKit

public extension UIViewController {
    class func instantiate(from storyboard: String, framework: String) -> Self {
        let bundle = self.bundle(for: framework)
        
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        
        return storyboard.instantiateInitialViewController() as! Self
    }
}

fileprivate extension UIViewController {
    class func bundle(for framework: String?) -> Bundle {
        let mainBundle = Bundle.main
        guard let framework = framework else {
            return mainBundle
        }

        let resourcesBundleURL = mainBundle.url(forResource: framework, withExtension: "bundle")!
        
        let resourcesBundle = Bundle(url: resourcesBundleURL)!
        
        return resourcesBundle
    }
}
