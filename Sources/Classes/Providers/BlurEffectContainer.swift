//
//  BlurEffectContainer.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// `BlurEffect`的容器默认实现
public final class BlurEffectContainer: UIVisualEffectView, ToastContainer {
    public var options = ToastContainerOptions()
    private var hiddenCompletion: ((BlurEffectContainer) -> ())?
    public init(effect: UIBlurEffect = UIBlurEffect(style: .dark)) {
        super.init(effect: effect)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("BlurEffectContainer deinit")
    }
}

// MARK: - ToastContainer
extension BlurEffectContainer {
    public func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T : ToastItemable {
        bounds.size = size
        contentView.addSubview(view)
    }

    public func toastContainerSize() -> CGSize {
        return bounds.size
    }

    public func showToast(inView view: UIView) {
        let center = options.postition.centerForContainer(self, inView: view)
        self.center = center
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

// MARK: - CAAnimationDelegate
extension BlurEffectContainer: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        layer.removeAllAnimations()
        removeFromSuperview()
        options.onDisappear?()
        hiddenCompletion?(self)
        hiddenCompletion = nil
    }
}

// MARK: - private
private extension BlurEffectContainer {
    @IBAction func onTap() {
        options.onClick?(self)
    }
}
