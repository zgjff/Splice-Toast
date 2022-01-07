//
//  ToastDSL.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

public class ToastDSL<T> where T: ToastItemable {
    private let item: T
    private var itemOptions = T.Options.init()
    private var containerOptions = ToastContainerOptions()
    private var container: ToastContainer!
    private unowned let view: UIView
    internal init(view: UIView, item: T) {
        self.view = view
        self.item = item
    }
    
    deinit {
        debugPrint("ToastDSL  deinit")
    }
}

// MARK: - Config
public extension ToastDSL {
    func updateItem(options block: (inout T.Options) -> ()) -> Self {
        block(&itemOptions)
        return self
    }
    
    func useContainer(_ container: ToastContainer) -> Self {
        self.container = container
        return self
    }
    
    func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        containerOptions.cornerRadius = cornerRadius
        return self
    }
    
    func corners(_ corners: UIRectCorner) -> Self {
        containerOptions.corners = corners
        return self
    }
    
    func duration(_ duration: ToastDuration) -> Self {
        containerOptions.duration = duration
        return self
    }
    
    func position(_ position: ToastPosition) -> Self {
        containerOptions.postition = position
        return self
    }
    
    func appearAnimations(_ appearAnimations: Set<ContainerAnimator>) -> Self {
        containerOptions.appearAnimations = appearAnimations
        return self
    }
    
    func disappearAnimations(_ disappearAnimations: Set<ContainerAnimator>) -> Self {
        containerOptions.disappearAnimations = disappearAnimations
        return self
    }
    
    func useOppositeAppearAnimationsForDisappear() -> Self {
        containerOptions.disappearAnimations = containerOptions.oppositeOfAppearAnimations()
        return self
    }
    
    func didAppear(block: @escaping () -> ()) -> Self {
        containerOptions.onAppear = block
        return self
    }
    
    func didDisappear(block: @escaping () -> ()) -> Self {
        containerOptions.onDisappear = block
        return self
    }
    
    func didClick(block: @escaping (ToastContainer) -> ()) -> Self {
        containerOptions.onClick = block
        return self
    }
    
    // TODO: -- indicator 作为一个控制器只有一个
    func asSingle() {
        
    }
}

public extension ToastDSL {
    func show() {
        let temp: ToastContainer = container == nil ? BlurEffectContainer() : container!
        item.delegate = temp
        temp.options = containerOptions
        item.layoutToastView(with: itemOptions)
        view.showToastContainer(temp)
    }
}
