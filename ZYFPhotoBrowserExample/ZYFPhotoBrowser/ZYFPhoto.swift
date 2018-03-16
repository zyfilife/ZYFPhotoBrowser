//
//  ZYFPhoto.swift
//  ZYFPhotoBrowser
//
//  Created by 朱益锋 on 2017/2/21.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

enum ZYFPhotoAdjustment {
    case moveUp, moveDown, moveNo
}

class ZYFPhoto: NSObject {
    
    var url: URL?
    
    var image: UIImage?
    
    var index: Int = 0
    
    var isShowing = true
    
    var adjustMode = ZYFPhotoAdjustment.moveNo
    
    var placeholder: UIImage?
    
    var sourceImageView: UIImageView?
    
    var capture: UIImage? {
        guard let sourceImageView = self.sourceImageView else {
            return nil
        }
        if sourceImageView.clipsToBounds {
            UIGraphicsBeginImageContextWithOptions(sourceImageView.bounds.size, true, 0.0)
            guard let context = UIGraphicsGetCurrentContext() else {
                return nil
            }
            sourceImageView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }else {
            return sourceImageView.image
        }
    }
    
    init(url: URL, index: Int, sourceImageView: UIImageView?) {
        super.init()
        self.url = url
        self.index = index
        self.sourceImageView = sourceImageView
        self.placeholder = sourceImageView?.image
    }
    
    init(image: UIImage, index: Int, sourceImageView: UIImageView?) {
        super.init()
        self.image = image
        self.index = index
        self.sourceImageView = sourceImageView
        self.placeholder = sourceImageView?.image
    }
}
