//
//  Storyboardable.swift
//  Example-iOS
//
//  Created by Yoo-Jin Lee on 6/6/19.
//  Copyright © 2019 Mokten Pty Ltd. All rights reserved.
//

import UIKit

protocol Storyboardable: class {
    static var defaultStoryboardName: String { get }
}

extension Storyboardable where Self: UIViewController {
    static var defaultStoryboardName: String {
        return String(describing: self)
    }
    
    static func storyboardViewController() -> Self {
        let storyboard = UIStoryboard(name: defaultStoryboardName, bundle: nil)
        
        guard let vc = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Could not instantiate initial storyboard with name: \(defaultStoryboardName)")
        }
        
        return vc
    }
}

extension UIViewController: Storyboardable { }
