//
//  UIView+Toast.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

// MARK: - 操作 `Toast`,通用方法
public extension UIView {
    func makeToast<T>(_ item: T) -> ToastDSL<T> where T: ToastItemable {
        return ToastDSL(view: self, item: item)
    }
    
    func hideToast(_ toast: ToastContainer) {
        toast.startHide { obj in
            self.shownContaienrQueue.remove(where: { $0 === obj })
        }
    }
    
    func hideAllToasts() {
        print("hideAllToasts-------", shownContaienrQueue.arr)
        shownContaienrQueue.forEach { [weak self] container in
            self?.hideToast(container)
        }
    }
}

public extension UIView {
    
}

// MARK: - 非公开调用的方法
extension UIView {
    internal func showToastContainer(_ container: ToastContainer) {
        shownContaienrQueue.append(container)
        container.showToast(inView: self)
        if case let .seconds(t) = container.options.duration {
            hideToast(container, after: t)
        }
    }
    
    internal func hideToast(_ toast: ToastContainer, after time: TimeInterval) {
        if time <= 0.15 {
            self.hideToast(toast)
            
            return
        }
        // TODO: - 倒计时放在这里不合理,应该放在ToastContainer中,且用NSTimer
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            self?.hideToast(toast)
        }
    }
}

