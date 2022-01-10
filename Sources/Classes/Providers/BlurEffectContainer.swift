//
//  BlurEffectContainer.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// `BlurEffect`的容器默认实现
public final class BlurEffectContainer<Item: ToastItemable>: UIVisualEffectView, ToastContainer, CAAnimationDelegate {
    public var options = ToastContainerOptions()
    private var hiddenCompletion: ((BlurEffectContainer) -> ())?
    private var toastItem: Item?
    private var orientationObserver: NSObjectProtocol?
    private var isPortraitOrientation = UIApplication.shared.orientation.isPortrait {
        didSet {
            if isPortraitOrientation != oldValue {
                toastItem?.onMidifyUIInterfaceOrientation(UIApplication.shared.orientation)
            }
        }
    }
    
    public override init(effect: UIVisualEffect?) {
        let eff = effect == nil ? UIBlurEffect(style: .dark) : effect
        super.init(effect: eff)
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
        debugPrint("BlurEffectContainer deinit")
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
extension BlurEffectContainer {
    public func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T : ToastItemable {
        toastItem = (sender as? Item)
        bounds.size = size
        contentView.addSubview(view)
        if let sv = superview {
            self.center = options.postition.centerForContainer(self, inView: sv)
        }
    }

    public func showToast(inView view: UIView) {
        self.center = options.postition.centerForContainer(self, inView: view)
        layer.setCornerRadius(options.cornerRadius, corner: options.corners)
        clipsToBounds = true
        view.addSubview(self)
        options.onAppear?()
        if let ani = options.startAppearAnimations(for: self) {
            let key = options.layerAnimationKey(forShow: true)
            layer.add(ani, forKey: key)
        }
    }
    
    public func startHide(completion: ((BlurEffectContainer) -> ())?) {
        layer.removeAllAnimations()
        if let ani = options.startHiddenAnimations(for: self) {
            hiddenCompletion = completion
            ani.delegate = WeakProxy(target: self).target
            let key = options.layerAnimationKey(forShow: false)
            layer.add(ani, forKey: key)
        } else {
            removeFromSuperview()
            options.onDisappear?()
            completion?(self)
        }
    }
}
