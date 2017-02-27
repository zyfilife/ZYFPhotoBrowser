//
//  SDWebImageManagerExtensions.swift
//  MYPhotoBrowserDemo
//
//  Created by 朱益锋 on 2017/2/21.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import Foundation

extension SDWebImageManager {
    class func download(withUrl url: URL?) {
        guard let url = url else {
            print(#line, "url is nil")
            return
        }
        let _ = self.shared().imageDownloader?.downloadImage(with: url, options: .lowPriority, progress: nil, completed: { (_, _, _, _) in
            
        })
    }
}

