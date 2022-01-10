//
//  ToastContainer.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// `toast`容器协议
public protocol ToastContainer: UIView, ToastableDelegate {
    var options: ToastContainerOptions { get set }
    func showToast(inView view: UIView)
    func startHide(completion: ((Self) -> ())?)
}
