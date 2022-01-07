//
//  RowAction.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import Foundation

struct RowAction {
    let title: String
    let action: String
}

extension RowAction {
    static let showTextAtTop = RowAction(title: "顶部显示文字", action: "onClickShowTextAtTop")
    static let showTextAtCenter = RowAction(title: "居中显示文字", action: "onClickShowTextAtCenter")
    static let showAttributedStringText = RowAction(title: "显示富文本", action: "onClickShowAttributedStringText")
    static let showActivity = RowAction(title: "显示系统的指示器", action: "onClickShowActivity")
    static let showArcrotation = RowAction(title: "显示三色转动的的指示器", action: "onClickShowArcrotation")
    static let showSingleImage = RowAction(title: "显示图片", action: "onClickShowSingleImage")
    static let showMultipleImages = RowAction(title: "显示多个图片动画", action: "onClickShowMultipleImages")
    static let showWebImage = RowAction(title: "显示网络图片", action: "onClickShowWebImage")
    static let showSDGifImage = RowAction(title: "使用SDAnimatedImageView显示gif图片", action: "onClickShowSDGifImage")
    static let showMixImageAndTextToast = RowAction(title: "混合图片+文字的toast", action: "onClickShowMixImageAndTextToast")
    static let showMixActivityAndTextToast = RowAction(title: "混合系统指示器+文字的toast", action: "onClickShowMixActivityAndTextToast")
    static let showMixArcrotationAndTextToast = RowAction(title: "混合三色转动指示器+文字的toast", action: "onClickShowMixArcrotationAndTextToast")
    static let showUsingColorContainerTextToast = RowAction(title: "使用带有色彩的容器来显示toast", action: "onClickShowUsingColorContainerTextToast")
    static let showUsingGradientContainerTextToast = RowAction(title: "使用渐变色的容器来显示toast", action: "onClickShowUsingGradientContainerTextToast")
    
}
