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
    func showToast(inView view: UIView, animated: Bool)
    func startHide(animated: Bool, completion: ((Self) -> ())?)
}

//MARK: - 默认实现
extension ToastContainer {
    public func showToast(inView view: UIView, animated: Bool) {
        self.center = options.postition.centerForContainer(self, inView: view)
        layer.setCornerRadius(options.cornerRadius, corner: options.corners)
        clipsToBounds = true
        view.addSubview(self)
        options.onAppear?()
        if animated, let ani = options.startAppearAnimations(for: self) {
            let key = options.layerAnimationKey(forShow: true)
            layer.add(ani, forKey: key)
        }
    }
}
