//
//  EHTiledImageView.swift
//  TestLarge
//
//  Created by 黄坤鹏 on 2021/5/13.
//

import Foundation
import UIKit
import CoreGraphics

class EHTiledImageView:UIView{
    
    fileprivate lazy var image = UIImage()
    
    fileprivate lazy var imageRect = CGRect()
    
    fileprivate lazy var imageScale = CGFloat()
    
    override class var layerClass: AnyClass {
        return CATiledLayer.classForCoder()
    }
    
    init(frame:CGRect,image:UIImage,scale:CGFloat){
        super.init(frame: frame)
        if scale > 0 {
            self.image = image
            self.imageScale = scale
            let tiledLayer = self.layer as! CATiledLayer
            //根据图片的缩放计算scrollview的缩放次数
            // 图片相对于视图放大了1/imageScale倍，所以用log2(1/imageScale)得出缩放次数，
            // 然后通过pow得出缩放倍数，至于为什么要加1，
            // 是希望图片在放大到原图比例时，还可以继续放大一次（即2倍），可以看的更清晰
          
            let lev = ceil(log2(1/scale))+1
            tiledLayer.levelsOfDetail = 1;
            tiledLayer.levelsOfDetailBias = Int(lev)
            //        tiledLayer.tileSize  此处tilesize使用默认的256x256即可
        }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        autoreleasepool {
            let imageCutRect = CGRect(x: rect.origin.x / imageScale, y: rect.origin.y / imageScale, width: rect.size.width / imageScale, height: rect.size.height / imageScale)
           
            guard let cgImage = self.image.cgImage else {return}
            guard let imageRef = cgImage.cropping(to: imageCutRect)else {return}
            
            let tileImage = UIImage(cgImage: imageRef)
            guard let context = UIGraphicsGetCurrentContext() else {return}
            UIGraphicsPushContext(context)
            tileImage.draw(in:rect)
            UIGraphicsPopContext()
        }
    }
    
    deinit {
        print("EHTiledImageView is deinit")
    }
    
}
