//
//  Style.swift
//  QuizUIKit
//
//  Created by Yoo-Jin Lee on 26/5/19.
//  Copyright © 2019 Yoo-Jin Lee. All rights reserved.
//

import UIKit

public protocol Style {
    static func applyStyle()
}

public struct DefaultStyle: Style {
    public static func applyStyle() {
        let label = UILabel.appearance()
        label.textAlignment = .center
    }
}
