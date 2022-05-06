//
//  SameToastItemTypeStrategy.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/10.
//

import Foundation

/// 同一个view上出现相同类型的`ToastItem`的处理策略
public protocol SameToastItemTypeStrategy {}


/// 直接将上一个替换成新的,而无需隐藏/显示动画
public struct ReplaceWithOutAnimatorStrategy: SameToastItemTypeStrategy {
    
}
