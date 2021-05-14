//
//  EHLargeImageScrollView.swift
//  EasyAtHome
//
//  Created by 黄坤鹏 on 2021/5/13.
//  大图、长图加载

import Foundation
import UIKit
import CoreGraphics

class EHLargeImageScrollView: UIScrollView {
    fileprivate lazy var image = UIImage()
    fileprivate lazy var imageScale = CGFloat()
    fileprivate var tiledView:EHTiledImageView?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        //UIScrollViewDecelerationRateFast
        self.decelerationRate = .fast
        self.delegate = self
    }
    
    ///加载图片
    func load(image:UIImage?){
        guard let image = image else {
            return
        }
        
        // 根据图片实际尺寸和屏幕尺寸计算图片视图的尺寸
        self.image = image
       
        var imageRect = CGRect(x: 0, y: 0, width: CGFloat(self.image.cgImage?.width ?? 0), height: CGFloat(self.image.cgImage?.height ?? 0))
        if imageRect.equalTo(.zero) {
            return
        }
        
        self.imageScale = self.frame.size.width/imageRect.size.width
        imageRect.size = CGSize(width: imageRect.size.width*imageScale, height: imageRect.size.height*imageScale)
       
        //根据图片的缩放计算scrollview的缩放级别
        // 图片相对于视图放大了1/imageScale倍，所以用log2(1/imageScale)得出缩放次数，
        // 然后通过pow得出缩放倍数，至于为什么要加1，
        // 是希望图片在放大到原图比例时，还可以继续放大一次（即2倍），可以看的更清晰
        let level = ceil(log2(1/imageScale))+1
        let zoomOutLevels = 1
        let zoomInLevels = pow(2, level)
        
        self.maximumZoomScale = zoomInLevels
        self.minimumZoomScale = CGFloat(zoomOutLevels)
        self.contentSize = imageRect.size
        
        self.tiledView = EHTiledImageView(frame: imageRect, image: self.image, scale: self.imageScale)
        self.tiledView?.tag = 101
        
        guard let tiledView =  self.tiledView else {
            return
        }
        
        if let v = self.viewWithTag(101) {
            v.removeFromSuperview()
        }
        self.addSubview(tiledView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTouch(_:)))
        tap.numberOfTapsRequired = 2
        tiledView.addGestureRecognizer(tap)
    }
    
    @objc func handleDoubleTouch(_ gesture:UIGestureRecognizer){
        var toScale = self.minimumZoomScale
        if self.zoomScale == self.minimumZoomScale {
            toScale = self.maximumZoomScale
            
        }else if self.zoomScale <= self.maximumZoomScale,self.zoomScale > self.minimumZoomScale{
            toScale = self.minimumZoomScale
        }

        var zoomRect = CGRect.zero
        let point = gesture.location(in: gesture.view)
        zoomRect.size.height = self.frame.size.height / toScale
        zoomRect.size.width = self.frame.size.width / toScale
        zoomRect.origin.x = point.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y = point.y - (zoomRect.size.height / 2.0)
        self.zoom(to: zoomRect, animated: true)
        
    }
    
    override func zoom(to rect: CGRect, animated: Bool) {
        super.zoom(to: rect, animated: animated)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let tiledView =  self.tiledView else {
            return
        }
        // center the image as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = tiledView.frame
        // center horizontally
        if frameToCenter.size.width < boundsSize.width{
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        }else{
            frameToCenter.origin.x = 0
        }
        // center vertically
        if frameToCenter.size.height < boundsSize.height{
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        }else{
            frameToCenter.origin.y = 0
        }
        tiledView.frame = frameToCenter
        // to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
        // tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
        // which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
        tiledView.contentScaleFactor = 1.0
    }
    
    deinit {
        print("EHLargeImageScrollView is deinit")
    }
    
}

extension EHLargeImageScrollView:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return tiledView
    }
    
    
}
