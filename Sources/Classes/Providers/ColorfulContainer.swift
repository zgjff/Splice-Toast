//
//  ColorfulContainer.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 带背景色的容器默认实现
public final class ColorfulContainer<Item: ToastItemable>: UIView, ToastContainer, CAAnimationDelegate {
    public var options = ToastContainerOptions()
    private var hiddenCompletion: ((ColorfulContainer) -> ())?
    private var toastItem: Item?
    private var orientationObserver: NSObjectProtocol?
    private var isPortraitOrientation = UIApplication.shared.orientation.isPortrait {
        didSet {
            if isPortraitOrientation != oldValue {
                toastItem?.onMidifyUIInterfaceOrientation(UIApplication.shared.orientation)
            }
        }
    }
    
    init(color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        orientationObserver = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.isPortraitOrientation = UIApplication.shared.orientation.isPortrait
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let orientationObserver = orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver)
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    @IBAction private func onTap() {
        options.onClick?(self)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        layer.removeAllAnimations()
        removeFromSuperview()
        options.onDisappear?()
        hiddenCompletion?(self)
        hiddenCompletion = nil
    }
}

// MARK: - ToastContainer
extension ColorfulContainer {
    public func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T : ToastItemable {
        toastItem = (sender as? Item)
        bounds.size = size
        addSubview(view)
        if let sv = superview {
            self.center = options.postition.centerForContainer(self, inView: sv)
        }
    }
    
    public func startHide(animated: Bool, completion: ((ColorfulContainer<Item>) -> ())?) {
        layer.removeAllAnimations()
        if animated, let ani = options.startHiddenAnimations(for: self) {
            hiddenCompletion = completion
            ani.delegate = WeakProxy(target: self).target
            let key = options.layerAnimationKey(forShow: false)
            layer.add(ani, forKey: key)
            return
        }
        removeFromSuperview()
        options.onDisappear?()
        completion?(self)
    }
}
