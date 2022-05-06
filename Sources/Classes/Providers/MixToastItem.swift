//
//  MixToastItem.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 显示指示器+文字的`toast`
public final class MixToastItem<Indicator: IndicatorToastItemable, Text: TextToastItem>: NSObject, IndicatorToastItemable, ToastableDelegate {
    public typealias Options = MixToastItemOptions<Indicator, Text>
    weak public var delegate: ToastableDelegate?
    private let indicatorView: Indicator
    private let textView: Text
    private var options: Options = Options.init()
    
    public init(indicator: Indicator, text: Text) {
        indicatorView = indicator
        textView = text
        super.init()
        indicator.delegate = self
        textView.delegate = self
    }
    
    private var indicatorToastProvider: SubToastProvider? {
        didSet {
            layoutViews()
        }
    }
    
    private var textToastProvider: SubToastProvider? {
        didSet {
            layoutViews()
        }
    }
}

// MARK: - ToastableDelegate
extension MixToastItem {
    public func didCalculationView<T>(_ view: UIView, viewSize size: CGSize, sender: T) where T : ToastItemable {
        if sender === indicatorView {
            indicatorToastProvider = SubToastProvider(view: view, contentSize: view.bounds.size, toastSize: size)
        }
        if sender === textView {
            textToastProvider = SubToastProvider(view: view, contentSize: view.bounds.size, toastSize: size)
        }
    }
    
    private func layoutViews() {
        guard let indicatorProvider = indicatorToastProvider,
              let textProvider = textToastProvider,
              let (textFrame, indicatorFrame, viewSize) = calculationSize() else {
                  return
              }
        let view = UIView()
        indicatorProvider.view.removeFromSuperview()
        indicatorProvider.view.frame = indicatorFrame
        view.addSubview(indicatorProvider.view)
        textProvider.view.removeFromSuperview()
        textProvider.view.frame = textFrame
        view.addSubview(textProvider.view)
        delegate?.didCalculationView(view, viewSize: viewSize, sender: self)
    }
    
    private func calculationSize() -> (textFrame: CGRect, indicatorFrame: CGRect, view: CGSize)? {
        guard let indicatorProvider = indicatorToastProvider,
              let textProvider = textToastProvider else {
            return nil
        }
        // 指示器
        let indicatorSize = indicatorProvider.contentSize
        let indicatorFrame = indicatorProvider.view.frame
        let indicatorViewSize = indicatorProvider.toastSize
        
        let indicatorMargin = UIEdgeInsets(top: indicatorFrame.minY, left: indicatorFrame.minX, bottom: indicatorViewSize.height - indicatorFrame.maxY, right: indicatorViewSize.width - indicatorFrame.maxX)
        // 文字
        let textSize = textProvider.contentSize
        let textFrame = textProvider.view.frame
        let textViewSize = textProvider.toastSize
        let textMargin = UIEdgeInsets(top: textFrame.minY, left: textFrame.minX, bottom: textViewSize.height - textFrame.maxY, right: textViewSize.width - textFrame.maxX)
        let width: CGFloat
        let height: CGFloat
        
        let maxSize = options.maxSize(UIApplication.shared.orientation)
        
        switch options.position {
        case .top:
            width = max(indicatorViewSize.width, textViewSize.width)
            height = indicatorMargin.top + indicatorSize.height + options.indicatorAndTextSpace + textSize.height + textMargin.bottom
            
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width, height: maxSize.height - options.indicatorAndTextSpace - indicatorSize.height - textMargin.bottom - indicatorMargin.top))
                return nil
            }
            
            let textFrame = CGRect(x: width * 0.5 - textSize.width * 0.5, y: height - textMargin.bottom - textSize.height, width: textSize.width, height: textSize.height)
            let indicatorFrame = CGRect(x: width * 0.5 - indicatorSize.width * 0.5, y: textFrame.minY - options.indicatorAndTextSpace - indicatorSize.height, width: indicatorSize.width, height: indicatorSize.height)
            return (textFrame, indicatorFrame, CGSize(width: width, height: height))
        case .bottom:
            width = max(indicatorViewSize.width, textViewSize.width)
            height = indicatorMargin.top + indicatorSize.height + options.indicatorAndTextSpace + textSize.height + textMargin.bottom
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width, height: maxSize.height - options.indicatorAndTextSpace - indicatorSize.height - textMargin.top - indicatorMargin.bottom))
                return nil
            }
            let textFrame = CGRect(x: width * 0.5 - textSize.width * 0.5, y: textMargin.top, width: textSize.width, height: textSize.height)
            
            let indicatorFrame = CGRect(x: width * 0.5 - indicatorSize.width * 0.5, y: textFrame.maxY + options.indicatorAndTextSpace, width: indicatorSize.width, height: indicatorSize.height)
            return (textFrame, indicatorFrame, CGSize(width: width, height: height))
        case .left:
            width = indicatorMargin.left + indicatorSize.width + options.indicatorAndTextSpace + textSize.width + textMargin.right
            height = max(indicatorViewSize.height, textViewSize.height)
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width - options.indicatorAndTextSpace - indicatorMargin.left - indicatorSize.width - textMargin.right, height: maxSize.height))
                return nil
            }
            let indicatorFrame = CGRect(x: indicatorMargin.left, y: height * 0.5 - indicatorSize.height * 0.5, width: indicatorSize.width, height: indicatorSize.height)
            let textFrame = CGRect(x: indicatorFrame.maxX + options.indicatorAndTextSpace, y: height * 0.5 - textSize.height * 0.5, width: textSize.width, height: textSize.height)
            return (textFrame, indicatorFrame, CGSize(width: width, height: height))
        case .right:
            width = indicatorMargin.left + indicatorSize.width + options.indicatorAndTextSpace + textSize.width + textMargin.right
            height = max(indicatorViewSize.height, textViewSize.height)
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width - options.indicatorAndTextSpace - indicatorMargin.right - indicatorSize.width - textMargin.left, height: maxSize.height))
                return nil
            }
            let indicatorFrame = CGRect(x: width - indicatorMargin.right - indicatorSize.width, y: height * 0.5 - indicatorSize.height * 0.5, width: indicatorSize.width, height: indicatorSize.height)
            let textFrame = CGRect(x: indicatorFrame.minX - options.indicatorAndTextSpace - textSize.width, y: height * 0.5 - textSize.height * 0.5, width: textSize.width, height: textSize.height)
            return (textFrame, indicatorFrame, CGSize(width: width, height: height))
        }
    }
    
    private func calculationSize2() {
        guard let indicatorProvider = indicatorToastProvider,
              let textProvider = textToastProvider else {
            return
        }
        // 指示器
        let indicatorSize = indicatorProvider.contentSize
        let indicatorFrame = indicatorProvider.view.frame
        let indicatorViewSize = indicatorProvider.toastSize
        
        let indicatorMargin = UIEdgeInsets(top: indicatorFrame.minY, left: indicatorFrame.minX, bottom: indicatorViewSize.height - indicatorFrame.maxY, right: indicatorViewSize.width - indicatorFrame.maxX)
        // 文字
        let textSize = textProvider.contentSize
        let textFrame = textProvider.view.frame
        let textViewSize = textProvider.toastSize
        let textMargin = UIEdgeInsets(top: textFrame.minY, left: textFrame.minX, bottom: textViewSize.height - textFrame.maxY, right: textViewSize.width - textFrame.maxX)
        let width: CGFloat
        let height: CGFloat
        
        let maxSize = options.maxSize(UIApplication.shared.orientation)
        
        switch options.position {
        case .top:
            width = max(indicatorViewSize.width, textViewSize.width)
            height = indicatorMargin.top + indicatorSize.height + options.indicatorAndTextSpace + textSize.height + textMargin.bottom
            
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width, height: maxSize.height - options.indicatorAndTextSpace - indicatorSize.height - textMargin.bottom - indicatorMargin.top))
                return
            }
            
            textProvider.view.frame = CGRect(x: width * 0.5 - textSize.width * 0.5, y: height - textMargin.bottom - textSize.height, width: textSize.width, height: textSize.height)
            indicatorProvider.view.frame = CGRect(x: width * 0.5 - indicatorSize.width * 0.5, y: textProvider.view.frame.minY - options.indicatorAndTextSpace - indicatorSize.height, width: indicatorSize.width, height: indicatorSize.height)
        case .bottom:
            width = max(indicatorViewSize.width, textViewSize.width)
            height = indicatorMargin.top + indicatorSize.height + options.indicatorAndTextSpace + textSize.height + textMargin.bottom
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width, height: maxSize.height - options.indicatorAndTextSpace - indicatorSize.height - textMargin.top - indicatorMargin.bottom))
                return
            }
            textProvider.view.frame = CGRect(x: width * 0.5 - textSize.width * 0.5, y: textMargin.top, width: textSize.width, height: textSize.height)
            
            indicatorProvider.view.frame = CGRect(x: width * 0.5 - indicatorSize.width * 0.5, y: textProvider.view.frame.maxY + options.indicatorAndTextSpace, width: indicatorSize.width, height: indicatorSize.height)
        case .left:
            width = indicatorMargin.left + indicatorSize.width + options.indicatorAndTextSpace + textSize.width + textMargin.right
            height = max(indicatorViewSize.height, textViewSize.height)
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width - options.indicatorAndTextSpace - indicatorMargin.left - indicatorSize.width - textMargin.right, height: maxSize.height))
                return
            }
            indicatorProvider.view.frame = CGRect(x: indicatorMargin.left, y: height * 0.5 - indicatorSize.height * 0.5, width: indicatorSize.width, height: indicatorSize.height)
            textProvider.view.frame = CGRect(x: indicatorProvider.view.frame.maxX + options.indicatorAndTextSpace, y: height * 0.5 - textSize.height * 0.5, width: textSize.width, height: textSize.height)
        case .right:
            width = indicatorMargin.left + indicatorSize.width + options.indicatorAndTextSpace + textSize.width + textMargin.right
            height = max(indicatorViewSize.height, textViewSize.height)
            if (width > maxSize.width) || (height > maxSize.height) {
                textView.resetContentSizeWithMaxSize(CGSize(width: maxSize.width - options.indicatorAndTextSpace - indicatorMargin.right - indicatorSize.width - textMargin.left, height: maxSize.height))
                return
            }
            indicatorProvider.view.frame = CGRect(x: width - indicatorMargin.right - indicatorSize.width, y: height * 0.5 - indicatorSize.height * 0.5, width: indicatorSize.width, height: indicatorSize.height)
            textProvider.view.frame = CGRect(x: indicatorProvider.view.frame.minX - options.indicatorAndTextSpace - textSize.width, y: height * 0.5 - textSize.height * 0.5, width: textSize.width, height: textSize.height)
        }
        let view = UIView()
        view.addSubview(indicatorProvider.view)
        view.addSubview(textProvider.view)
        delegate?.didCalculationView(view, viewSize: CGSize(width: width, height: height), sender: self)
    }
}

// MARK: - IndicatorWithTextToastable
extension MixToastItem {
    public func layoutToastView(with options: MixToastItemOptions<Indicator, Text>) {
        self.options = options
        indicatorView.layoutToastView(with: options.indicatorOptions)
        textView.layoutToastView(with: options.textOptions)
    }
    
    public func onMidifyUIInterfaceOrientation(_ orientation: UIInterfaceOrientation) {
//        indicatorToastProvider = nil
//        textToastProvider = nil
        layoutToastView(with: options)
    }
    
    public func startAnimating() {
        indicatorView.startAnimating()
    }
}

/// MixToastItemOptions
public struct MixToastItemOptions<Indicator: IndicatorToastItemable, Text: TextToastItem>: ToastItemOptions {
    public init() {}
    /// 指示器设置选项
    public var indicatorOptions = Indicator.Options.init()
    
    /// 文字设置选项
    public var textOptions = Text.Options.init()
    
    /// 指示器的位置
    public var position = MixToastItem<Indicator, Text>.IndicatorPosition.top
    
    /// 文字与指示器的间距
    public var indicatorAndTextSpace: CGFloat = 15
    
    /// 设置内容区域的最大size
    public var maxSize: (UIInterfaceOrientation) -> (CGSize) = { _ in
        return CGSize(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height - 200)
    }
}

extension MixToastItem {
    /// 指示器于文字之间的对齐方式
    public enum IndicatorPosition {
        case top, left, bottom, right
    }
    
    private struct SubToastProvider {
        let view: UIView
        let contentSize: CGSize
        let toastSize: CGSize
    }
}
