//
//  ContainerAnimator.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

public struct ContainerAnimator {
    internal let keyPath: String
    internal let fromValue: Any?
    internal let toValue: Any?
    
    public init?(keyPath: String, fromValue: Any?, toValue: Any?) {
        let key = keyPath.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty {
            return nil
        }
        self.keyPath = key
        self.fromValue = fromValue
        self.toValue = toValue
    }
    
    public var opposite: ContainerAnimator {
        return ContainerAnimator(keyPath: keyPath, fromValue: toValue, toValue: fromValue)!
    }
    
    internal var animation: CABasicAnimation {
        let obj = CABasicAnimation(keyPath: keyPath)
        obj.fromValue = fromValue
        obj.toValue = toValue
        return obj
    }
}

extension ContainerAnimator: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
    }
    
    public static func == (lhs: ContainerAnimator, rhs: ContainerAnimator) -> Bool {
        return lhs.keyPath == rhs.keyPath
    }
}

extension ContainerAnimator {
    public static var scale: (_ fromValue: Double) -> ContainerAnimator = { fromValue in
        let from = fromValue < 0 ? 0 : (fromValue > 1) ? 1 : fromValue
        return ContainerAnimator(keyPath: "transform.scale", fromValue: from, toValue: 1)!
    }
    public static var scaleX: (_ fromValue: Double) -> ContainerAnimator = { fromValue in
        let from = fromValue < 0 ? 0 : (fromValue > 1) ? 1 : fromValue
        return ContainerAnimator(keyPath: "transform.scale.x", fromValue: from, toValue: 1)!
    }
    public static var scaleY: (_ fromValue: Double) -> ContainerAnimator = { fromValue in
        let from = fromValue < 0 ? 0 : (fromValue > 1) ? 1 : fromValue
        return ContainerAnimator(keyPath: "transform.scale.y", fromValue: from, toValue: 1)!
    }
    public static var opacity: (_ fromValue: Double) -> ContainerAnimator = { fromValue in
        let from = fromValue < 0 ? 0 : (fromValue > 1) ? 1 : fromValue
        return ContainerAnimator(keyPath: "opacity", fromValue: from, toValue: 1)!
    }
}

