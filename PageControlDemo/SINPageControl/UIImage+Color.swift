//
//  File.swift
//  SINUIKit
//
//  Created by Annabelle on 2018/9/17.
//

import Foundation
import UIKit

extension UIImage {
    
    /**
     *  传入颜色生成image
     *
     *  @param color color
     *
     *  @return image
     */
    public class func sin_image(color: UIColor) -> UIImage? {
        return sin_image(color: color, size: CGSize(width: 1, height: 1))
    }
    
    public class func sin_image(color: UIColor, size: CGSize) -> UIImage? {
        
        if size.width == 0.0 || size.height == 0.0 {
            return nil
        }
        
        return sin_image(size: size) { (context) in
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.setFillColor(color.cgColor)
            context.addRect(rect)
            context.fill(rect)
        }
    }
    
    public class func sin_image(size: CGSize, drawHandler:(_ contex: CGContext) -> ()) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let contex = UIGraphicsGetCurrentContext()
        
        if let contex = contex {
            drawHandler(contex)
        } else {
            return nil
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

