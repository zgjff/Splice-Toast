//
//  TextToastItem.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 显示文字的`toast`的默认实现
public final class TextToastItem: TextToastItemable {
    public typealias Options = TextToastItemOptions
    private lazy var label: UILabel = {
       let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingTail
        l.numberOfLines = 0
        return l
    }()
    
    weak public var delegate: ToastableDelegate?
    private let attributedString: NSAttributedString
    private var labelMargin = UIEdgeInsets.zero
    private var options = Options.init()
    public init(text: String) {
        attributedString = NSAttributedString(string: text)
    }

    public init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    deinit {
        print("TextToastItem---deinit", self, type(of: self))
    }
}

// MARK: - TextToastable
extension TextToastItem {
    public func layoutToastView(with options: TextToastItemOptions) {
        self.options = options
        labelMargin = options.margin
        configLabel(with: options)
        let maxSize = options.maxSize(UIApplication.shared.orientation)
        let (lsize, vsize) = calculationSize(with: options.margin, maxSize: maxSize)
        label.frame = CGRect(origin: CGPoint(x: options.margin.left, y: options.margin.top), size: lsize)
        delegate?.didCalculationView(label, viewSize: vsize, sender: self)
    }
    
    public func onMidifyUIInterfaceOrientation(_ orientation: UIInterfaceOrientation) {
        let maxSize = options.maxSize(orientation)
        let (lsize, vsize) = calculationSize(with: options.margin, maxSize: maxSize)
        label.frame = CGRect(origin: CGPoint(x: options.margin.left, y: options.margin.top), size: lsize)
        delegate?.didCalculationView(label, viewSize: vsize, sender: self)
    }
    
    public func resetContentSizeWithMaxSize(_ size: CGSize) {
        let (lsize, vsize) = calculationSize(with: labelMargin, maxSize: size)
        label.frame = CGRect(origin: CGPoint(x: labelMargin.left, y: labelMargin.top), size: lsize)
        delegate?.didCalculationView(label, viewSize: vsize, sender: self)
    }
}

// MARK: - private
private extension TextToastItem {
    func configLabel(with options: TextToastItemOptions) {
        options.configLabel?(label)
        if options.lineSpacing <= 0 {
            label.attributedText = attributedString
            return
        }
        let str = attributedString.string
        let att = NSMutableAttributedString(attributedString: attributedString)
        let range = str.nsRange(from: str.startIndex..<str.endIndex)
        attributedString.enumerateAttribute(.paragraphStyle, in: range, options: []) { [weak self] value, subRange, _ in
            guard let self = self else {
                return
            }
            let paragraphStyle: NSMutableParagraphStyle
            if let mutableStyle = value as? NSMutableParagraphStyle {
                paragraphStyle = mutableStyle
            } else if let style = value as? NSParagraphStyle {
                let obj = NSMutableParagraphStyle()
                obj.setParagraphStyle(style)
                paragraphStyle = obj
            } else {
                paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = self.label.textAlignment
                paragraphStyle.lineBreakMode = self.label.lineBreakMode
            }
            paragraphStyle.lineSpacing = options.lineSpacing
            att.addAttribute(.paragraphStyle, value: paragraphStyle, range: subRange)
        }
        label.attributedText = att
    }
    
    func calculationSize(with margin: UIEdgeInsets, maxSize: CGSize) -> (CGSize, CGSize) {
        let labelMaxSize = CGSize(width: maxSize.width - margin.left - margin.right, height: maxSize.height - margin.top - margin.bottom)
        var labelSize = label.sizeThatFits(labelMaxSize)
        labelSize.width = labelSize.width > labelMaxSize.width ? labelMaxSize.width : labelSize.width
        labelSize.height = labelSize.height > labelMaxSize.height ? labelMaxSize.height : labelSize.height
        let w = labelSize.width + margin.left + margin.right
        let h = labelSize.height + margin.top + margin.bottom
        let viewSize = CGSize(width: w, height: h)
        return (labelSize, viewSize)
    }
}

// MARK: - 文字配置

/// 文字`taost`配置项
public struct TextToastItemOptions: ToastItemOptions {
    public init() {}
    
    /// 通过block方式设置label的属性
    public var configLabel: ((UILabel) -> ())?
    
    /// 多行显示时的文字行间隔。默认为6；少于0无效；
    ///
    /// 设置此项,可能会导致`TextToastProvider`通过`init(attributedString: NSAttributedString)`方式初始化时,设置的`paragraphStyle`行间距无效
    public var lineSpacing: CGFloat = 6
    
    /// 设置文字label外边距
    public var margin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    /// item的最大size
    public var maxSize: (UIInterfaceOrientation) -> (CGSize) = { _ in
        return CGSize(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height - 200)
    }
}
