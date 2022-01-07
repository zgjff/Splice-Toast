//
//  ImageToastItem.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit

/// 显示自定义图像的`toast`,可提供动画
public final class ImageToastItem: IndicatorToastItemable {
    /// `ImageToast`的数据类型
    ///
    /// `local`: 使用本地`UIImage`
    ///
    /// `web`: 使用网络图片链接
    public enum DataSource {
        /// 使用本地`UIImage`
        case local(image: UIImage, display: (() -> (UIImageView))?)
        /// 使用网络图片链接
        case web(url: URL, display: (_ url: URL, _ imageView: UIImageView) -> (UIImageView?))
    }
    
    public typealias Options = ImageToastItemOptions
    weak public var delegate: ToastableDelegate?
    
    private lazy var imageView = UIImageView()
    private let data: DataSource
    
    /// 初始化包含`image`的`toast`
    /// - Parameters:
    ///   - data: 数据源
    ///
    ///   - example1: 使用本地单张图片
    ///
    ///         ImageToastItem(data: .local(image: image, display: nil))
    ///
    ///   - example2: 使用本地多张图片组成动画
    ///
    ///         let image = UIImage.animatedImage(with: [image1, image2, image3, image4], duration: 2.0)
    ///         ImageToastItem(data: .local(image: imgae, display: nil))
    ///
    ///   - example3: 使用`SDWebImage`的`SDAnimatedImageView`展示gif图片
    ///
    ///         let animatedImage = SDAnimatedImage(named: "image.gif")
    ///         ImageToastItem(data: .local(image: animatedImage, display: {
    ///             return SDAnimatedImageView()
    ///         }))
    ///
    ///   - example4: 使用`SDWebImage`展示网络图片
    ///
    ///         ImageToastItem(data: .web(url: url, display: { url, imageView in
    ///             imageView.sd_setImage(with: url, placeholderImage: nil)
    ///             return nil
    ///         }))
    ///
    ///   - example5: 使用`SDWebImage`的`SDAnimatedImageView`展示网络`WebP`图片
    ///
    ///         ImageToastItem(data: .web(url: url, display: { url, _ in
    ///             let imageView = SDAnimatedImageView()
    ///             imageView.sd_setImage(with: url, placeholderImage: nil)
    ///             return imageView
    ///         }))
    ///   - example6: 使用`YYWebImage`跟`Kingfisher`与上述`SDWebImage`逻辑同理
    public init(data: DataSource) {
        defer {
            imageView.contentMode = .scaleAspectFit
        }
        self.data = data
        switch data {
        case let .local(image, display):
            if let display = display {
                imageView = display()
                imageView.image = image
                return
            }
            guard let animatedImages = image.images else {
                imageView.image = image
                return
            }
            imageView.animationImages = animatedImages
            imageView.animationDuration = image.duration
            imageView.animationRepeatCount = Int.max
        case let .web(url, display):
            if url.isFileURL {
                let image = UIImage(contentsOfFile: url.absoluteString)
                imageView.image = image
                return
            }
            if let dv = display(url, imageView) {
                imageView = dv
            }
        }
    }
    
    
    /// 创建显示本地图片的组件
    /// - Parameter image: UIImage
    public convenience init(image: UIImage) {
        self.init(data: .local(image: image, display: nil))
    }
    
    /// 创建显示网络图片的组件
    /// - Parameters:
    ///   - url: 图片url
    ///   - display: `UIImageView`显示网络图片的逻辑
    public convenience init(url: URL, display: @escaping (_ url: URL, _ imageView: UIImageView) -> ()) {
        self.init(data: .web(url: url, display: { url, imageView in
            display(url, imageView)
            return nil
        }))
    }
}

// MARK: - IndicatorToastItemable
extension ImageToastItem {
    public func layoutToastView(with options: ImageToastItemOptions) {
        options.configUIImageView?(imageView)
        let (imageSize, toastSize) = calculationSize(with: options)
        imageView.frame = CGRect(x: options.margin.left, y: options.margin.top, width: imageSize.width, height: imageSize.height)
        delegate?.didCalculationView(imageView, viewSize: toastSize, sender: self)
        startAnimating()
    }
    
    public func startAnimating() {
        imageView.startAnimating()
    }
}

// MARK: - private
private extension ImageToastItem {
    func calculationSize(with options: ImageToastItemOptions) -> (image: CGSize, toast: CGSize) {
        let imageSize: CGSize
        switch options.imageSize {
        case .fit:
            switch data {
            case .local:
                imageView.sizeToFit()
                imageSize = imageView.bounds.size
            case .web:
                fatalError("网络图片toast必须设置固定的大小")
            }
        case .fixed(let s):
            imageSize = s
        }
        let width = imageSize.width + options.margin.left + options.margin.right
        let height = imageSize.height + options.margin.top + options.margin.bottom
        return (imageSize, CGSize(width: width, height: height))
    }
}

// MARK: - ImageToastOptions配置

/// 自定义图像`taost`配置项
public struct ImageToastItemOptions: ToastItemOptions {
    public init() {}
    /// 设置图像外边距
    public var margin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    /// 设置图像大小---默认是固定的大小
    public var imageSize = ImageSize.fixed(CGSize(width: 60, height: 60))
    
    /// 通过block方式设置UIImageView的属性
    public var configUIImageView: ((UIImageView) -> ())?
}

extension ImageToastItemOptions {
    /// 图片大小
    public enum ImageSize {
        /// 自适应
        case fit
        /// 固定的size
        case fixed(CGSize)
    }
}
