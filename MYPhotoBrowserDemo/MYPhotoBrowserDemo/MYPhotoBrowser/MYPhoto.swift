//
//  MYPhoto.swift
//  MYPhotoBrowserDemo
//
//  Created by 朱益锋 on 2017/2/21.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

enum MYPhotoAdjustment {
    case moveUp, moveDown, moveNo
}

class MYPhoto: NSObject {
    
    var url: URL?
    
    var image: UIImage?
    
    var srcImageView: UIImageView? {
        didSet {
            guard let srcImageView = self.srcImageView else {
                return
            }
            self.placeholder = srcImageView.image
        }
    }
    
    var placeholder: UIImage?
    
    var capture: UIImage? {
        guard let srcImageView = self.srcImageView else {
            return nil
        }
        if srcImageView.clipsToBounds {
            return self.capture(view: srcImageView)
        }else {
            return self.srcImageView?.image
        }
    }
    
    var isFirstShow = true
    
    var adjustMode = MYPhotoAdjustment.moveNo
    
    var isSaved = false
    
    var index: Int = 0
    
    func capture(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }

}
