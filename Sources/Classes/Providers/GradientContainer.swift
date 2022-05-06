//
//  GradientContainer.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 带背景色的容器默认实现
public final class GradientContainer<Item: ToastItemable>: UIView, ToastContainer, CAAnimationDelegate {
    public var options = ToastContainerOptions()
    private var hiddenCompletion: ((GradientContainer) -> ())?
    private var toastItem: Item?
    private var orientationObserver: NSObjectProtocol?
    private var isPortraitOrientation = UIApplication.shared.orientation.isPortrait {
        didSet {
            if isPortraitOrientation != oldValue {
                toastItem?.onMidifyUIInterfaceOrientation(UIApplication.shared.orientation)
            }
        }
    }
    
    private lazy var gradientLayer = CAGradientLayer()
    init(colors: [CGColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        super.init(frame: .zero)
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.insertSublayer(gradientLayer, at: 0)
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        layer.removeAllAnimations()
        removeFromSuperview()
        options.onDisappear?()
        hiddenCompletion?(self)
        hiddenCompletion = nil
    }
    
    @IBAction private func onTap() {
        options.onClick?(self)
    }
}

// MARK: - ToastContainer
extension GradientContainer {
    public func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T : ToastItemable {
        toastItem = (sender as? Item)
        bounds.size = size
        addSubview(view)
        if let sv = superview {
            self.center = options.postition.centerForContainer(self, inView: sv)
        }
    }
    
    public func startHide(animated: Bool, completion: ((GradientContainer<Item>) -> ())?) {
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
