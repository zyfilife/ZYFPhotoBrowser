//
//  MYPhotoBrowser.swift
//  MYPhotoBrowserDemo
//
//  Created by 朱益锋 on 2017/2/21.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

let kPadding: CGFloat = 10
let kPhotoViewTagOffset = 1000

class MYPhotoBrowser: UIViewController, UIScrollViewDelegate, MYPhotoViewDelegate {
    
    fileprivate var visiblePhotoViews = Set<MYPhotoView>()
    fileprivate var reusablePhotoViews = Set<MYPhotoView>()
    
    fileprivate var isStatusBarHidden = false
    
    var photos = [MYPhoto]() {
        didSet {
            var i = 0
            for item in self.photos {
                item.index = i
                item.isFirstShow = i == self.currentPhotoIndex
                i += 1
            }
        }
    }
    
    var currentPhotoIndex = 0 {
        didSet {
            var i = 0
            for item in self.photos {
                item.isFirstShow = i == self.currentPhotoIndex
                i += 1
            }
            
            if self.isViewLoaded {
                self.photoScrollView.contentOffset = CGPoint(x: CGFloat(self.currentPhotoIndex)*self.photoScrollView.frame.size.width, y: 0)
                self.showPhotos()
            }
        }
    }
    
    var photoScrollView: UIScrollView!
    
    override func loadView() {
        super.loadView()
        self.isStatusBarHidden = UIApplication.shared.isStatusBarHidden
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoScrollView = UIScrollView()
        var frame = self.view.bounds
        frame.origin.x -= kPadding
        frame.size.width += 2*kPadding
        photoScrollView.frame = frame
        photoScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoScrollView.isPagingEnabled = true
        photoScrollView.delegate = self
        photoScrollView.showsVerticalScrollIndicator = false
        photoScrollView.showsHorizontalScrollIndicator = false
        photoScrollView.backgroundColor = .clear
        photoScrollView.contentSize = CGSize(width: frame.size.width*CGFloat(self.photos.count), height: 0)
        photoScrollView.contentOffset = CGPoint(x: CGFloat(self.currentPhotoIndex)*frame.size.width, y: 0)
        
        self.view.backgroundColor = .black

        self.view.addSubview(self.photoScrollView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self.view)
        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(self)
        if self.currentPhotoIndex == 0 {
            self.showPhotos()
        }
    }
    
    func showPhotos() {
        if self.photos.count == 1 {
            self.showPhotos(at: 0)
            return
        }
        let visibleBounds = self.photoScrollView.bounds
        var firstIndex = Int(floor(visibleBounds.minX + kPadding*2)/visibleBounds.width)
        var lastIndex = Int(floor(visibleBounds.maxX - kPadding*2 - 1)/visibleBounds.width)
        if firstIndex < 0 {
            firstIndex = 0
        }
        if firstIndex >= self.photos.count {
            lastIndex = self.photos.count - 1
        }
        var photoViewIndex = 0
        for photoView in self.visiblePhotoViews {
            photoViewIndex = photoView.my_tag
            if photoViewIndex < firstIndex || photoViewIndex > lastIndex {
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
                self.showPhotos(at: i)
            }
        }
    }
    
    func showPhotos(at index: Int) {
        
        var photoView = self.dequeueReusablePhotoView()
        if photoView == nil {
            photoView = MYPhotoView()
            photoView?.my_delegate = self
        }
        let bounds = self.photoScrollView.bounds
        var photoViewFrame = bounds
        photoViewFrame.size.width -= 2*kPadding
        photoViewFrame.origin.x = bounds.size.width*CGFloat(index) + kPadding
        photoView?.tag = kPhotoViewTagOffset + index
        
        if self.photos.count > 0 && index < self.photos.count {
            let photo = self.photos[index]
            photoView?.frame = photoViewFrame
            photoView?.photo = photo
            
            self.visiblePhotoViews.insert(photoView!)
            self.photoScrollView.addSubview(photoView!)
            
            self.loadImage(near: index)
        }
    }
    
    func loadImage(near index: Int) {
        if index > 0 {
            let photo = self.photos[index-1]
            SDWebImageManager.download(withUrl: photo.url)
        }
        if index < self.photos.count - 1 {
            let photo = self.photos[index + 1]
            SDWebImageManager.download(withUrl: photo.url)
        }
    }
    
    func isShowingPhotoView(at index: Int) -> Bool {
        for photoView in self.visiblePhotoViews {
            if photoView.my_tag == index {
                return true
            }
        }
        return false
    }
    
    func dequeueReusablePhotoView() -> MYPhotoView? {
        return self.reusablePhotoViews.popFirst()
    }
    
    func updateToolBarState() {
        
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.showPhotos()
        self.updateToolBarState()
    }
    
    
    // MARK: - MYPhotoViewDelegate
    
    func photoViewWillHide(photoView: MYPhotoView) {
        UIApplication.shared.setStatusBarHidden(self.isStatusBarHidden, with: UIStatusBarAnimation.none)
        UIApplication.shared.isStatusBarHidden = self.isStatusBarHidden
    }
    
    func photoViewSingleTap(photoView: MYPhotoView) {
        self.view.backgroundColor = .clear
    }
    
    func photoViewImageFinishLoad(photoView: MYPhotoView) {
        
    }
    
    func photoViewDidEndZoom(photoView: MYPhotoView) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

}
