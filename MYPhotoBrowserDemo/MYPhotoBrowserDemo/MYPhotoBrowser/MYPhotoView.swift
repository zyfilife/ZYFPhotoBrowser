//
//  MYPhotoView.swift
//  MYPhotoBrowserDemo
//
//  Created by 朱益锋 on 2017/2/21.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

protocol MYPhotoViewDelegate:NSObjectProtocol {
    func photoViewImageFinishLoad(photoView: MYPhotoView)
    func photoViewWillHide(photoView: MYPhotoView)
    func photoViewSingleTap(photoView: MYPhotoView)
    func photoViewDidEndZoom(photoView: MYPhotoView)
}

class MYPhotoView: UIScrollView, UIScrollViewDelegate {

    var photo: MYPhoto? {
        didSet {
            guard let photo = self.photo else {
                return
            }
            self.showImage(photo)
        }
    }
    
    var my_tag: Int {
        return self.tag - kPhotoViewTagOffset
    }
    
    var isDoubleTap = false
    
    var imageView: UIImageView!
    
    weak var my_delegate: MYPhotoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        self.clipsToBounds = true
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(self.imageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(MYPhotoView.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delaysTouchesBegan = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MYPhotoView.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(singleTap)
    }
    
    // MARK: - Action
    
    func handleSingleTap(_ sender: UITapGestureRecognizer) {
        self.isDoubleTap = false
        
        self.perform(#selector(MYPhotoView.hide), with: nil, afterDelay: 0.2)
    }
    
    func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        self.isDoubleTap = true
        let touchPoint = sender.location(in: self)
        if self.zoomScale == self.maximumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else {
            self.zoom(to: CGRect(origin: touchPoint, size: CGSize(width: 1, height: 1)), animated: true)
        }
    }
    
    func hide() {
        if self.isDoubleTap {
            return
        }
        
        self.my_delegate?.photoViewWillHide(photoView: self)
        
        self.contentOffset = CGPoint.zero
        
        let duration: TimeInterval = 0.15
        
        if let srcImageView = self.photo?.srcImageView {
            
            if srcImageView.clipsToBounds {
                
            }
            
            let window = UIApplication.shared.delegate!.window!
            let rect = window!.convert(srcImageView.frame, from: srcImageView.superview)
            print(rect)
            
            UIView.animate(withDuration: duration + 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                self.imageView.frame = rect
                self.imageView.alpha = 0
                if let images = self.imageView.image?.images {
                    if images.count > 0 {
                        self.imageView.image = images[0]
                    }
                }
                self.my_delegate?.photoViewSingleTap(photoView: self)
            }, completion: { (finished) in
                self.photo?.srcImageView?.image = self.photo?.placeholder
                self.my_delegate?.photoViewDidEndZoom(photoView: self)
            })
        }
        
        
    }
    
    func reset() {
        self.imageView.image = self.photo?.capture
        self.imageView.contentMode = .scaleAspectFill
    }
    
    func showImage(_ photo: MYPhoto) {
        if photo.isFirstShow {
            self.imageView.image = photo.placeholder
            photo.srcImageView?.image = nil
            
            if let url = photo.url {
                if !url.absoluteString.hasSuffix("gif") {
                    self.imageView.sd_setImage(with: url, placeholderImage: photo.placeholder, options: [.lowPriority, .retryFailed], completed: { [weak self, weak photo] (image, error, cacheType, imageURL) in
                        photo?.image = image
                        self?.adjustFrame()
                    })
                }
            }else {
                self.photoStartLoad()
            }
        }else {
            self.photoStartLoad()
        }
        
        self.adjustFrame()
    }
    
    func photoStartLoad() {
        if let image = self.photo?.image {
            self.isScrollEnabled = true
            self.imageView.image = image
        }else {
            self.isScrollEnabled = false
            self.imageView.sd_setImage(with: self.photo?.url, placeholderImage: self.photo?.srcImageView?.image, options: .lowPriority, progress: { (_, _) in
                
            }, completed: { (image, _, _, _) in
                self.photoDidFinishLoad(with: image)
            })
        }
    }
    
    func adjustFrame() {
        guard let image = self.imageView.image, let photo = self.photo else {
            return
        }
        
        let boundsSize = self.bounds.size
        let boundsWidth = boundsSize.width
        let boundsHeight = boundsSize.height
        
        let imageSize = image.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        
        var minScale = boundsWidth/imageWidth
        if minScale > 1 {
            minScale = 1.0
        }
        
        var maxScale: CGFloat = 2.0
        maxScale = maxScale / UIScreen.main.scale
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
        self.zoomScale = minScale
        
        var imageFrame = CGRect(x: 0, y: 0, width: boundsWidth, height: imageHeight*boundsWidth/imageWidth)
        
        self.contentSize = CGSize(width: 0, height: imageFrame.size.height)
        
        if imageFrame.size.height < boundsHeight {
            imageFrame.origin.y = floor((boundsHeight - imageFrame.size.height) / 2.0)
        }else {
            imageFrame.origin.y = 0
        }
        
        if photo.isFirstShow {
            photo.isFirstShow = false
            if let scrImageView = photo.srcImageView {
                let window = UIApplication.shared.delegate!.window!
                self.imageView.frame = window!.convert(scrImageView.frame, from: scrImageView.superview)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.frame = imageFrame
            }, completion: { (finished) in
                self.photo?.srcImageView?.image = self.photo?.placeholder
                self.photoStartLoad()
            })
        }else {
            self.imageView.frame = imageFrame
        }
        
    }
    
    func photoDidFinishLoad(with image: UIImage?) {
        if image != nil {
            self.isScrollEnabled = true
            self.photo?.image = image
            self.my_delegate?.photoViewImageFinishLoad(photoView: self)
        }else {
            
        }
        self.adjustFrame()
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

}
