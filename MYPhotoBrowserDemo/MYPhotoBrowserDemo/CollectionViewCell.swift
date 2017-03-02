//
//  CollectionViewCell.swift
//  MYPhotoBrowserDemo
//
//  Created by 朱益锋 on 2017/2/27.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var rowNumber: Int = 0 {
        didSet {
            self.imageView.image = UIImage(named: "\(rowNumber+1)")
        }
    }
    
    
}
