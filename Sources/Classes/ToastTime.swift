//
//  ToastTime.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import Foundation

/// toast的显示时长
///
///     seconds: 显示时长秒
///     distantFuture: 只要不主动隐藏就会永久显示
public enum ToastDuration {
    /// 显示时长秒
    case seconds(TimeInterval)
    /// 只要不主动隐藏就会永久显示
    case distantFuture
}
