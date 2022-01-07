//
//  CALayer+CornerRadius.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

internal extension CALayer {
    func setCornerRadius(_ radius: CGFloat, corner: UIRectCorner) {
        cornerRadius = radius
        var maskedCorners: CACornerMask = []
        if corner.contains(.topLeft) {
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        if corner.contains(.topRight) {
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if corner.contains(.bottomLeft) {
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        if corner.contains(.bottomRight) {
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        self.maskedCorners = maskedCorners
    }
}
