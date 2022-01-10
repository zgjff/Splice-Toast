//
//  ToastItemable.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// toast组件配置协议
public protocol ToastItemOptions {
    init()
}

/// toast组件协议
public protocol ToastItemable: AnyObject {
    associatedtype Options: ToastItemOptions
    var delegate: ToastableDelegate? { get set }
    func layoutToastView(with options: Options)
    func onMidifyUIInterfaceOrientation(_ orientation: UIInterfaceOrientation)
}

public protocol ToastableDelegate: NSObjectProtocol {
    func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T: ToastItemable
}

/// 显示文字的 `toast`组件协议
public protocol TextToastItemable: ToastItemable {
    init(text: String)
    init(attributedString: NSAttributedString)
    func resetContentSizeWithMaxSize(_ size: CGSize)
}

/// 显示指示器的 `toast`组件协议
public protocol IndicatorToastItemable: ToastItemable {
    func startAnimating()
}

/// 显示进度条的 `toast`组件协议
public protocol ProgressToastItemable: ToastItemable {
    func setProgress(_ progress: Float, animated: Bool)
}
