//
//  UIImage+Ex.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

extension UIImage {
    func scaleTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage ?? self
    }
    
    /// 图片压缩
    ///
    /// - Returns: 压缩后的图片
    func resizeImage(maxSize: CGFloat = 1280) -> UIImage? {
        let originalImg = self
        //prepare constants
        let width = originalImg.size.width
        let height = originalImg.size.height
        let scale = width/height
        
        var sizeChange = CGSize()
        
        if width <= maxSize && height <= maxSize { //a，图片宽或者高均小于或等于maxSize时图片尺寸保持不变，不改变图片大小
            return originalImg
        } else if width > maxSize || height > maxSize {//b,宽或者高大于maxSize，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至maxSize
            
            if scale <= 2 && scale >= 1 {
                let changedWidth: CGFloat = maxSize
                let changedheight: CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if scale >= 0.5 && scale <= 1 {
                
                let changedheight: CGFloat = maxSize
                let changedWidth: CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if width > maxSize && height > maxSize {//宽以及高均大于maxSize，但是图片宽高比大于2时，则宽或者高取小的等比压缩至maxSize
                
                if scale > 2 {//高的值比较小
                    
                    let changedheight: CGFloat = maxSize
                    let changedWidth: CGFloat = changedheight * scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                } else if scale < 0.5 {//宽的值比较小
                    
                    let changedWidth: CGFloat = maxSize
                    let changedheight: CGFloat = changedWidth / scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                }
            } else {//d, 宽或者高，只有一个大于maxSize，并且宽高比超过2，不改变图片大小
                return originalImg
            }
        }
        
        UIGraphicsBeginImageContext(sizeChange)
        
        //draw resized image on Context
        originalImg.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
        
        //create UIImage
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImg
    }
}
