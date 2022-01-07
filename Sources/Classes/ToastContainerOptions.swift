//
//  ToastContainerOptions.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

public struct ContainerCornerRadius {
    internal let cornerRadius: CGFloat
    internal let corners: UIRectCorner
    
    init(cornerRadius: CGFloat, corners: UIRectCorner = .allCorners) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }
}

public struct ToastContainerOptions {
    internal var cornerRadius: CGFloat = 6
    internal var corners = UIRectCorner.allCorners
    internal var duration = ToastDuration.seconds(2)
    internal var postition = ToastPosition.center
    internal var appearAnimations: Set<ContainerAnimator> = [ContainerAnimator.scale(0.7)]
    internal var disappearAnimations: Set<ContainerAnimator>!
    internal var onAppear: (() -> ())?
    internal var onDisappear: (() -> ())?
    internal var onClick: ((ToastContainer) -> ())?
    
    init() {
        disappearAnimations = [ContainerAnimator.opacity(0).opposite]
    }
}

extension ToastContainerOptions {
    internal func oppositeOfAppearAnimations() -> Set<ContainerAnimator> {
        var animations: Set<ContainerAnimator> = []
        for ani in appearAnimations {
            animations.insert(ani.opposite)
        }
        return animations
    }
    
    @discardableResult
    internal func startAppearAnimations(for view: UIView) -> CAAnimation? {
        return handleAnimations(appearAnimations, forView: view)
    }
       
    @discardableResult
    internal func startHiddenAnimations(for view: UIView) -> CAAnimation? {
        return handleAnimations(disappearAnimations, forView: view)
    }
       
    @discardableResult
    private func handleAnimations(_ animations: Set<ContainerAnimator>, forView view: UIView) -> CAAnimation? {
        if animations.isEmpty {
            return nil
        }
        var anis: [CAAnimation] = []
        for ani in animations {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            view.layer.setValue(ani.toValue, forKey: ani.keyPath)
            CATransaction.commit()
            anis.append(ani.animation)
        }
        let group = CAAnimationGroup()
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        group.duration = 0.25
        group.animations = anis
        return group
    }
       
    internal func layerAnimationKey(forShow isShow: Bool) -> String {
        return isShow ? "showGroupAnimations" : "hideGroupAnimations"
    }
}
