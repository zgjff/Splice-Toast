//
//  ActivityToastItem.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 显示系统`UIActivityIndicatorView`的`toast` item
public final class ActivityToastItem: IndicatorToastItemable {
    public typealias Options = ActivityToastItemOptions
    private lazy var activity: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .large)
        } else {
            return UIActivityIndicatorView(style: .white)
        }
    }()
    private var options = Options.init()
    weak public var delegate: ToastableDelegate?
}

// MARK: - IndicatorToastItemable
extension ActivityToastItem {
    public func layoutToastView(with options: ActivityToastItemOptions) {
        config(with: options)
        self.options = options
        activity.sizeToFit()
        let size = calculationSize(with: options)
        activity.frame = CGRect(x: options.margin.left, y: options.margin.top, width: activity.bounds.width, height: activity.bounds.height)
        delegate?.didCalculationView(activity, viewSize: size, sender: self)
        startAnimating()
    }
    
    public func onMidifyUIInterfaceOrientation(_ orientation: UIInterfaceOrientation) {
        let size = calculationSize(with: options)
        activity.frame = CGRect(x: options.margin.left, y: options.margin.top, width: activity.bounds.width, height: activity.bounds.height)
        delegate?.didCalculationView(activity, viewSize: size, sender: self)
    }
    
    public func startAnimating() {
        activity.startAnimating()
    }
}

// MARK: - private
private extension ActivityToastItem {
    func config(with options: ActivityToastItemOptions) {
        activity.style = options.style
        activity.color = options.color
    }
    
    func calculationSize(with options: ActivityToastItemOptions) -> CGSize {
        return CGSize(width: activity.bounds.width + options.margin.left + options.margin.right, height: activity.bounds.height + options.margin.top + options.margin.bottom)
    }
}

// MARK: - Activity配置

/// Activity的`taost`配置项
public struct ActivityToastItemOptions: ToastItemOptions {
    public init() {}
    
    /// 设置Activity颜色
    public var color = UIColor.white
    
    /// 设置`UIActivityIndicatorView.Style`
    public var style: UIActivityIndicatorView.Style = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView.Style.large
        } else {
            return .white
        }
    }()
    
    /// 设置Activity外边距
    public var margin = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
}
