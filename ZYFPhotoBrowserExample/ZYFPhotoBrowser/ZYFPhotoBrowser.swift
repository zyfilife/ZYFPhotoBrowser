//
//  ZYFPhotoBrowser.swift
//  ZYFPhotoBrowser
//
//  Created by 朱益锋 on 2017/2/21.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit
import SDWebImage

let kPadding: CGFloat = 0

class ZYFPhotoBrowser: UIViewController, UIScrollViewDelegate, ZYFPhotoViewDelegate {
    
    fileprivate var visiblePhotoViews = Set<ZYFPhotoView>()
    fileprivate var reusablePhotoViews = Set<ZYFPhotoView>()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var photos = [ZYFPhoto]() {
        didSet {
            var i = 0
            for item in self.photos {
                item.index = i
                item.isShowing = i == self.firstShowIndex
                i += 1
            }
        }
    }
    
    var firstShowIndex = 0 {
        didSet {
            var i = 0
            for item in self.photos {
                item.isShowing = i == self.firstShowIndex
                i += 1
            }
        }
    }
    
    lazy var photoScrollView: UIScrollView = {
        let view = UIScrollView()
        view.frame = CGRect(x: -kPadding,
                            y: 0,
                            width: UIScreen.main.bounds.width + 2*kPadding,
                            height: UIScreen.main.bounds.height)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isPagingEnabled = true
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        self.view.addSubview(view)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        photoScrollView.contentSize = CGSize(width: photoScrollView.bounds.width*CGFloat(self.photos.count),
                                             height: photoScrollView.bounds.height)
        photoScrollView.contentOffset.x = CGFloat(self.firstShowIndex)*view.bounds.size.width
        showPhotos()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(view)
        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(self)
    }
    
    private func showPhotos() {
        
        if photos.count == 1 {
            self.showPhoto(at: 0)
            return
        }
        let visibleBounds = photoScrollView.bounds
        var firstIndex = Int(floor(visibleBounds.minX)/visibleBounds.width)
        var lastIndex = Int(floor(visibleBounds.maxX)/visibleBounds.width)
        
        firstIndex = max(0, firstIndex)
        lastIndex = min(photos.count - 1, lastIndex)
        for photoView in self.visiblePhotoViews {
            if photoView.index < firstIndex || photoView.index > lastIndex {
                self.reusablePhotoViews.insert(photoView)
                photoView.removeFromSuperview()
            }
        }
        self.visiblePhotoViews.subtract(self.reusablePhotoViews)
        while self.reusablePhotoViews.count > 2 {
            let _ = self.reusablePhotoViews.removeFirst()
        }
        
        for i in firstIndex...lastIndex {
            if !self.isShowingPhotoView(at: i) {
                self.showPhoto(at: i)
            }
        }
    }
    
    private func isShowingPhotoView(at index: Int) -> Bool {
        for photoView in self.visiblePhotoViews {
            if photoView.index == index {
                return true
            }
        }
        return false
    }
    
    private func showPhoto(at index: Int) {
        var photoView: ZYFPhotoView!
        if let _photoView = dequeueReusablePhotoView() {
            photoView = _photoView
        }else {
            photoView = ZYFPhotoView()
            photoView.zyf_delegate = self
        }
        let bounds = photoScrollView.bounds
        photoView.frame = CGRect(x: bounds.size.width*CGFloat(index),
                                 y: 0,
                                 width: bounds.size.width,
                                 height: bounds.size.height)
        if index < photos.count {
            let photo = photos[index]
            photoView.photo = photo
            photoView.index = index
            visiblePhotoViews.insert(photoView)
            photoScrollView.addSubview(photoView)
            print("index: \(index), photoView: \(photoView.frame)")
            loadImage(near: index)
        }
    }
    
    private func loadImage(near index: Int) {
        if index > 0 {
            let photo = photos[index-1]
            SDWebImageManager.download(withUrl: photo.url)
        }
        if index < photos.count - 1 {
            let photo = photos[index + 1]
            SDWebImageManager.download(withUrl: photo.url)
        }
    }
    
    private func dequeueReusablePhotoView() -> ZYFPhotoView? {
        return self.reusablePhotoViews.popFirst()
    }
    
    func updateToolBarState() {
        
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.showPhotos()
        self.updateToolBarState()
    }
    
    
    // MARK: - ZYFPhotoViewDelegate
    
    func photoViewWillHide(photoView: ZYFPhotoView) {
       
    }
    
    func photoViewSingleTap(photoView: ZYFPhotoView) {
        self.view.backgroundColor = .clear
    }
    
    func photoViewImageFinishLoad(photoView: ZYFPhotoView) {
        
    }
    
    func photoViewDidEndZoom(photoView: ZYFPhotoView) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

}
