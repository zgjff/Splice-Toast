//
//  UIApplication+Orientation.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/8.
//

import UIKit

extension UIApplication {
    internal var orientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.compactMap { $0 as? UIWindowScene }
            return scenes.first?.interfaceOrientation ?? .portrait
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
