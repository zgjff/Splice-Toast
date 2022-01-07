//
//  GradientContainer.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 带背景色的容器默认实现
public final class GradientContainer: UIView, ToastContainer {
    public var options = ToastContainerOptions()
    private var hiddenCompletion: ((GradientContainer) -> ())?
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - ToastContainer
extension GradientContainer {
    public func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T : ToastItemable {
        bounds.size = size
        addSubview(view)
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
    
    public func startHide(completion: ((GradientContainer) -> ())?) {
        // 如果显示时间太短,还处在显示动画中,直接干掉显示动画
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
extension GradientContainer: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        layer.removeAllAnimations()
        removeFromSuperview()
        options.onDisappear?()
        hiddenCompletion?(self)
        hiddenCompletion = nil
    }
}

// MARK: - private
private extension GradientContainer {
    @IBAction func onTap() {
        options.onClick?(self)
    }
}
