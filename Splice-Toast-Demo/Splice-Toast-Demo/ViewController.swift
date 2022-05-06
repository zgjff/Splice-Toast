//
//  ViewController.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import UIKit
import SDWebImage
private let cellReuseIdentifier = "UITableViewCell"

class ViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    
    private var datas: [RowAction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        view.addSubview(tableView)
        configDatas()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(clear))
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @IBAction private func clear() {
        view.hideAllToasts()
    }
    
    private func configDatas() {
        datas = [
            .showText, .showAttributedStringText,
            .showActivity, .showArcrotation, .showSingleImage, .showMultipleImages,
            .showWebImage, .showSDGifImage, .showMixImageAndTextToast, .showMixActivityAndTextToast,
            .showMixArcrotationAndTextToast,
            
            .showUsingColorContainerTextToast, .showUsingGradientContainerTextToast
        ]
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = datas[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = datas[indexPath.row].action
        if action.isEmpty {
            return
        }
        let sel = Selector(action)
        perform(sel)
    }
}

// MARK: - cell actions
private extension ViewController {
    @IBAction func onClickShowText() {
        view.makeToast(TextToastItem(text: "For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud."))
            .duration(.distantFuture)
            .didClick(block: { [weak self] c in
                self?.view.hideToast(c)
            })
            .show()
    }
    
    @IBAction func onClickShowAttributedStringText() {
        let str = "我是一个富文本toast,你可以方便的使用。"
        let att = NSMutableAttributedString(string: str)
        let r = (str as NSString).range(of: "富文本")
        att.addAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.orange], range: r)
        view.makeToast(TextToastItem(attributedString: att))
            .duration(.distantFuture)
            .position(.quarter).show()
    }
    
    @IBAction func onClickShowActivity() {
        view.makeToast(ActivityToastItem())
            .duration(.distantFuture)
            .position(.threeQuarter).show()
    }
    
    @IBAction func onClickShowArcrotation() {
        view.makeToast(ArcrotationToastItem()).duration(.distantFuture).position(.bottom).show()
    }
    
    @IBAction func onClickShowSingleImage() {
        if #available(iOS 13.0, *) {
            let img = UIImage(systemName: "mic")!
            view.makeToast(ImageToastItem(image: img))
                .duration(.distantFuture)
                .position(.safeTop).show()
        }
    }
    
    @IBAction func onClickShowMultipleImages() {
        if #available(iOS 13.0, *) {
            let img1 = UIImage(systemName: "mic")!
            let img2 = UIImage(systemName: "mic.fill")!
            let img3 = UIImage(systemName: "mic.circle")!
            let img4 = UIImage(systemName: "mic.circle.fill")!
            let img = UIImage.animatedImage(with: [img1.withTintColor(.orange), img2, img3, img4], duration: 2)!
            view.makeToast(ImageToastItem(image: img))
                .duration(.distantFuture)
                .position(.quarter).show()
        }
    }
    
    @IBAction func onClickShowWebImage() {
        guard let url = URL(string: "http://apng.onevcat.com/assets/elephant.png") else {
            return
        }
        view.makeToast(ImageToastItem(url: url, display: { url, imageView in
            imageView.sd_setImage(with: url, completed: nil)
        })).updateItem(options: { opt in
            opt.imageSize = .fixed(CGSize(width: 150, height: 150))
            opt.configUIImageView = { iv in
                iv.contentMode = .scaleAspectFill
                iv.clipsToBounds = true
            }
        }).duration(.distantFuture)
        .position(.center).show()
    }
    
    @IBAction func onClickShowSDGifImage() {
        guard let url = URL(string: "http://assets.sbnation.com/assets/2512203/dogflops.gif") else {
            return
        }
        view.makeToast(ImageToastItem(data: .web(url: url, display: { url, _ in
            let animatedView = SDAnimatedImageView()
            animatedView.sd_setImage(with: url, completed: nil)
            return animatedView
        }))).updateItem(options: { opt in
            opt.imageSize = .fixed(CGSize(width: 150, height: 150))
            opt.margin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }).duration(.distantFuture)
            .position(.threeQuarter).show()
    }
    
    @IBAction func onClickShowMixImageAndTextToast() {
        if #available(iOS 13.0, *) {
            let img = UIImage(systemName: "mic")!
            view.makeToast(MixToastItem(indicator: ImageToastItem(image: img), text: TextToastItem(text: "我是图片+文字toast")))
                .position(.bottom)
                .duration(.distantFuture)
                .show()
        }
    }
    
    @IBAction func onClickShowMixActivityAndTextToast() {
        view.makeToast(MixToastItem(indicator: ActivityToastItem(), text: TextToastItem(text: "For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud.")))
            .position(.safeTop).duration(.distantFuture).show()
    }
    
    @IBAction func onClickShowMixArcrotationAndTextToast() {
        view.makeToast(MixToastItem(indicator: ArcrotationToastItem(), text: TextToastItem(text: "我是三色转动指示器+文字toast")))
            .position(.quarter).duration(.distantFuture).show()
    }
    
    @IBAction func onClickShowUsingColorContainerTextToast() {
        view.makeToast(TextToastItem(text: "我是一个带色彩背景的toast"))
            .useContainer(ColorfulContainer<TextToastItem>(color: .purple))
            .duration(.distantFuture)
            .show()
    }
    
    @IBAction func onClickShowUsingGradientContainerTextToast() {
        let container = GradientContainer<TextToastItem>(colors: [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.magenta.cgColor], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        view.makeToast(TextToastItem(text: "我是一个带色彩背景的toast"))
            .useContainer(container)
            .position(.threeQuarter)
            .duration(.distantFuture)
            .show()
    }
}
