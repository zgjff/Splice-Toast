//
//  ToastPosition.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// Toast的显示位置
public struct ToastPosition {
    private let centerYRatio: CGFloat
    private let offset: CGFloat
    private let ignoreSafeAreaInsets: Bool
    /// 初始化ToastPosition
    /// - Parameters:
    ///   - centerYRatio: taost container的中心点占superView的比例,具体算法为
    ///
    ///         containerView.centerY/(superView.height - containerView.height - superView.safeAreaInsets.top - superView.safeAreaInsets.bottom)
    ///
    ///   - offset: centerY的偏移量
    ///   - ignoreSafeAreaInsets: 是否忽略安全区域
    public init(centerYRatio: CGFloat, offset: CGFloat, ignoreSafeAreaInsets: Bool = false) {
        self.centerYRatio = centerYRatio
        self.offset = offset
        self.ignoreSafeAreaInsets = ignoreSafeAreaInsets
    }
}

extension ToastPosition {
    /// 忽略安全区域的顶部
    public static let top = ToastPosition(centerYRatio: 0, offset: 0, ignoreSafeAreaInsets: true)
    /// 不忽略安全区域顶部
    public static let safeTop = ToastPosition(centerYRatio: 0, offset: 0, ignoreSafeAreaInsets: false)
    /// 忽略安全区域的四分之一处
    public static let quarter = ToastPosition(centerYRatio: 0.25, offset: 0, ignoreSafeAreaInsets: true)
    /// 不忽略安全区域的四分之一处
    public static let safeQuarter = ToastPosition(centerYRatio: 0.25, offset: 0, ignoreSafeAreaInsets: false)
    /// 忽略安全区域的中心处
    public static let center = ToastPosition(centerYRatio: 0.5, offset: 0, ignoreSafeAreaInsets: true)
    /// 不忽略安全区域的中心处
    public static let safeCenter = ToastPosition(centerYRatio: 0.5, offset: 0, ignoreSafeAreaInsets: false)
    /// 忽略安全区域的四分之三处
    public static let threeQuarter = ToastPosition(centerYRatio: 0.75, offset: 0, ignoreSafeAreaInsets: true)
    /// 不忽略安全区域的四分之三处
    public static let safeThreeQuarter = ToastPosition(centerYRatio: 0.75, offset: 0, ignoreSafeAreaInsets: false)
    /// 忽略安全区域的底部
    public static let bottom = ToastPosition(centerYRatio: 1, offset: 0, ignoreSafeAreaInsets: true)
    /// 不忽略安全区域低部
    public static let safeBottom = ToastPosition(centerYRatio: 1, offset: 0, ignoreSafeAreaInsets: false)
}

extension ToastPosition {
    internal func centerForContainer(_ container: ToastContainer, inView superView: UIView) -> CGPoint {
        let cx = superView.bounds.width * 0.5
        let containerSize = container.toastContainerSize()
        let cy: CGFloat
        switch ignoreSafeAreaInsets {
        case false:
            let safeAreaHeight = superView.bounds.height - containerSize.height - superView.safeAreaInsets.top - superView.safeAreaInsets.bottom
            cy = safeAreaHeight * centerYRatio + offset + containerSize.height * 0.5 + superView.safeAreaInsets.top
        case true:
            let areaHeight = superView.bounds.height - containerSize.height
            cy = areaHeight * centerYRatio + offset + containerSize.height * 0.5
        }
        return CGPoint(x: cx, y: cy)
    }
}

extension ToastPosition: Equatable {
    public static func == (lhs: ToastPosition, rhs: ToastPosition) -> Bool {
        return (lhs.ignoreSafeAreaInsets == rhs.ignoreSafeAreaInsets) && (lhs.centerYRatio == rhs.centerYRatio) && (lhs.offset == rhs.offset)
    }
}
